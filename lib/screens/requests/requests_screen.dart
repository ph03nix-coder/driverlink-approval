import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driverlink_approval/providers/requests_provider.dart';
import 'package:driverlink_approval/config/theme.dart';
import 'package:driverlink_approval/models/request.dart';
import 'package:driverlink_approval/screens/requests/document_viewer_screen.dart';
import 'package:driverlink_approval/api/auth/auth_service.dart';
import 'package:driverlink_approval/screens/auth/login_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar las solicitudes cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestsProvider>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Aprobación'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Menú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              onTap: () async {
                // Cerrar el drawer primero
                Navigator.pop(context);
                
                // Mostrar diálogo de confirmación
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  // Realizar el logout
                  await AuthService().logout();
                  
                  // Navegar a la pantalla de login y eliminar todas las rutas anteriores
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: Consumer<RequestsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider);
          }

          if (provider.requests.isEmpty) {
            return _buildEmptyWidget();
          }

          return _buildRequestsList(provider.requests);
        },
      ),
    );
  }

  Widget _buildErrorWidget(RequestsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar solicitudes',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadRequests();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes pendientes',
            style: AppTheme.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Todas las solicitudes han sido procesadas',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<Request> requests) {
    return RefreshIndicator(
      onRefresh: () => context.read<RequestsProvider>().loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return RequestCard(request: requests[index]);
        },
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final Request request;

  const RequestCard({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del conductor
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    request.firstName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.firstName} ${request.lastName}',
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.phoneNumber,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.approvalStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(request.approvalStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información del vehículo
            _buildInfoRow(
              icon: Icons.directions_car,
              label: 'Vehículo',
              value:
                  '${request.vehicleType} - ${request.vehicleModel} (${request.vehicleYear})',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.confirmation_number,
              label: 'Placa',
              value: request.vehiclePlate,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Solicitado',
              value: _formatDate(request.createdAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Última ubicación',
              value:
                  '${request.currentLatitude?.toStringAsFixed(4) ?? 'N/A'}, ${request.currentLongitude?.toStringAsFixed(4) ?? 'N/A'}',
            ),

            const SizedBox(height: 16),

            // Documentos
            if (request.licenseDocument != null || request.idDocument != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documentos',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (request.licenseDocument != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DocumentViewerScreen(
                                    requestId: request.userId,
                                    documentType: 'license',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.assignment),
                            label: const Text('Licencia'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      if (request.licenseDocument != null &&
                          request.idDocument != null)
                        const SizedBox(width: 8),
                      if (request.idDocument != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DocumentViewerScreen(
                                    requestId: request.userId,
                                    documentType: 'id',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person),
                            label: const Text('Identidad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Botones de acción
            Consumer<RequestsProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () => _approveRequest(context, provider),
                        icon: const Icon(Icons.check),
                        label: const Text('Aprobar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () => _rejectRequest(context, provider),
                        icon: const Icon(Icons.close),
                        label: const Text('Rechazar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: BorderSide(color: AppTheme.errorColor),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.accentColor;
      case 'approved':
        return AppTheme.secondaryColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'approved':
        return 'Aprobado';
      case 'rejected':
        return 'Rechazado';
      default:
        return status;
    }
  }

  void _approveRequest(BuildContext context, RequestsProvider provider) async {
    final success = await provider.approveRequest(request.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud de ${request.firstName} aprobada'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  void _rejectRequest(BuildContext context, RequestsProvider provider) async {
    final success = await provider.rejectRequest(request.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud de ${request.firstName} rechazada'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
