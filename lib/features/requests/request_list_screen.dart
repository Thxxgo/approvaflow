import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_colors.dart';

// Modelo simple de solicitud (por ahora sin Firebase)
class Request {
  final String id;
  final String title;
  final String description;
  final RequestStatus status;
  final DateTime createdAt;

  Request({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

enum RequestStatus { pendiente, aprobado, rechazado }

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  final List<Request> _requests = [
    Request(
      id: '1',
      title: 'Orden de compra #41',
      description: 'Compra de materiales de oficina',
      status: RequestStatus.aprobado,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Request(
      id: '2',
      title: 'Solicitud de viaje',
      description: 'Tiquetes para reunión en Bogotá',
      status: RequestStatus.pendiente,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Request(
      id: '3',
      title: 'Informe mensual',
      description: 'Informe de ventas marzo 2025',
      status: RequestStatus.rechazado,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis solicitudes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Hola, Carlos',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes solicitudes aún',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return _RequestCard(request: request);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/requests/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva solicitud'),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Request request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícono de estado
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor(request.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _statusIcon(request.status),
                color: _statusColor(request.status),
              ),
            ),
            const SizedBox(width: 14),

            // Título y descripción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Badge de estado
            _StatusBadge(status: request.status),
          ],
        ),
      ),
    );
  }

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.aprobado:
        return AppColors.approved;
      case RequestStatus.rechazado:
        return AppColors.rejected;
      case RequestStatus.pendiente:
        return AppColors.pending;
    }
  }

  IconData _statusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.aprobado:
        return Icons.check_circle_outline;
      case RequestStatus.rechazado:
        return Icons.cancel_outlined;
      case RequestStatus.pendiente:
        return Icons.hourglass_empty_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final RequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RequestStatus.aprobado => 'Aprobado',
      RequestStatus.rechazado => 'Rechazado',
      RequestStatus.pendiente => 'Pendiente',
    };

    final color = switch (status) {
      RequestStatus.aprobado => AppColors.approved,
      RequestStatus.rechazado => AppColors.rejected,
      RequestStatus.pendiente => AppColors.pending,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
