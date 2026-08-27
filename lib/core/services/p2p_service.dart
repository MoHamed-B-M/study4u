import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling_service.dart';

class RemotePeer {
  final String id;
  final String displayName;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  MediaStream? remoteStream;
  bool videoEnabled = true;
  bool audioEnabled = true;
  RemotePeer({required this.id, required this.displayName});
}

class ChatMessage {
  final String from;
  final String fromId;
  final String text;
  final DateTime ts;
  final bool isMe;
  ChatMessage(
      {required this.from,
      required this.fromId,
      required this.text,
      required this.ts,
      required this.isMe});
}

class FileMeta {
  final String fileId;
  final String fileName;
  final int fileSize;
  final String fromId;
  final String fromName;
  FileMeta(
      {required this.fileId,
      required this.fileName,
      required this.fileSize,
      required this.fromId,
      required this.fromName});
}

/// Mesh P2P manager – handles local media, peer connections, chat & file via DataChannel.
class P2PService {
  P2PService({required this.selfId, required this.displayName});

  final String selfId;
  final String displayName;

  MediaStream? localStream;
  final Map<String, RemotePeer> peers = {};
  final _peerController = StreamController<List<RemotePeer>>.broadcast();
  final _chatController = StreamController<ChatMessage>.broadcast();
  final _fileMetaController = StreamController<FileMeta>.broadcast();
  final _incomingFileController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _vibrateController = StreamController<String>.broadcast();

  Stream<List<RemotePeer>> get onPeersChanged => _peerController.stream;
  Stream<ChatMessage> get onChat => _chatController.stream;
  Stream<FileMeta> get onFileMeta => _fileMetaController.stream;
  Stream<Map<String, dynamic>> get onFileChunk =>
      _incomingFileController.stream;
  Stream<String> get onVibrate => _vibrateController.stream;

  SignalingService? _signaling;
  StreamSubscription<Map<String, dynamic>>? _sigSub;
  bool _micEnabled = true;
  bool _camEnabled = true;
  bool _disposed = false;

  bool get micEnabled => _micEnabled;
  bool get camEnabled => _camEnabled;

