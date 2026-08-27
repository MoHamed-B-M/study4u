import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Lightweight signaling client for P2P WebRTC.
/// Connects to a dumb relay that just broadcasts JSON within a room.
/// Message shape: {type, room, from, to?, sdp?, candidate?, ...}
class SignalingService {
  SignalingService({required this.roomId, required this.selfId});

  final String roomId;
  final String selfId;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _controller.stream;

  bool get isConnected => _channel != null;

  Future<bool> connect(String url) async {
    try {
      final uri = Uri.parse(url);
      // Support ws://host:port and host:port forms
      final wsUri = (url.startsWith('ws://') || url.startsWith('wss://'))
          ? uri
          : Uri.parse('ws://$url');
      _channel = IOWebSocketChannel.connect(wsUri);
      _sub = _channel!.stream.listen(
        (data) {
          try {
            final map = jsonDecode(data as String) as Map<String, dynamic>;
            if (map['room'] != roomId) return;
            if (map['from'] == selfId) return;
            // If 'to' is set and not us, ignore (directed signal)
            final to = map['to'] as String?;
            if (to != null && to != selfId) return;
            _controller.add(map);
          } catch (_) {}
        },
        onDone: () => _controller.add({'type': 'disconnect'}),
        onError: (_) => _controller.add({'type': 'error'}),
      );
      // Announce join
      _send({'type': 'join', 'room': roomId, 'from': selfId});
      return true;
    } catch (_) {
      return false;
    }
  }

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void sendOffer(String to, Map<String, dynamic> sdp) => _send(
      {'type': 'offer', 'room': roomId, 'from': selfId, 'to': to, 'sdp': sdp});

  void sendAnswer(String to, Map<String, dynamic> sdp) => _send(
      {'type': 'answer', 'room': roomId, 'from': selfId, 'to': to, 'sdp': sdp});

  void sendIce(String to, Map<String, dynamic> candidate) => _send({
        'type': 'ice',
        'room': roomId,
        'from': selfId,
        'to': to,
        'candidate': candidate
      });

  void sendChat(String text, {String? to}) => _send({
        'type': 'chat',
        'room': roomId,
        'from': selfId,
        'to': to,
        'text': text,
        'ts': DateTime.now().millisecondsSinceEpoch
      });

  void sendFileMeta(String fileName, int fileSize, String fileId) => _send({
        'type': 'file_meta',
        'room': roomId,
        'from': selfId,
        'fileId': fileId,
        'fileName': fileName,
        'fileSize': fileSize
      });

  // For file chunks via DataChannel fallback we also support relay
  void leave() => _send({'type': 'leave', 'room': roomId, 'from': selfId});

  Future<void> disconnect() async {
    try {
      leave();
    } catch (_) {}
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
    try {
      _channel?.sink.close();
    } catch (_) {}
  }
}
