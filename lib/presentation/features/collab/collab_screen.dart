import 'dart:async';
import 'dart:typed_data';

import 'package:crdt_lf/crdt_lf.dart';
import 'package:crdt_lf_flutter/crdt_lf_flutter.dart';
import 'package:crdt_socket_sync/web_socket_relay_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/p2p_service.dart';
import '../../../data/datasources/collab_doc_storage.dart';
import '../../../presentation/theme/theme_provider.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_button.dart';

const String _kContentHandler = 'content';
const int _kDefaultPeerColor = 0xFF229ED9;
const List<int> _peerColors = [
  0xFF229ED9,
  0xFFE63946,
  0xFF16A34A,
  0xFFD97706,
  0xFF7C3AED,
  0xFF0EA5E9,
];

class CollabScreen extends ConsumerStatefulWidget {
  const CollabScreen({super.key});
  @override
  ConsumerState<CollabScreen> createState() => _CollabScreenState();
}

class _CollabScreenState extends ConsumerState<CollabScreen>
    with TickerProviderStateMixin {
  // --- CRDT ---
  final _urlCtrl =
      TextEditingController(text: AppConstants.collabDefaultServerUrl);
  final _roomCtrl = TextEditingController(text: AppConstants.collabDefaultRoom);
  final _editorFocus = FocusNode();
  CRDTDocument? _doc;
  WebSocketRelayClient? _client;
  ClientAwarenessPlugin? _awareness;
  StreamSubscription<ConnectionStatus>? _statusSub;
  StreamSubscription<DocumentAwareness>? _awarenessSub;
  StreamSubscription<dynamic>? _docUpdatesSub;
  Timer? _saveDebounce;
  late PeerId _siteId;
  String _activeRoom = AppConstants.collabDefaultRoom;
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String? _mySessionId;
  Map<String, ClientAwareness> _peers = {};
  bool _liveEditing = true;

  // --- P2P ---
  P2PService? _p2p;
  final _chatCtrl = TextEditingController();
  final List<ChatMessage> _chats = [];
  final List<FileMeta> _files = [];
  final Map<String, List<int>> _fileRecvBuffers = {};
  late TabController _tabCtrl;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  bool _p2pJoined = false;
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;

  bool get _connected =>
      _status == ConnectionStatus.connected ||
      _status == ConnectionStatus.reconnecting ||
      _status == ConnectionStatus.connecting;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _siteId = CollabDocStorage.loadOrCreateSiteId();
    _startSession(AppConstants.collabDefaultRoom);
    _localRenderer.initialize();
  }

  void _startSession(String roomId) {
    _teardownDocSubs();
    _doc?.dispose();
    _activeRoom = roomId;
    final doc = CRDTDocument(documentId: roomId, peerId: _siteId);
    CRDTFugueTextHandler(doc, _kContentHandler);
    final stored = CollabDocStorage.loadSnapshot(roomId);
    if (stored != null) {
      try {
        doc.importSnapshot(stored, pruneHistory: false);
      } catch (_) {}
    }
    _doc = doc;
    _docUpdatesSub = doc.updates.listen((_) => _scheduleSave());
    if (mounted) setState(() {});
  }

  void _scheduleSave() {
    if (!_liveEditing) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 800), () {
      final doc = _doc;
      if (doc == null) return;
      try {
        CollabDocStorage.saveSnapshot(
            _activeRoom, doc.takeSnapshot(pruneHistory: false));
      } catch (_) {}
    });
  }

  void _saveNow() {
    _saveDebounce?.cancel();
    final doc = _doc;
    if (doc == null) return;
    try {
      CollabDocStorage.saveSnapshot(
          _activeRoom, doc.takeSnapshot(pruneHistory: false));
    } catch (_) {}
  }

  void _teardownDocSubs() {
    _docUpdatesSub?.cancel();
    _docUpdatesSub = null;
  }

  Future<void> _connect() async {
    Vibrate.feedback(FeedbackType.light);
    final rawUrl = _urlCtrl.text.trim();
    if (rawUrl.isEmpty) return;
    final url = rawUrl.startsWith('ws://') || rawUrl.startsWith('wss://')
        ? rawUrl
        : 'ws://$rawUrl';
    final room = _roomCtrl.text.trim();
    if (room.isNotEmpty && room != _activeRoom) {
      _saveNow();
      _startSession(room);
    }
    await _disconnectClient();
    final name = ref.read(settingsProvider.select((s) => s.userName));
    final displayName = name.trim().isEmpty ? 'Guest' : name.trim();
    const myColor = _kDefaultPeerColor;
    final awareness = ClientAwarenessPlugin(
        initialMetadata: {'name': displayName, 'color': myColor});
    final client = WebSocketRelayClient(
        url: url, document: _doc!, author: _siteId, plugins: [awareness]);
    _statusSub = client.connectionStatus.listen((status) {
      if (!mounted) return;
      setState(() => _status = status);
      if (status == ConnectionStatus.connected) _mySessionId = client.sessionId;
    });
    _awarenessSub = awareness.awarenessStream.listen((state) {
      if (!mounted) return;
      final own = _mySessionId ?? client.sessionId;
      setState(() => _peers = Map<String, ClientAwareness>.from(state.states)
        ..remove(own));
    });
    _client = client;
    _awareness = awareness;
    setState(() => _status = ConnectionStatus.connecting);
    final ok = await client.connect();
    if (!ok && mounted) setState(() => _status = ConnectionStatus.error);
    // Also join P2P if enabled
    if (_p2pJoined) await _joinP2P();
  }

  Future<void> _disconnectClient() async {
    _statusSub?.cancel();
    _awarenessSub?.cancel();
    _statusSub = null;
    _awarenessSub = null;
    try {
      await _client?.disconnect();
    } catch (_) {}
    try {
      _client?.dispose();
    } catch (_) {}
    try {
      _awareness?.dispose();
    } catch (_) {}
    _client = null;
    _awareness = null;
    if (mounted) {
      setState(() {
        _peers = {};
        _mySessionId = null;
      });
    }
  }

  Future<void> _disconnect() async {
    Vibrate.feedback(FeedbackType.light);
    await _leaveP2P();
    await _disconnectClient();
    if (mounted) setState(() => _status = ConnectionStatus.disconnected);
  }

  // ---- P2P ----
  String get _signalingUrl {
    final raw = _urlCtrl.text.trim();
    if (raw.isEmpty) return 'ws://192.168.1.100:8789';
    // Use same host but port 8789 for signaling
    try {
      final uri = Uri.parse(raw.startsWith('ws') ? raw : 'ws://$raw');
      final port = 8789;
      return '${uri.scheme}://${uri.host}:$port';
    } catch (_) {
      return 'ws://192.168.1.100:8789';
    }
  }

  Future<void> _joinP2P() async {
    final name = ref.read(settingsProvider.select((s) => s.userName)).trim();
    final displayName = name.isEmpty ? 'Guest' : name;
    final p2p =
        P2PService(selfId: _siteId.toString(), displayName: displayName);
    // Request permissions
    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    final hasVideo = cam.isGranted;
    final hasAudio = mic.isGranted;
    await p2p.initLocalMedia(video: hasVideo, audio: hasAudio);
    if (p2p.localStream != null) {
      _localRenderer.srcObject = p2p.localStream;
    }
    p2p.onPeersChanged.listen((peers) {
      if (!mounted) return;
      setState(() {});
      // Setup remote renderers
      for (final peer in peers) {
        if (peer.remoteStream != null &&
            !_remoteRenderers.containsKey(peer.id)) {
          final r = RTCVideoRenderer();
          r.initialize().then((_) {
            r.srcObject = peer.remoteStream;
            if (mounted) setState(() => _remoteRenderers[peer.id] = r);
          });
        }
      }
      // Remove left peers renderers
      final ids = peers.map((e) => e.id).toSet();
      for (final id in _remoteRenderers.keys.toList()) {
        if (!ids.contains(id)) {
          _remoteRenderers[id]?.dispose();
          _remoteRenderers.remove(id);
        }
      }
    });
    p2p.onChat.listen((msg) {
      if (!mounted) return;
      setState(() => _chats.add(msg));
    });
    p2p.onFileMeta.listen((meta) {
      if (!mounted) return;
      setState(() => _files.add(meta));
    });
    p2p.onFileChunk.listen((data) {
      final bytes = data['data'] as Uint8List;
      // Simple append to last file buffer (mesh needs fileId header, simplified)
      final lastId = _files.isNotEmpty ? _files.last.fileId : null;
      if (lastId != null) {
        _fileRecvBuffers[lastId] ??= [];
        _fileRecvBuffers[lastId]!.addAll(bytes);
      }
    });
    await p2p.connectSignaling(_signalingUrl, _activeRoom);
    _p2p = p2p;
    setState(() => _p2pJoined = true);
  }

  Future<void> _leaveP2P() async {
    for (final r in _remoteRenderers.values) {
      try {
        await r.dispose();
      } catch (_) {}
    }
    _remoteRenderers.clear();
    try {
      await _p2p?.leave();
    } catch (_) {}
    try {
      await _p2p?.dispose();
    } catch (_) {}
    _p2p = null;
    _localRenderer.srcObject = null;
    if (mounted) setState(() => _p2pJoined = false);
  }

  Future<void> _toggleP2P() async {
    Vibrate.feedback(FeedbackType.light);
    if (_p2pJoined) {
      await _leaveP2P();
    } else {
      await _joinP2P();
    }
  }

  Future<void> _sendChat() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    _chatCtrl.clear();
    await _p2p?.sendChat(text);
    // If not in P2P, still add locally via signaling fallback is inside P2P service which also sends via signaling
    if (_p2p == null || !_p2pJoined) {
      // Fallback: add locally
      setState(() => _chats.add(ChatMessage(
          from: 'You',
          fromId: _siteId.toString(),
          text: text,
          ts: DateTime.now(),
          isMe: true)));
    }
  }

  Future<void> _pickAndSendFile() async {
    final res = await FilePicker.platform.pickFiles(withData: true);
    if (res == null || res.files.isEmpty) return;
    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    if (_p2p != null && _p2pJoined) {
      await _p2p!.sendFile(bytes, file.name);
      setState(() => _files.add(FileMeta(
          fileId: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: file.name,
          fileSize: bytes.length,
          fromId: _siteId.toString(),
          fromName: 'You')));
    } else {
      // No P2P, just show locally
      setState(() => _files.add(FileMeta(
          fileId: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: file.name,
          fileSize: bytes.length,
          fromId: _siteId.toString(),
          fromName: 'You')));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Join P2P to send files live')));
      }
    }
  }

  @override
  void dispose() {
    _saveNow();
    _statusSub?.cancel();
    _awarenessSub?.cancel();
    _docUpdatesSub?.cancel();
    _saveDebounce?.cancel();
    try {
      _client?.disconnect();
    } catch (_) {}
    try {
      _client?.dispose();
    } catch (_) {}
    try {
      _awareness?.dispose();
    } catch (_) {}
    try {
      _doc?.dispose();
    } catch (_) {}
    _leaveP2P();
    _localRenderer.dispose();
    for (final r in _remoteRenderers.values) {
      r.dispose();
    }
    _urlCtrl.dispose();
    _roomCtrl.dispose();
    _editorFocus.dispose();
    _chatCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doc = _doc;
    final userName =
        ref.watch(settingsProvider.select((s) => s.userName)).trim();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Room'),
        actions: [
          IconButton(
            tooltip: _liveEditing ? 'Live editing ON' : 'Live editing OFF',
            icon: Icon(
                _liveEditing ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                size: 20),
            onPressed: () {
              Vibrate.feedback(FeedbackType.selection);
              setState(() => _liveEditing = !_liveEditing);
            },
          ),
          Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _StatusPill(status: _status)),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
          unselectedLabelColor:
              (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)
                  .withValues(alpha: 0.5),
          indicatorColor: ComicTheme.inkRed,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.videocam_rounded, size: 18), text: 'VIDEO'),
            Tab(icon: Icon(Icons.chat_bubble_rounded, size: 16), text: 'CHAT'),
            Tab(icon: Icon(Icons.edit_document, size: 16), text: 'DOC'),
            Tab(icon: Icon(Icons.folder_rounded, size: 16), text: 'FILES'),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Column(children: [
                        _buildConnectionCard(isDark),
                        _buildPresenceBar(userName, isDark),
                        const SizedBox(height: 8),
                        Expanded(child: _buildVideoPanel(isDark)),
                      ])),
                  const VerticalDivider(width: 1),
                  Expanded(
                      flex: 4,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildVideoPanel(isDark),
                          _buildChatPanel(isDark),
                          _buildEditor(doc, isDark),
                          _buildFilesPanel(isDark),
                        ],
                      )),
                ],
              );
            }
            return Column(
              children: [
                _buildConnectionCard(isDark),
                _buildPresenceBar(userName, isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildVideoPanel(isDark),
                      _buildChatPanel(isDark),
                      _buildEditor(doc, isDark),
                      _buildFilesPanel(isDark),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionCard(bool isDark) {
    final canEdit = !_connected && !_p2pJoined;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: _comicBox(isDark),
      child: Column(children: [
        TextField(
          controller: _urlCtrl,
          enabled: canEdit,
          keyboardType: TextInputType.url,
          style: TextStyle(
              fontSize: 12,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack),
          decoration: const InputDecoration(
              labelText: 'Relay / Signaling (LAN)',
              hintText: 'ws://192.168.1.100:8787',
              border: InputBorder.none,
              isDense: true),
        ),
        const Divider(height: 12),
        Row(children: [
          Expanded(
              child: TextField(
            controller: _roomCtrl,
            enabled: canEdit,
            style: TextStyle(
                fontSize: 12,
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack),
            decoration: const InputDecoration(
                labelText: 'Room',
                hintText: 'stdy4u-notes',
                border: InputBorder.none,
                isDense: true),
          )),
          const SizedBox(width: 8),
          ComicButton(
            isCta: !_connected,
            onPressed: (_status == ConnectionStatus.connecting ||
                    _status == ConnectionStatus.reconnecting)
                ? () {}
                : (_connected ? _disconnect : _connect),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(_connected ? 'LEAVE' : 'JOIN'),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: ComicButton(
            isCta: _p2pJoined,
            onPressed: _toggleP2P,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                  _p2pJoined
                      ? Icons.call_end_rounded
                      : Icons.video_call_rounded,
                  size: 16,
                  color: _p2pJoined ? Colors.white : ComicTheme.inkBlack),
              const SizedBox(width: 6),
              Text(_p2pJoined ? 'LEAVE P2P' : 'JOIN P2P'),
            ]),
          )),
          const SizedBox(width: 8),
          IconButton(
            tooltip: _isAudioEnabled ? 'Mute' : 'Unmute',
            onPressed: () async {
              await _p2p?.toggleMic();
              setState(() => _isAudioEnabled = _p2p?.micEnabled ?? true);
            },
            icon: Icon(
                _isAudioEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                size: 18),
          ),
          IconButton(
            tooltip: _isVideoEnabled ? 'Cam off' : 'Cam on',
            onPressed: () async {
              await _p2p?.toggleCam();
              setState(() => _isVideoEnabled = _p2p?.camEnabled ?? true);
            },
            icon: Icon(
                _isVideoEnabled
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                size: 18),
          ),
          IconButton(
              tooltip: 'Switch cam',
              onPressed: () => _p2p?.switchCamera(),
              icon: const Icon(Icons.flip_camera_ios_rounded, size: 18)),
        ]),
      ]),
    );
  }

  Widget _buildPresenceBar(String userName, bool isDark) {
    final me = userName.isEmpty ? 'You' : userName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(children: [
        _PeerBadge(name: me, color: const Color(_kDefaultPeerColor)),
        const SizedBox(width: 4),
        for (final peer in _peers.values.take(5)) ...[
          const SizedBox(width: 2),
          _PeerBadge(
              name: (peer.metadata['name'] as String?)?.isNotEmpty == true
                  ? peer.metadata['name'] as String
                  : 'Peer',
              color: Color(
                  (peer.metadata['color'] as int?) ?? _nextPeerColor(peer))),
        ],
        const Spacer(),
        Text('${_peers.length + 1} in room',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack)),
        const SizedBox(width: 8),
        Text('${_p2p?.peers.length ?? 0} P2P',
            style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? ComicTheme.darkText.withValues(alpha: 0.6)
                    : ComicTheme.inkBlack.withValues(alpha: 0.6))),
      ]),
    );
  }

  int _nextPeerColor(ClientAwareness p) =>
      _peerColors[p.clientId.hashCode.abs() % _peerColors.length];

  Widget _buildVideoPanel(bool isDark) {
    final peers = _p2p?.peers.values.toList() ?? [];
    // Responsive grid: 1 col on narrow, 2 cols on wide
    return LayoutBuilder(builder: (context, c) {
      final cross = c.maxWidth > 500 ? 2 : 1;
      return Container(
        margin: const EdgeInsets.all(12),
        decoration: _comicBox(isDark),
        child: peers.isEmpty && _p2p?.localStream == null
            ? Center(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.videocam_off_rounded,
                          size: 40,
                          color: (isDark
                                  ? ComicTheme.darkText
                                  : ComicTheme.inkBlack)
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text(
                          'No P2P peers yet\nTap JOIN P2P to start video/voice',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: (isDark
                                      ? ComicTheme.darkText
                                      : ComicTheme.inkBlack)
                                  .withValues(alpha: 0.6))),
                    ])))
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cross,
                    childAspectRatio: 16 / 10,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8),
                itemCount: 1 + peers.length,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _VideoTile(
                        label: 'You',
                        stream: _p2p?.localStream,
                        renderer: _localRenderer,
                        isLocal: true,
                        muted: true);
                  }
                  final p = peers[i - 1];
                  return _VideoTile(
                      label: p.displayName,
                      stream: p.remoteStream,
                      renderer: _remoteRenderers[p.id],
                      isLocal: false,
                      muted: false);
                },
              ),
      );
    });
  }

  Widget _buildChatPanel(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: _comicBox(isDark),
      child: Column(children: [
        Expanded(
            child: _chats.isEmpty
                ? Center(
                    child: Text('No messages yet',
                        style: TextStyle(
                            color: (isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)
                                .withValues(alpha: 0.5),
                            fontSize: 12)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _chats.length,
                    itemBuilder: (context, i) {
                      final m = _chats[i];
                      return Align(
                        alignment: m.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: m.isMe
                                ? ComicTheme.inkRed
                                : (isDark
                                    ? ComicTheme.darkSurface
                                    : Colors.white),
                            border: Border.all(
                                color: ComicTheme.inkBlack, width: 1.5),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.from,
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: m.isMe
                                            ? Colors.white
                                            : ComicTheme.inkRed)),
                                Text(m.text,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: m.isMe
                                            ? Colors.white
                                            : (isDark
                                                ? ComicTheme.darkText
                                                : ComicTheme.inkBlack))),
                              ]),
                        ),
                      );
                    },
                  )),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
                child: TextField(
              controller: _chatCtrl,
              decoration: InputDecoration(
                  hintText: 'Type message...',
                  isDense: true,
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: ComicTheme.inkBlack, width: 1.5)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              onSubmitted: (_) => _sendChat(),
            )),
            const SizedBox(width: 8),
            ComicButton(
                isCta: true,
                onPressed: _sendChat,
                child: const Icon(Icons.send_rounded, size: 16)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEditor(CRDTDocument? doc, bool isDark) {
    final editor = doc == null
        ? const SizedBox.shrink()
        : CrdtProvider.value(
            value: doc,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: _comicBox(isDark),
              child: ClipRRect(
                child: Column(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: _liveEditing
                        ? ComicTheme.inkRed.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    child: Row(children: [
                      Icon(
                          _liveEditing
                              ? Icons.sync_rounded
                              : Icons.sync_disabled_rounded,
                          size: 14,
                          color:
                              _liveEditing ? ComicTheme.inkRed : Colors.grey),
                      const SizedBox(width: 6),
                      Text(_liveEditing ? 'LIVE SYNC ON' : 'LIVE SYNC PAUSED',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _liveEditing
                                  ? ComicTheme.inkRed
                                  : Colors.grey)),
                      const Spacer(),
                      Switch(
                          value: _liveEditing,
                          activeTrackColor: ComicTheme.inkRed,
                          onChanged: (v) => setState(() => _liveEditing = v)),
                    ]),
                  ),
                  Expanded(
                    child: CrdtTextFieldBuilder(
                      id: _kContentHandler,
                      builder: (context, controller) => TextField(
                        controller: controller,
                        focusNode: _editorFocus,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        cursorColor: ComicTheme.inkRed,
                        enabled: _liveEditing,
                        style: TextStyle(
                            fontSize: 14.5,
                            height: 1.55,
                            color: isDark
                                ? ComicTheme.darkText
                                : ComicTheme.inkBlack),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(14),
                          hintText: _liveEditing
                              ? 'Shared notes — everyone sees edits live…'
                              : 'Live paused — edits stay local',
                          hintStyle: TextStyle(
                              color: (isDark
                                      ? ComicTheme.darkText
                                      : ComicTheme.inkBlack)
                                  .withValues(alpha: 0.4)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
    return Column(children: [
      Expanded(child: editor),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Text(
          _liveEditing
              ? (_connected
                  ? 'Live — keystrokes merge on all peers'
                  : 'Offline — will merge when you rejoin')
              : 'Paused — tap sync to resume live merging',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)
                  .withValues(alpha: 0.5)),
        ),
      ),
    ]);
  }

  Widget _buildFilesPanel(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: _comicBox(isDark),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Icon(Icons.folder_rounded, size: 16),
            const SizedBox(width: 8),
            Text('Shared Files',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack)),
            const Spacer(),
            ComicButton(
                isCta: true,
                onPressed: _pickAndSendFile,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.upload_rounded, size: 14),
                  SizedBox(width: 4),
                  Text('SEND')
                ]))
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: _files.isEmpty
              ? Center(
                  child: Text('No files yet',
                      style: TextStyle(
                          color: (isDark
                                  ? ComicTheme.darkText
                                  : ComicTheme.inkBlack)
                              .withValues(alpha: 0.5),
                          fontSize: 12)))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, i) {
                    final f = _files[i];
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file_rounded),
                      title: Text(f.fileName,
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                          '${(f.fileSize / 1024).toStringAsFixed(1)} KB • from ${f.fromName}',
                          style: const TextStyle(fontSize: 10)),
                      trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, size: 18),
                          onPressed: () {
                            // For received files, data is in buffers – here we just show info
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('File ${f.fileName} ready')));
                          }),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

