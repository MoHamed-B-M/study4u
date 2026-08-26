import 'dart:async';

import 'package:crdt_lf/crdt_lf.dart';
import 'package:crdt_lf_flutter/crdt_lf_flutter.dart';
import 'package:crdt_socket_sync/web_socket_relay_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/collab_doc_storage.dart';
import '../../../presentation/theme/theme_provider.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_button.dart';

/// Shared text handler id — every peer uses the same one so ops merge into
/// the same document tree (classic flat crdt_lf usage).
const String _kContentHandler = 'content';

/// Fallback presence colour for this device.
const int _kDefaultPeerColor = 0xFF229ED9;

/// Comic-print palette (ARGB ints) used to colour peers' presence badges.
const List<int> _peerColors = [
  0xFF229ED9, // telegram blue
  0xFFE63946, // ink red
  0xFF16A34A, // green
  0xFFD97706, // amber
  0xFF7C3AED, // violet
  0xFF0EA5E9, // sky
];

/// Real-time collaborative notes ("Study Room").
///
/// Local-first by design:
///  * edits land instantly in a [CRDTFugueTextHandler] and persist locally
///    via Hive snapshots ([CollabDocStorage]) — no server required to work;
///  * a LAN relay ([WebSocketRelayClient], dumb rebroadcaster) syncs opaque
///    change blobs between devices; merging happens on-device;
///  * presence (who is in the room) flows through the awareness plugin.
class CollabScreen extends ConsumerStatefulWidget {
  const CollabScreen({super.key});

  @override
  ConsumerState<CollabScreen> createState() => _CollabScreenState();
}

class _CollabScreenState extends ConsumerState<CollabScreen> {
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

  bool get _connected =>
      _status == ConnectionStatus.connected ||
      _status == ConnectionStatus.reconnecting ||
      _status == ConnectionStatus.connecting;

  @override
  void initState() {
    super.initState();
    _siteId = CollabDocStorage.loadOrCreateSiteId();
    _startSession(AppConstants.collabDefaultRoom);
  }

  // ---------------------------------------------------------------------
  // Session lifecycle (document + local persistence)
  // ---------------------------------------------------------------------

