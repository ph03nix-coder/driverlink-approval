import 'dart:typed_data';
import 'package:driverlink_approval/config/theme.dart';
import 'package:driverlink_approval/services/document_service.dart';
import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatefulWidget {
  final int requestId;
  final String documentType; // 'license' or 'id'
  // ... (el resto de la clase no cambia)

  const DocumentViewerScreen({
    Key? key,
    required this.requestId,
    required this.documentType,
  }) : super(key: key);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  Uint8List? _documentBytes;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _documentInfo;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _documentBytes = null;
      _documentInfo = null;
    });

    try {
      // Cargar información del documento primero
      _documentInfo = await DocumentService.getDocumentInfo(
        widget.requestId,
        widget.documentType,
      );

      // Cargar el archivo como bytes
      if (widget.documentType == 'license') {
        _documentBytes =
            await DocumentService.getLicenseDocument(widget.requestId);
      } else if (widget.documentType == 'id') {
        _documentBytes = await DocumentService.getIdDocument(widget.requestId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getDocumentTitle()),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_documentBytes != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadDocument,
              tooltip: 'Descargar imagen',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getDocumentTitle() {
    switch (widget.documentType) {
      case 'license':
        return 'Documento de Licencia';
      case 'id':
        return 'Documento de Identidad';
      default:
        return 'Documento';
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
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
                'Error al cargar documento',
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadDocument,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_documentBytes == null || _documentBytes!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Documento no disponible',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'El documento solicitado no está disponible',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Información del documento
          if (_documentInfo != null) _buildDocumentInfo(),

          const SizedBox(height: 16),

          // Imagen del documento
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FullScreenImageViewer(imageBytes: _documentBytes!),
                ),
              );
            },
            child: Container(
              height: 400, // Altura máxima para la vista previa
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.textSecondaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _documentBytes!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al mostrar la imagen',
                            style: AppTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'El archivo podría estar corrupto o en un formato no soportado',
                            style: AppTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Información adicional
          _buildDocumentDetails(),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _downloadDocument,
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareDocument,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del documento',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            if (_documentInfo!['contentType'] != null)
              _buildInfoRow('Tipo', _documentInfo!['contentType']),
            if (_documentInfo!['contentLength'] != null)
              _buildInfoRow('Tamaño', _documentInfo!['contentLength']),
            if (_documentInfo!['lastModified'] != null)
              _buildInfoRow(
                  'Última modificación', _documentInfo!['lastModified']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'ID de solicitud: ${widget.requestId}',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tipo de documento: ${_getDocumentTitle()}',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tamaño del archivo: ${_formatFileSize(_documentBytes!.length)}',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _downloadDocument() async {
    if (_documentBytes == null) return;

    // try {
    //   final result = await ImageGallerySaver.saveImage(
    //     _documentBytes!,
    //     quality: 100,
    //     name: 'document_${widget.requestId}_${widget.documentType}',
    //   );

    //   if (mounted) {
    //     if (result['isSuccess']) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('Imagen guardada en la galería'),
    //           backgroundColor: AppTheme.secondaryColor,
    //         ),
    //       );
    //     } else {
    //       throw Exception('Failed to save image: ${result['errorMessage']}');
    //     }
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error al guardar la imagen: $e'),
    //         backgroundColor: AppTheme.errorColor,
    //       ),
    //     );
    //   }
    // }
  }

  void _shareDocument() {
    // TODO: Implementar compartir imagen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de compartir pendiente de implementar'),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;

  const FullScreenImageViewer({Key? key, required this.imageBytes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