BoxDecoration _comicBox(bool isDark) => BoxDecoration(
      color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
      border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
      boxShadow: const [
        BoxShadow(
            color: ComicTheme.inkBlack, offset: Offset(3, 3), blurRadius: 0)
      ],
    );

class _PeerBadge extends StatelessWidget {
  final String name;
  final Color color;
  const _PeerBadge({required this.name, required this.color});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: name,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: ComicTheme.inkBlack, width: 2)),
          child: Text(name.characters.first.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      );
}

class _StatusPill extends StatelessWidget {
  final ConnectionStatus status;
  const _StatusPill({required this.status});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ConnectionStatus.connected => ('LIVE', const Color(0xFF16A34A)),
      ConnectionStatus.connecting => ('SYNC…', const Color(0xFFD97706)),
      ConnectionStatus.reconnecting => ('RETRY', const Color(0xFFD97706)),
      ConnectionStatus.error => ('ERROR', ComicTheme.inkRed),
      ConnectionStatus.disconnected => ('OFFLINE', const Color(0xFF6B7280)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color, width: 2)),
      child: Text(label,
          style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: color)),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final String label;
  final MediaStream? stream;
  final RTCVideoRenderer? renderer;
  final bool isLocal;
  final bool muted;
  const _VideoTile(
      {required this.label,
      this.stream,
      this.renderer,
      required this.isLocal,
      required this.muted});
  @override
  Widget build(BuildContext context) {
    final hasVideo = renderer != null &&
        stream != null &&
        stream!.getVideoTracks().isNotEmpty &&
        stream!.getVideoTracks().first.enabled;
    return Container(
      decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: ComicTheme.inkBlack, width: 2)),
      child: Stack(children: [
        if (hasVideo && renderer != null)
          RTCVideoView(renderer!,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: isLocal)
        else
          Center(
              child: Icon(Icons.person_rounded,
                  size: 40, color: Colors.white.withValues(alpha: 0.7))),
        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: Colors.black54,
            child: Text(label + (isLocal ? ' (You)' : ''),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        if (muted && !isLocal)
          const Positioned(
              right: 6,
              top: 6,
              child:
                  Icon(Icons.mic_off_rounded, size: 14, color: Colors.white)),
      ]),
    );
  }
}