  final Map<String, List<int>> _fileBuffers = {};
  final Map<String, int> _fileExpected = {};

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  Future<bool> initLocalMedia({bool video = true, bool audio = true}) async {
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': audio,
        'video':
            video ? {'facingMode': 'user', 'width': 640, 'height': 480} : false,
      });
      _micEnabled = audio;
      _camEnabled = video;
      return true;
    } catch (e) {
      localStream = null;
      return false;
    }
  }

  Future<void> connectSignaling(String url, String roomId) async {
    _signaling = SignalingService(roomId: roomId, selfId: selfId);
    final ok = await _signaling!.connect(url);
    if (!ok) return;
    _sigSub = _signaling!.onMessage.listen(_handleSignal);
  }

  Future<void> _handleSignal(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    final from = msg['from'] as String? ?? 'peer';
    final fromName = (msg['fromName'] as String?) ?? from;
    switch (type) {
      case 'join':
        // New peer joined – we initiate offer
        if (!peers.containsKey(from)) {
          await _createPeer(from, fromName, initiator: true);
        }
        break;
      case 'offer':
        await _onOffer(from, fromName, msg['sdp'] as Map<String, dynamic>);
        break;
      case 'answer':
        await _onAnswer(from, msg['sdp'] as Map<String, dynamic>);
        break;
      case 'ice':
        await _onIce(from, msg['candidate'] as Map<String, dynamic>);
        break;
      case 'vibrate':
        _vibrateController.add(from);
        break;
      case 'chat':
        final text = msg['text'] as String? ?? '';
        _chatController.add(ChatMessage(
            from: fromName,
            fromId: from,
            text: text,
            ts: DateTime.now(),
            isMe: false));
        break;
      case 'file_meta':
        _fileMetaController.add(FileMeta(
            fileId: msg['fileId'] as String,
            fileName: msg['fileName'] as String,
            fileSize: msg['fileSize'] as int,
            fromId: from,
            fromName: fromName));
        _fileExpected[msg['fileId'] as String] = msg['fileSize'] as int;
        _fileBuffers[msg['fileId'] as String] = [];
        break;
      case 'leave':
        _removePeer(from);
        break;
    }
  }

  Future<void> _createPeer(String peerId, String name,
      {required bool initiator}) async {
    if (_disposed) return;
    if (peers.containsKey(peerId)) return;
    final peer = RemotePeer(id: peerId, displayName: name);
    peers[peerId] = peer;
    _peerController.add(peers.values.toList());

    final pc = await createPeerConnection(_iceServers);
    peer.pc = pc;

    // Add local tracks
    if (localStream != null) {
      for (final track in localStream!.getTracks()) {
        await pc.addTrack(track, localStream!);
      }
    }

    // Data channel for chat/files (initiator creates)
    if (initiator) {
      final dc = await pc.createDataChannel(
          'data', RTCDataChannelInit()..ordered = true);
      _setupDataChannel(peer, dc);
      peer.dc = dc;
    } else {
      pc.onDataChannel = (dc) => _setupDataChannel(peer, dc);
    }

    pc.onIceCandidate = (cand) {
      if (cand.candidate != null) {
        _signaling?.sendIce(peerId, {
          'candidate': cand.candidate,
          'sdpMid': cand.sdpMid,
          'sdpMLineIndex': cand.sdpMLineIndex,
        });
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        peer.remoteStream = event.streams[0];
        _peerController.add(peers.values.toList());
      }
    };

    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _removePeer(peerId);
      }
    };

    if (initiator) {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      _signaling?.sendOffer(peerId, offer.toMap());
    }
  }

  void _setupDataChannel(RemotePeer peer, RTCDataChannel dc) {
    peer.dc = dc;
    dc.onMessage = (msg) {
      try {
        if (msg.isBinary) {
          // File chunk binary
          final data = msg.binary;
          // First 36 bytes = fileId utf8? Simpler: json header via text, binary = raw chunk
          // For now treat binary as file chunk for last fileId (track via map)
          // We'll send fileId as text frame before binary chunks, so buffer tracking works via _fileExpected
          // Assume binary chunks belong to most recent file – in real mesh need fileId header
          _incomingFileController.add({'peerId': peer.id, 'data': data});
        } else {
          final map = jsonDecode(msg.text) as Map<String, dynamic>;
          final t = map['t'] as String?;
          if (t == 'chat') {
            _chatController.add(ChatMessage(
                from: peer.displayName,
                fromId: peer.id,
                text: map['text'] as String,
                ts: DateTime.now(),
                isMe: false));
          } else if (t == 'vibrate') {
            _vibrateController.add(peer.id);
          } else if (t == 'file_meta') {
            _fileMetaController.add(FileMeta(
                fileId: map['fileId'] as String,
                fileName: map['fileName'] as String,
                fileSize: map['fileSize'] as int,
                fromId: peer.id,
                fromName: peer.displayName));
          }
        }
      } catch (_) {}
    };
  }

  Future<void> _onOffer(
      String from, String name, Map<String, dynamic> sdp) async {
    var peer = peers[from];
    if (peer == null) {
      await _createPeer(from, name, initiator: false);
      peer = peers[from]!;
    }
    final pc = peer.pc!;
    await pc.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'] as String, sdp['type'] as String));
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    _signaling?.sendAnswer(from, answer.toMap());
  }

  Future<void> _onAnswer(String from, Map<String, dynamic> sdp) async {
    final peer = peers[from];
    if (peer?.pc == null) return;
    await peer!.pc!.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'] as String, sdp['type'] as String));
  }

  Future<void> _onIce(String from, Map<String, dynamic> cand) async {
    final peer = peers[from];
    if (peer?.pc == null) return;
    try {
      await peer!.pc!.addCandidate(RTCIceCandidate(cand['candidate'] as String,
          cand['sdpMid'] as String?, cand['sdpMLineIndex'] as int?));
    } catch (_) {}
  }

  Future<void> sendVibrate({String? to}) async {
    bool sent = false;
    for (final p in peers.values) {
      if (to != null && p.id != to) continue;
      if (p.dc != null &&
          p.dc!.state == RTCDataChannelState.RTCDataChannelOpen) {
        try {
          await p.dc!.send(RTCDataChannelMessage(jsonEncode({'t': 'vibrate'})));
          sent = true;
        } catch (_) {}
      }
    }
    if (!sent) {
      // Fallback via signaling
      try {
        _signaling?.sendVibrate(to: to);
      } catch (_) {}
      // If no specific peer, broadcast via signaling
      if (to == null) {
        for (final p in peers.values) {
          _vibrateController.add(p.id);
        }
      }
    }
  }

  Future<void> sendChat(String text) async {
    final msg = ChatMessage(
        from: displayName,
        fromId: selfId,
        text: text,
        ts: DateTime.now(),
        isMe: true);
    _chatController.add(msg);
    // Try DataChannel first, fallback to signaling relay
    bool sent = false;
    for (final p in peers.values) {
      if (p.dc != null &&
          p.dc!.state == RTCDataChannelState.RTCDataChannelOpen) {
        try {
          await p.dc!.send(
              RTCDataChannelMessage(jsonEncode({'t': 'chat', 'text': text})));
          sent = true;
        } catch (_) {}
      }
    }
    if (!sent) {
      _signaling?.sendChat(text);
    }
  }

  Future<void> sendFile(Uint8List bytes, String fileName) async {
    final fileId = DateTime.now().millisecondsSinceEpoch.toString();
    final meta = {
      't': 'file_meta',
      'fileId': fileId,
      'fileName': fileName,
      'fileSize': bytes.length
    };
    for (final p in peers.values) {
      if (p.dc != null &&
          p.dc!.state == RTCDataChannelState.RTCDataChannelOpen) {
        await p.dc!.send(RTCDataChannelMessage(jsonEncode(meta)));
        // Chunk 16KB
        const chunk = 16 * 1024;
        for (var i = 0; i < bytes.length; i += chunk) {
          final end = (i + chunk < bytes.length) ? i + chunk : bytes.length;
          await p.dc!
              .send(RTCDataChannelMessage.fromBinary(bytes.sublist(i, end)));
          await Future.delayed(const Duration(milliseconds: 5));
        }
      } else {
        _signaling?.sendFileMeta(fileName, bytes.length, fileId);
        // Fallback: send via signaling as base64 chunks (not ideal) – for now just meta via signaling
      }
    }
  }

  Future<void> toggleMic() async {
    _micEnabled = !_micEnabled;
    localStream?.getAudioTracks().forEach((t) => t.enabled = _micEnabled);
  }

  Future<void> toggleCam() async {
    _camEnabled = !_camEnabled;
    localStream?.getVideoTracks().forEach((t) => t.enabled = _camEnabled);
  }

  Future<void> switchCamera() async {
    final videoTrack = localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      try {
        await Helper.switchCamera(videoTrack);
      } catch (_) {}
    }
  }

  void _removePeer(String id) {
    final p = peers.remove(id);
    try {
      p?.pc?.close();
    } catch (_) {}
    try {
      p?.dc?.close();
    } catch (_) {}
    try {
      p?.remoteStream?.dispose();
    } catch (_) {}
    _peerController.add(peers.values.toList());
  }

  Future<void> leave() async {
    _signaling?.leave();
    for (final id in peers.keys.toList()) {
      _removePeer(id);
    }
    try {
      localStream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    try {
      await localStream?.dispose();
    } catch (_) {}
    localStream = null;
    await disconnectSignaling();
  }

  Future<void> disconnectSignaling() async {
    await _signaling?.disconnect();
    _signaling = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    _saveDebounceCleanup();
    await leave();
    await _peerController.close();
    await _chatController.close();
    await _fileMetaController.close();
    await _incomingFileController.close();
    await _vibrateController.close();
    _sigSub?.cancel();
  }

  void _saveDebounceCleanup() {}
}
