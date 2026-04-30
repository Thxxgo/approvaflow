import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum RequestStatus { pendiente, aprobado, rechazado }

class Request {
  final String id;
  final String title;
  final String description;
  final RequestStatus status;
  final DateTime createdAt;
  final String solicitanteId;
  final String? comentario;

  Request({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.solicitanteId,
    this.comentario,
  });

  factory Request.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Request(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: RequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RequestStatus.pendiente,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      solicitanteId: data['solicitanteId'] ?? '',
      comentario: data['comentario'],
    );
  }
}

class RequestService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Crear nueva solicitud
  Future<void> createRequest({
    required String title,
    required String description,
  }) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('requests').add({
      'title': title,
      'description': description,
      'status': RequestStatus.pendiente.name,
      'solicitanteId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'comentario': null,
    });
  }

  // Solicitudes del solicitante actual
  Stream<List<Request>> getMyRequests() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('requests')
        .where('solicitanteId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Request.fromFirestore).toList());
  }

  // Todas las solicitudes pendientes (para el aprobador)
  Stream<List<Request>> getPendingRequests() {
    return _db
        .collection('requests')
        .where('status', isEqualTo: 'pendiente')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Request.fromFirestore).toList());
  }

  // Aprobar o rechazar
  Future<void> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
    required String comentario,
  }) async {
    await _db.collection('requests').doc(requestId).update({
      'status': status.name,
      'comentario': comentario,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtener una solicitud por ID
  Future<Request?> getRequestById(String id) async {
    final doc = await _db.collection('requests').doc(id).get();
    if (!doc.exists) return null;
    return Request.fromFirestore(doc);
  }
}
