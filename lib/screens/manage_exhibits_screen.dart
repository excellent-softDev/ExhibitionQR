import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import '../models/exhibit.dart';
import '../services/exhibit_service.dart';

class ManageExhibitsScreen extends StatefulWidget {
  const ManageExhibitsScreen({super.key});

  @override
  State<ManageExhibitsScreen> createState() => _ManageExhibitsScreenState();
}

class _ManageExhibitsScreenState extends State<ManageExhibitsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _qrCodeController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<Exhibit> _exhibits = [];

  @override
  void initState() {
    super.initState();
    _loadExhibits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _qrCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadExhibits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exhibitService = Provider.of<ExhibitService>(context, listen: false);
      final exhibits = await exhibitService.getAllExhibits();

      setState(() {
        _exhibits = exhibits;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createExhibit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final exhibitService = Provider.of<ExhibitService>(context, listen: false);

      final exhibit = await exhibitService.createExhibit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        qrCode: _qrCodeController.text.trim().isEmpty ? null : _qrCodeController.text.trim(),
      );

      setState(() {
        _exhibits.insert(0, exhibit);
      });

      // Clear form
      _nameController.clear();
      _descriptionController.clear();
      _qrCodeController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibit created successfully.')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildForm() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create New Exhibit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exhibit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter an exhibit name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qrCodeController,
                decoration: const InputDecoration(
                  labelText: 'QR Code Text (optional)',
                  helperText: 'Leave empty to generate a unique code automatically.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : _createExhibit,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create Exhibit'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExhibitCard(Exhibit exhibit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.museum, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exhibit.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(exhibit);
                    } else if (value == 'delete') {
                      _showDeleteDialog(exhibit);
                    } else if (value == 'download') {
                      _showDownloadOptions(exhibit);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 8),
                          Text('Download'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(exhibit.description),
            const SizedBox(height: 8),
            Text('QR Code: ${exhibit.qrCode}'),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: QrImageView(
                  data: exhibit.qrCode,
                  size: 140,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Exhibit exhibit) {
    final nameController = TextEditingController(text: exhibit.name);
    final descriptionController = TextEditingController(text: exhibit.description);
    final qrCodeController = TextEditingController(text: exhibit.qrCode);

    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Exhibit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exhibit Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qrCodeController,
                  decoration: const InputDecoration(
                    labelText: 'QR Code Text',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty ||
                          descriptionController.text.trim().isEmpty ||
                          qrCodeController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All fields are required')),
                        );
                        return;
                      }

                      setState(() => isUpdating = true);

                      try {
                        final exhibitService = Provider.of<ExhibitService>(context, listen: false);

                        final updatedExhibit = Exhibit(
                          id: exhibit.id,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          qrCode: qrCodeController.text.trim(),
                          createdAt: exhibit.createdAt,
                        );

                        await exhibitService.updateExhibit(updatedExhibit);

                        final index = _exhibits.indexWhere((e) => e.id == exhibit.id);
                        if (index != -1) {
                          setState(() {
                            _exhibits[index] = updatedExhibit;
                          });
                        }

                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exhibit updated successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating exhibit: $e')),
                        );
                      } finally {
                        setState(() => isUpdating = false);
                      }
                    },
              child: isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Exhibit exhibit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exhibit'),
        content: Text('Are you sure you want to delete "${exhibit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final exhibitService = Provider.of<ExhibitService>(context, listen: false);
                await exhibitService.deleteExhibit(exhibit.id);

                setState(() {
                  _exhibits.removeWhere((e) => e.id == exhibit.id);
                });

                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exhibit deleted successfully')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting exhibit: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDownloadOptions(Exhibit exhibit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Exhibit'),
        content: const Text('Choose format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAsImage(exhibit, 'png');
            },
            child: const Text('PNG'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAsImage(exhibit, 'jpeg');
            },
            child: const Text('JPEG'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAsPDF(exhibit);
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAsImage(Exhibit exhibit, String format) async {
    try {
      // Generate QR code image
      final qrPainter = QrPainter(
        data: exhibit.qrCode,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xff000000),
        emptyColor: const Color(0xffffffff),
      );

      final picData = await qrPainter.toImageData(200);
      final imageBytes = picData?.buffer.asUint8List();

      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate image')),
        );
        return;
      }

      final filename = '${exhibit.name.replaceAll(' ', '_')}_QR.$format';
      _downloadFile(imageBytes, filename);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded as $format')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image: $e')),
      );
    }
  }

  Future<void> _downloadAsPDF(Exhibit exhibit) async {
    try {
      final pdf = pw.Document();

      // Generate QR code image
      final qrPainter = QrPainter(
        data: exhibit.qrCode,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xff000000),
        emptyColor: const Color(0xffffffff),
      );

      final picData = await qrPainter.toImageData(300);
      final imageBytes = picData?.buffer.asUint8List();

      if (imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate QR code')),
        );
        return;
      }

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  exhibit.name,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(exhibit.description),
                pw.SizedBox(height: 30),
                pw.Text(
                  'QR Code:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Image(pw.MemoryImage(imageBytes), width: 300, height: 300),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Code: ${exhibit.qrCode}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final filename = '${exhibit.name.replaceAll(' ', '_')}_QR.pdf';
      _downloadFile(Uint8List.fromList(pdfBytes), filename);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded as PDF')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }

  void _downloadFile(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Exhibits'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadExhibits,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildForm(),
              const SizedBox(height: 12),
              const Text(
                'Existing Exhibits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_exhibits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No exhibits found. Create one to start tracking visits.'),
                )
              else
                ..._exhibits.map(_buildExhibitCard),
            ],
          ),
        ),
      ),
    );
  }
}
