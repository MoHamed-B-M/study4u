import 'dart:async';
import 'dart:typed_data';

import 'package:crdt_lf/crdt_lf.dart';
import 'package:crdt_lf_flutter/crdt_lf_flutter.dart';
import 'package:crdt_socket_sync/web_socket_relay_client.dart';
import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  bool _p2pJoined = false;
  bool _isAudioEnabled = true;
  StreamSubscription<String>? _vibrateSub;

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
    if (rawUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Enter relay URL (e.g. ws://192.168.1.10:8787)')));
      }
      return;
    }
    final url = rawUrl.startsWith('ws://') || rawUrl.startsWith('wss://')
        ? rawUrl
        : 'ws://$rawUrl';
    final room = _roomCtrl.text.trim();
    if (room.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Enter a room code')));
      }
      return;
    }
    if (room != _activeRoom) {
      _saveNow();
      _startSession(room);
    }
    await _disconnectClient();
    final name = ref.read(settingsProvider.select((s) => s.userName));
    final displayName = name.trim().isEmpty ? 'Guest' : name.trim();
    const myColor = _kDefaultPeerColor;
    setState(() => _status = ConnectionStatus.connecting);
    try {
      final awareness = ClientAwarenessPlugin(
          initialMetadata: {'name': displayName, 'color': myColor});
      final client = WebSocketRelayClient(
          url: url, document: _doc!, author: _siteId, plugins: [awareness]);
      _statusSub = client.connectionStatus.listen((status) {
        if (!mounted) return;
        setState(() => _status = status);
        if (status == ConnectionStatus.connected)
          _mySessionId = client.sessionId;
        if (status == ConnectionStatus.error && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Connection error – check server at $url is running')));
        }
      });
      _awarenessSub = awareness.awarenessStream.listen((state) {
        if (!mounted) return;
        final own = _mySessionId ?? client.sessionId;
        setState(() => _peers = Map<String, ClientAwareness>.from(state.states)
          ..remove(own));
      });
      _client = client;
      _awareness = awareness;
      final ok = await client
          .connect()
          .timeout(const Duration(seconds: 8), onTimeout: () => false);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Working offline – relay not reachable at $url. Edits saved locally. Share QR or run: dart run tools/collab_relay_server.dart 8787'),
              duration: const Duration(seconds: 5)));
          setState(() => _status = ConnectionStatus.disconnected);
        }
        await _disconnectClient();
        return;
      }
      if (_p2pJoined) await _joinP2P();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Join failed: $e'),
            duration: const Duration(seconds: 4)));
        setState(() => _status = ConnectionStatus.error);
      }
      await _disconnectClient();
    }
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
    try {
      PermissionStatus micStatus = PermissionStatus.denied;
      try {
        micStatus = await Permission.microphone.request();
      } catch (_) {}
      final hasAudio = micStatus.isGranted;
      if (!hasAudio) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Mic denied – joining for chat/files/vibrate only')));
        }
      }
      final mediaOk = await p2p.initLocalMedia(video: false, audio: hasAudio);
      if (!mediaOk && hasAudio && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not start mic – check permissions')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Media init failed: $e')));
      }
    }
    p2p.onPeersChanged.listen((peers) {
      if (!mounted) return;
      setState(() {});
    });
    p2p.onChat.listen((msg) {
      if (!mounted) return;
      setState(() => _chats.add(msg));
    });
    _vibrateSub = p2p.onVibrate.listen((fromId) {
      if (!mounted) return;
      Vibrate.feedback(FeedbackType.heavy);
      Vibrate.vibrate();
      final fromName = p2p.peers[fromId]?.displayName ?? 'Peer';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$fromName sent a buzz!'),
            duration: const Duration(seconds: 2)),
      );
    });
    p2p.onFileMeta.listen((meta) {
      if (!mounted) return;
      setState(() => _files.add(meta));
    });
    p2p.onFileChunk.listen((data) {
      final bytes = data['data'] as Uint8List;
      final lastId = _files.isNotEmpty ? _files.last.fileId : null;
      if (lastId != null) {
        _fileRecvBuffers[lastId] ??= [];
        _fileRecvBuffers[lastId]!.addAll(bytes);
      }
    });
    try {
      await p2p.connectSignaling(_signalingUrl, _activeRoom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'P2P signaling failed at $_signalingUrl: $e\nCheck signaling server running (port 8789)'),
            duration: const Duration(seconds: 4)));
      }
    }
    _p2p = p2p;
    setState(() => _p2pJoined = true);
  }

  Future<void> _leaveP2P() async {
    await _vibrateSub?.cancel();
    _vibrateSub = null;
    try {
      await _p2p?.leave();
    } catch (_) {}
    try {
      await _p2p?.dispose();
    } catch (_) {}
    _p2p = null;
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

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  void _showQrDialog() {
    final room =
        _roomCtrl.text.trim().isEmpty ? _activeRoom : _roomCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    final data = jsonEncode({'r': room, 'u': url});
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
            border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(
                  color: ComicTheme.inkBlack,
                  offset: Offset(4, 4),
                  blurRadius: 0)
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Share Room',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack)),
            const SizedBox(height: 8),
            Text('Room: $room',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: ComicTheme.inkRed)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Ask peer to scan this QR\nor share code: $room',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)
                        .withValues(alpha: 0.7))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: ComicButton(
                      isCta: false,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'))),
              const SizedBox(width: 8),
              Expanded(
                  child: ComicButton(
                      isCta: true,
                      onPressed: () {
                        final newCode = _generateRoomCode();
                        _roomCtrl.text = newCode;
                        Navigator.pop(ctx);
                        _showQrDialog();
                      },
                      child: const Text('New Code'))),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showJoinWithCodeDialog() {
    final codeCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
            border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
            boxShadow: const [
              BoxShadow(
                  color: ComicTheme.inkBlack,
                  offset: Offset(4, 4),
                  blurRadius: 0)
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Join with Code',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack)),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                  hintText: 'e.g. A7K9P2',
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: ComicTheme.inkBlack, width: 2)),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: ComicButton(
                      isCta: false,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'))),
              const SizedBox(width: 8),
              Expanded(
                  child: ComicButton(
                      isCta: true,
                      onPressed: () {
                        final code = codeCtrl.text.trim().toUpperCase();
                        if (code.isEmpty) return;
                        _roomCtrl.text = code;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Room set to $code – tap JOIN')));
                      },
                      child: const Text('Set'))),
            ]),
            const SizedBox(height: 12),
            ComicButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openScanner();
                },
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.qr_code_scanner_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Scan QR')
                ])),
          ]),
        ),
      ),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _QrScannerPage(onScanned: (raw) {
              try {
                final map = jsonDecode(raw) as Map<String, dynamic>;
                final r = map['r'] as String?;
                final u = map['u'] as String?;
                if (r != null && r.isNotEmpty) _roomCtrl.text = r;
                if (u != null && u.isNotEmpty) _urlCtrl.text = u;
                if (r != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned room $r – tap JOIN')));
                }
              } catch (_) {
                final code = raw.trim().toUpperCase();
                if (code.isNotEmpty) {
                  _roomCtrl.text = code;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scanned code $code')));
                }
              }
            })));
  }

  @override
  void dispose() {
    _saveNow();
    _statusSub?.cancel();
    _awarenessSub?.cancel();
    _docUpdatesSub?.cancel();
    _saveDebounce?.cancel();
    _vibrateSub?.cancel();
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
            Tab(icon: Icon(Icons.call_rounded, size: 18), text: 'CALL'),
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
                        Expanded(child: _buildCallPanel(isDark)),
                      ])),
                  const VerticalDivider(width: 1),
                  Expanded(
                      flex: 4,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildCallPanel(isDark),
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
                      _buildCallPanel(isDark),
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
              Icon(_p2pJoined ? Icons.call_end_rounded : Icons.call_rounded,
                  size: 16,
                  color: _p2pJoined ? Colors.white : ComicTheme.inkBlack),
              const SizedBox(width: 6),
              Text(_p2pJoined ? 'LEAVE CALL' : 'JOIN CALL'),
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
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: ComicButton(
            onPressed: _showQrDialog,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_rounded, size: 14),
                  SizedBox(width: 4),
                  Text('Share QR', style: TextStyle(fontSize: 11)),
                ]),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: ComicButton(
            onPressed: _showJoinWithCodeDialog,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vpn_key_rounded, size: 14),
                  SizedBox(width: 4),
                  Text('Code', style: TextStyle(fontSize: 11)),
                ]),
          )),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: ComicTheme.inkBlack, width: 2)),
            child: IconButton(
                tooltip: 'Scan QR',
                onPressed: _openScanner,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18)),
          ),
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

  Future<void> _sendVibrateTo(String peerId, String peerName) async {
    if (_p2p == null || !_p2pJoined) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Join P2P to send buzz')));
      }
      return;
    }
    Vibrate.feedback(FeedbackType.heavy);
    Vibrate.vibrate();
    try {
      await _p2p!.sendVibrate(to: peerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Buzz sent to $peerName'),
            duration: const Duration(seconds: 1)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Buzz failed: $e')));
      }
    }
  }

  Future<void> _buzzAll() async {
    if (_p2p == null || !_p2pJoined) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Join P2P to buzz')));
      }
      return;
    }
    Vibrate.feedback(FeedbackType.heavy);
    if (_peers.isEmpty && (_p2p?.peers.isEmpty ?? true)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No peers to buzz')));
      }
      return;
    }
    for (final peer in _p2p!.peers.values) {
      try {
        await _p2p!.sendVibrate(to: peer.id);
      } catch (_) {}
    }
    // Also vibrate via signaling broadcast to cover awareness-only peers
    try {
      await _p2p!.sendVibrate();
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Buzz sent to all!')));
    }
  }

  Widget _buildCallPanel(bool isDark) {
    final p2pPeers = _p2p?.peers.values.toList() ?? [];
    final presencePeers = _peers.values.toList();
    final hasPeers = p2pPeers.isNotEmpty || presencePeers.isNotEmpty;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: _comicBox(isDark),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              Icon(_p2pJoined ? Icons.call_rounded : Icons.call_outlined,
                  size: 18,
                  color: _p2pJoined
                      ? const Color(0xFF16A34A)
                      : (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)),
              const SizedBox(width: 8),
              Text(_p2pJoined ? 'In Call' : 'Voice Call',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color:
                          isDark ? ComicTheme.darkText : ComicTheme.inkBlack)),
              const Spacer(),
              if (_p2pJoined)
                IconButton(
                  tooltip: _isAudioEnabled ? 'Mute' : 'Unmute',
                  onPressed: () async {
                    await _p2p?.toggleMic();
                    setState(() => _isAudioEnabled = _p2p?.micEnabled ?? true);
                  },
                  icon: Icon(
                      _isAudioEnabled
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      size: 18),
                ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: ComicButton(
                isCta: !_p2pJoined,
                onPressed: _toggleP2P,
                child: Text(_p2pJoined ? 'LEAVE CALL' : 'JOIN CALL'),
              )),
              const SizedBox(width: 8),
              ComicButton(
                isCta: false,
                onPressed: _buzzAll,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.vibration_rounded, size: 16),
                  SizedBox(width: 4),
                  Text('Buzz All'),
                ]),
              ),
            ]),
            if (!_p2pJoined)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Join call to enable voice and buzz',
                    style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color:
                            (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)
                                .withValues(alpha: 0.5))),
              ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: !hasPeers
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.people_outline_rounded,
                            size: 36,
                            color: (isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)
                                .withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                            _p2pJoined
                                ? 'No peers yet\nShare QR or code to invite'
                                : 'Join call to see peers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: (isDark
                                        ? ComicTheme.darkText
                                        : ComicTheme.inkBlack)
                                    .withValues(alpha: 0.6))),
                      ])))
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: presencePeers.isNotEmpty
                      ? presencePeers.length
                      : p2pPeers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (presencePeers.isNotEmpty) {
                      final peer = presencePeers[i];
                      final name =
                          (peer.metadata['name'] as String?)?.isNotEmpty == true
                              ? peer.metadata['name'] as String
                              : 'Peer';
                      final color = Color((peer.metadata['color'] as int?) ??
                          _nextPeerColor(peer));
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: ComicTheme.inkBlack, width: 2)),
                          child: Center(
                              child: Text(name.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800))),
                        ),
                        title: Text(name,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)),
                        subtitle: Text('Tap buzz to nudge',
                            style: TextStyle(
                                fontSize: 10,
                                color: (isDark
                                        ? ComicTheme.darkText
                                        : ComicTheme.inkBlack)
                                    .withValues(alpha: 0.6))),
                        trailing: ComicButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          onPressed: () => _sendVibrateTo(peer.clientId, name),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.vibration_rounded, size: 14),
                                SizedBox(width: 4),
                                Text('Buzz', style: TextStyle(fontSize: 11)),
                              ]),
                        ),
                      );
                    } else {
                      final p = p2pPeers[i];
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: ComicTheme.inkRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: ComicTheme.inkBlack, width: 2)),
                          child: Center(
                              child: Text(
                                  p.displayName.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800))),
                        ),
                        title: Text(p.displayName,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? ComicTheme.darkText
                                    : ComicTheme.inkBlack)),
                        trailing: ComicButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          onPressed: () => _sendVibrateTo(p.id, p.displayName),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.vibration_rounded, size: 14),
                                SizedBox(width: 4),
                                Text('Buzz'),
                              ]),
                        ),
                      );
                    }
                  },
                ),
        ),
      ]),
    );
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

class _QrScannerPage extends StatefulWidget {
  final void Function(String raw) onScanned;
  const _QrScannerPage({required this.onScanned});
  @override
  State<_QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            if (_handled) return;
            final barcodes = capture.barcodes;
            if (barcodes.isEmpty) return;
            final raw = barcodes.first.rawValue;
            if (raw == null || raw.isEmpty) return;
            _handled = true;
            widget.onScanned(raw);
            if (mounted) Navigator.of(context).pop();
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: const Text('Point camera at the QR code',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}
