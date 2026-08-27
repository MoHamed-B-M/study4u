import 'dart:convert';
import 'dart:io';

/// Simple WebRTC signaling relay – dumb broadcast per room.
/// Run: dart run tools/webrtc_signaling_server.dart [port]
/// Default port 8789 so it doesn't clash with the CRDT relay on 8787.
/// Clients send JSON {type, room, from, to?, sdp?, candidate?, text?}
/// and the server forwards to all other peers in the same room.
Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8789 : 8789;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  final rooms = <String, Set<WebSocket>>{};

  print('WebRTC signaling relay listening on ws://0.0.0.0:$port');
  print('Use same host as CRDT relay but port $port for P2P signaling.');

  await for (final req in server) {
    if (!WebSocketTransformer.isUpgradeRequest(req)) {
      req.response.statusCode = HttpStatus.notFound;
      await req.response.close();
      continue;
    }
    final socket = await WebSocketTransformer.upgrade(req);
    String? joinedRoom;
    socket.listen((data) {
      try {
        final map = jsonDecode(data as String) as Map<String, dynamic>;
        final room = map['room'] as String? ?? 'default';
        joinedRoom = room;
        rooms.putIfAbsent(room, () => <WebSocket>{}).add(socket);
        // Broadcast to others in room
        for (final peer in rooms[room]!.toList()) {
          if (peer != socket) {
            try {
              peer.add(data);
            } catch (_) {}
          }
        }
      } catch (_) {}
    }, onDone: () {
      if (joinedRoom != null) rooms[joinedRoom!]?.remove(socket);
    }, onError: (_) {
      if (joinedRoom != null) rooms[joinedRoom!]?.remove(socket);
    });
  }
}
