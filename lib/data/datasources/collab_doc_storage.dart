import 'dart:convert';

import 'package:crdt_lf/crdt_lf.dart';

import 'local_storage.dart';

/// Local-first persistence for collaboration documents.
///
/// Stores each document's latest [Snapshot] as base64 in the `collabDocs`
/// Hive box, plus a stable per-install [PeerId] used as CRDT site identity.
/// Snapshots (not raw change logs) keep storage bounded and make cold boot
/// O(1): import one blob and the document is fully reconstructed offline.
class CollabDocStorage {
  CollabDocStorage._();

  static const String _peerIdKey = 'siteId';
  static String _snapKey(String docId) => 'snap_$docId';

  /// Stable per-install CRDT identity. Survives restarts so re-connecting
  /// peers recognise us; regenerated only if the box is cleared.
  static PeerId loadOrCreateSiteId() {
    final stored = LocalStorage.collabDocsBox.get(_peerIdKey);
    final id = stored != null ? PeerId.parse(stored) : PeerId.generate();
    if (stored == null) {
      LocalStorage.collabDocsBox.put(_peerIdKey, id.toString());
    }
    return id;
  }

  /// Loads the last saved snapshot for [docId], or `null` when the document
  /// has never been edited on this device (or its blob failed to decode).
  static Snapshot? loadSnapshot(String docId) {
    final b64 = LocalStorage.collabDocsBox.get(_snapKey(docId));
    if (b64 == null) return null;
    try {
      return Snapshot.fromBytes(base64Decode(b64));
    } catch (_) {
      // Corrupt legacy blob — start fresh rather than crash.
      return null;
    }
  }

  /// Persists [snapshot] for [docId]. Fire-and-forget friendly: failures are
  /// swallowed because losing one debounced snapshot must never crash the UI.
  static void saveSnapshot(String docId, Snapshot snapshot) {
    try {
      LocalStorage.collabDocsBox.put(
        _snapKey(docId),
        base64Encode(snapshot.toBytes()),
      );
    } catch (_) {}
  }
}
