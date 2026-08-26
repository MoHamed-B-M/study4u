import 'dart:io';

import 'package:crdt_socket_sync/web_socket_relay_server.dart';

/// LAN relay for stdy4u Study Rooms.
///
/// The relay is CRDT-agnostic: it persists opaque change blobs per room and
/// rebroadcasts them — all merging happens on-device inside crdt_lf. Run this
/// on any machine in your local network (no cloud needed):
///
///   dart run tools/collab_relay_server.dart 8787
///
/// Then point the app's Study Room screen at ws://machine-ip:8787.
Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8787 : 8787;

  final server = WebSocketRelayServer(
    serverFactory: () => HttpServer.bind(InternetAddress.anyIPv4, port),
    plugins: [ServerAwarenessPlugin()],
  );

  await server.start();
  stdout.writeln('stdy4u collab relay listening on ws://0.0.0.0:$port');
  stdout.writeln('Rooms are keyed by document id (e.g. "stdy4u-notes").');
}