  /// Builds (or rebuilds) the CRDT session for [roomId] and replays any
  /// locally persisted snapshot so the document works fully offline first.
  void _startSession(String roomId) {
    _teardownDocSubs();
    _doc?.dispose();

    _activeRoom = roomId;
    final doc = CRDTDocument(documentId: roomId, peerId: _siteId);
    // Handler must exist before importing so the snapshot state lands in it.
    // It self-registers into the document; CrdtTextFieldBuilder resolves it
    // by id, so no long-lived Dart reference is needed here.
    CRDTFugueTextHandler(doc, _kContentHandler);

    final stored = CollabDocStorage.loadSnapshot(roomId);
    if (stored != null) {
      try {
        doc.importSnapshot(stored, pruneHistory: false);
      } catch (_) {
        // A corrupt snapshot must never brick the room — start clean.
      }
    }

    _doc = doc;
    _docUpdatesSub = doc.updates.listen((_) => _scheduleSave());
    if (mounted) setState(() {});
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 800), () {
      final doc = _doc;
      if (doc == null) return;
      try {
        CollabDocStorage.saveSnapshot(
          _activeRoom,
          doc.takeSnapshot(pruneHistory: false),
        );
      } catch (_) {}
    });
  }

  void _saveNow() {
    _saveDebounce?.cancel();
    final doc = _doc;
    if (doc == null) return;
    try {
      CollabDocStorage.saveSnapshot(
        _activeRoom,
        doc.takeSnapshot(pruneHistory: false),
      );
    } catch (_) {}
  }

  void _teardownDocSubs() {
    _docUpdatesSub?.cancel();
    _docUpdatesSub = null;
  }

  // ---------------------------------------------------------------------
  // Network (LAN relay + awareness)
  // ---------------------------------------------------------------------

  Future<void> _connect() async {
    Vibrate.feedback(FeedbackType.light);
    final rawUrl = _urlCtrl.text.trim();
    if (rawUrl.isEmpty) return;
    final url = rawUrl.startsWith('ws://') || rawUrl.startsWith('wss://')
        ? rawUrl
        : 'ws://$rawUrl';

    // Room changed while offline? Rebuild the session around the new id.
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
      initialMetadata: {'name': displayName, 'color': myColor},
    );
    final client = WebSocketRelayClient(
      url: url,
      document: _doc!,
      author: _siteId,
      plugins: [awareness],
    );

    _statusSub = client.connectionStatus.listen((status) {
      if (!mounted) return;
      setState(() => _status = status);
      if (status == ConnectionStatus.connected) {
        _mySessionId = client.sessionId;
      }
    });

    _awarenessSub = awareness.awarenessStream.listen((state) {
      if (!mounted) return;
      final own = _mySessionId ?? client.sessionId;
      setState(() {
        _peers = Map<String, ClientAwareness>.from(state.states)..remove(own);
      });
    });

    _client = client;
    _awareness = awareness;
    setState(() => _status = ConnectionStatus.connecting);

    final ok = await client.connect();
    if (!ok && mounted) {
      // Status stream will surface error/reconnecting details.
      setState(() => _status = ConnectionStatus.error);
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
    await _disconnectClient();
    if (mounted) setState(() => _status = ConnectionStatus.disconnected);
  }

  // ---------------------------------------------------------------------
  // Widget
  // ---------------------------------------------------------------------

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
    _urlCtrl.dispose();
    _roomCtrl.dispose();
    _editorFocus.dispose();
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _StatusPill(status: _status),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildConnectionCard(isDark),
            _buildPresenceBar(userName, isDark),
            const SizedBox(height: 10),
            Expanded(child: _buildEditor(doc, isDark)),
            _buildHintLine(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard(bool isDark) {
    final canEditFields = !_connected;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: _comicBox(isDark),
      child: Column(
        children: [
          TextField(
            controller: _urlCtrl,
            enabled: canEditFields,
            keyboardType: TextInputType.url,
            style: TextStyle(
                fontSize: 13,
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack),
            decoration: const InputDecoration(
              labelText: 'Relay server (LAN)',
              hintText: 'ws://192.168.1.100:8787',
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roomCtrl,
                  enabled: canEditFields,
                  style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? ComicTheme.darkText : ComicTheme.inkBlack),
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    hintText: 'stdy4u-notes',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ComicButton(
                isCta: !_connected,
                onPressed: (_status == ConnectionStatus.connecting ||
                        _status == ConnectionStatus.reconnecting)
                    ? () {}
                    : (_connected ? _disconnect : _connect),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  _connected
                      ? 'LEAVE'
                      : (_status == ConnectionStatus.connecting ||
                              _status == ConnectionStatus.reconnecting
                          ? '…'
                          : 'JOIN'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresenceBar(String userName, bool isDark) {
    final me = userName.isEmpty ? 'You' : userName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _PeerBadge(
              name: me.isEmpty ? 'You' : me,
              color: const Color(_kDefaultPeerColor)),
          const SizedBox(width: 6),
          for (final peer in _peers.values.take(5)) ...[
            const SizedBox(width: 2),
            _PeerBadge(
              name: (peer.metadata['name'] as String?)?.isNotEmpty == true
                  ? peer.metadata['name'] as String
                  : 'Peer',
              color: Color(
                (peer.metadata['color'] as int?) ?? _nextPeerColor(peer),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${_peers.length + 1} in room',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
            ),
          ),
        ],
      ),
    );
  }

  int _nextPeerColor(ClientAwareness peer) =>
      _peerColors[peer.clientId.hashCode.abs() % _peerColors.length];

  Widget _buildEditor(CRDTDocument? doc, bool isDark) {
    if (doc == null) {
      return const SizedBox.shrink();
    }
    return CrdtProvider.value(
      value: doc,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: _comicBox(isDark),
        child: ClipRRect(
          child: CrdtTextFieldBuilder(
            id: _kContentHandler,
            builder: (context, controller) => TextField(
              controller: controller,
              focusNode: _editorFocus,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              cursorColor: ComicTheme.inkRed,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14),
                hintText: 'Shared notes appear here — everyone in the room '
                    'sees edits live…',
                hintStyle: TextStyle(
                  color: (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)
                      .withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintLine(bool isDark) {
    final offline = !_connected;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Text(
        offline
            ? 'Offline mode — edits stay on this device and merge '
                'automatically once you join a relay.'
            : 'Live — every keystroke merges conflict-free on all peers.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.5,
          fontStyle: FontStyle.italic,
          color: (isDark ? ComicTheme.darkText : ComicTheme.inkBlack)
              .withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small presentational helpers
// ---------------------------------------------------------------------------

BoxDecoration _comicBox(bool isDark) => BoxDecoration(
      color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
      border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
      boxShadow: const [
        BoxShadow(
          color: ComicTheme.inkBlack,
          offset: Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    );

/// Coloured circle badge with a peer's initial.
class _PeerBadge extends StatelessWidget {
  final String name;
  final Color color;

  const _PeerBadge({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: name,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: ComicTheme.inkBlack, width: 2),
        ),
        child: Text(
          name.characters.first.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Bordered connection-state pill shown in the app bar.
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
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}
