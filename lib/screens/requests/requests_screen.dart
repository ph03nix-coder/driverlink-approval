import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driverlink_approval/providers/requests_provider.dart';
import 'package:driverlink_approval/config/theme.dart';
import 'package:driverlink_approval/models/request.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    return RefreshIndicator(
      child: Center(
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
      ),
      onRefresh: () => context.read<RequestsProvider>().loadRequests(),
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

  // Función para copiar la información del conductor al portapapeles
  Future<void> _copyDriverInfoToClipboard() async {
    final driverInfo = '''
Nombre: ${request.firstName} ${request.lastName}
Teléfono: ${request.phoneNumber}
Vehículo: ${request.vehicleType} - ${request.vehicleModel} (${request.vehicleYear})
Placa: ${request.vehiclePlate}
Solicitado: ${_formatDate(request.createdAt)}
Estado: ${_getStatusText(request.approvalStatus)}
    ''';
    
    await Clipboard.setData(ClipboardData(text: driverInfo));
    
    // Mostrar mensaje de confirmación
    Fluttertoast.showToast(
      msg: 'Información copiada al portapapeles',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

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
                Row(
                  children: [
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      color: AppTheme.primaryColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _copyDriverInfoToClipboard,
                      tooltip: 'Copiar información del conductor',
                    ),
                  ],
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
                            label: const Text('Licencia', overflow: TextOverflow.ellipsis),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
                            label: const Text('Identidad', overflow: TextOverflow.ellipsis),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent,
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
                      child: OutlinedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () => _approveRequest(context, provider), 
                        icon: const Icon(Icons.check),
                        label: const Text('Aprobar', overflow: TextOverflow.ellipsis),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
                          side: BorderSide(color: AppTheme.secondaryColor),
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
                        label: const Text('Rechazar', overflow: TextOverflow.ellipsis),
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

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondaryColor)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText, style: TextStyle(color: confirmColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Procesando...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _approveRequest(BuildContext context, RequestsProvider provider) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Confirmar Aprobación',
      content: '¿Estás seguro de que deseas aprobar la solicitud de ${request.firstName} ${request.lastName}?',
      confirmText: 'Aprobar',
      confirmColor: AppTheme.secondaryColor,
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (BuildContext context, _, __) => const PopScope(
            canPop: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      try {
        final success = await provider.approveRequest(request.id);
        // Remove loading dialog
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Solicitud de ${request.firstName} aprobada'),
                backgroundColor: AppTheme.secondaryColor,
              ),
            );
          }
        }
      } catch (e) {
        // Remove loading dialog in case of error
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocurrió un error al procesar la solicitud'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context, RequestsProvider provider) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Confirmar Rechazo',
      content: '¿Estás seguro de que deseas rechazar la solicitud de ${request.firstName} ${request.lastName}?',
      confirmText: 'Rechazar',
      confirmColor: AppTheme.errorColor,
    );

    if (confirmed == true && context.mounted) {
      // Show loading dialog
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (BuildContext context, _, __) => const PopScope(
            canPop: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      try {
        final success = await provider.rejectRequest(request.id);
        // Remove loading dialog
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Solicitud de ${request.firstName} rechazada'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        // Remove loading dialog in case of error
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocurrió un error al procesar la solicitud'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
