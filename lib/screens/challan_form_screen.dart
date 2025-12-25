import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/delivery_challan.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../services/whatsapp_service.dart';
import 'login_screen.dart';

class ChallanFormScreen extends StatefulWidget {
  const ChallanFormScreen({super.key});

  @override
  State<ChallanFormScreen> createState() => _ChallanFormScreenState();
}

class _ChallanFormScreenState extends State<ChallanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isGenerating = false;
  List<int>? _currentPdfBytes; // Store PDF bytes for preview

  // Form controllers
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _invoiceNoController = TextEditingController();
  final _refNameController = TextEditingController();
  final _cellNoController = TextEditingController();
  final _dcNoController = TextEditingController();
  final _gradeController = TextEditingController();
  final _purchaseOrderNoController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverCellNoController = TextEditingController();
  final _amountController = TextEditingController();
  final _tmGateOutKmsController = TextEditingController();
  final _siteInTimeController = TextEditingController();
  final _sgstController = TextEditingController();
  final _tmGateInKmsController = TextEditingController();
  final _siteOutTimeController = TextEditingController();
  final _cgstController = TextEditingController();
  final _grandTotalController = TextEditingController();

  // Table item controllers
  List<ChallanItemControllers> _itemControllers = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _addNewItem();
  }

  @override
  void dispose() {
    _toController.dispose();
    _dateController.dispose();
    _invoiceNoController.dispose();
    _refNameController.dispose();
    _cellNoController.dispose();
    _dcNoController.dispose();
    _gradeController.dispose();
    _purchaseOrderNoController.dispose();
    _driverNameController.dispose();
    _driverCellNoController.dispose();
    _amountController.dispose();
    _tmGateOutKmsController.dispose();
    _siteInTimeController.dispose();
    _sgstController.dispose();
    _tmGateInKmsController.dispose();
    _siteOutTimeController.dispose();
    _cgstController.dispose();
    _grandTotalController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _itemControllers.add(ChallanItemControllers());
    });
  }

  void _removeItem(int index) {
    if (_itemControllers.length > 1) {
      setState(() {
        _itemControllers[index].dispose();
        _itemControllers.removeAt(index);
      });
    }
  }

  Future<void> _generatePDF() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isGenerating = true);

      try {
        // Create challan object
        final challan = DeliveryChallan(
          to: _toController.text,
          date: _dateController.text,
          invoiceNo: _invoiceNoController.text,
          refName: _refNameController.text,
          cellNo: _cellNoController.text,
          dcNo: _dcNoController.text,
          grade: _gradeController.text,
          purchaseOrderNo: _purchaseOrderNoController.text,
          items: _itemControllers.map((c) => c.toChallanItem()).toList(),
          driverName: _driverNameController.text,
          driverCellNo: _driverCellNoController.text,
          amount: _amountController.text,
          tmGateOutKms: _tmGateOutKmsController.text,
          siteInTime: _siteInTimeController.text,
          sgst: _sgstController.text,
          tmGateInKms: _tmGateInKmsController.text,
          siteOutTime: _siteOutTimeController.text,
          cgst: _cgstController.text,
          grandTotal: _grandTotalController.text,
          createdBy: AuthService.instance.currentUser?.username ?? 'Unknown',
        );

        // Generate 3 PDF copies
        final result = await PDFService.instance.generatePDF(challan);
        final pdfPaths = result.paths;
        _currentPdfBytes = result.bytes; // Store bytes for preview

        // Save to database with PDF paths
        final savedChallan = challan.copyWith(
          pdfPath1: pdfPaths[0],
          pdfPath2: pdfPaths[1],
          pdfPath3: pdfPaths[2],
        );
        await DatabaseService.instance.createChallan(savedChallan);

        setState(() => _isGenerating = false);

        if (mounted) {
          // Show success dialog with options
          _showSuccessDialog(pdfPaths, challan);
        }
      } catch (e) {
        setState(() => _isGenerating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating PDF: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSuccessDialog(List<String> pdfPaths, DeliveryChallan challan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✅ 3 PDF copies have been generated and saved.'),
            const SizedBox(height: 16),
            Text(
              'DC No: ${challan.dcNo}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'What would you like to do?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Click "Preview PDF" to view in-app\n'
              '• Click "Open PDF" to view/download\n'
              '• Click "Print" to print directly\n'
              '• Click "Send to WhatsApp" to share',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            const Text('PDF files saved at:', style: TextStyle(fontSize: 11)),
            ...pdfPaths.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  'Copy ${entry.key + 1}: ${entry.value}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _previewPDF();
            },
            child: const Text('Preview PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendToWhatsApp(challan, pdfPaths[0]);
            },
            child: const Text('Send to WhatsApp'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              _openPDFLocation(pdfPaths[0]);
            },
            child: const Text('Open PDF'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await PDFService.instance.printPDF(pdfPaths[0]);
            },
            child: const Text('Print'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            child: const Text('New Challan'),
          ),
        ],
      ),
    );
  }

  void _previewPDF() async {
    if (_currentPdfBytes != null) {
      try {
        await PDFService.instance.previewPDF(_currentPdfBytes!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error previewing PDF: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF not available for preview'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _openPDFLocation(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (await file.exists()) {
        // Open the PDF file with default application
        final uri = Uri.file(pdfPath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // If can't open file directly, open the folder
          final directory = file.parent.path;
          final dirUri = Uri.file(directory);
          await launchUrl(dirUri);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF opened successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _sendToWhatsApp(DeliveryChallan challan, String pdfPath) async {
    if (challan.cellNo.isNotEmpty) {
      final message = WhatsAppService.instance.formatChallanMessage(
        challan.dcNo,
        challan.date,
        challan.to,
      );

      final success = await WhatsAppService.instance.sendPDF(
        challan.cellNo,
        pdfPath,
        message,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'WhatsApp opened. Please attach the PDF manually from:\n$pdfPath'
                  : 'Failed to open WhatsApp',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cell number is required for WhatsApp'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _toController.clear();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _invoiceNoController.clear();
    _refNameController.clear();
    _cellNoController.clear();
    _dcNoController.clear();
    _gradeController.clear();
    _purchaseOrderNoController.clear();
    _driverNameController.clear();
    _driverCellNoController.clear();
    _amountController.clear();
    _tmGateOutKmsController.clear();
    _siteInTimeController.clear();
    _sgstController.clear();
    _tmGateInKmsController.clear();
    _siteOutTimeController.clear();
    _cgstController.clear();
    _grandTotalController.clear();
    _currentPdfBytes = null; // Clear stored PDF bytes

    for (var controller in _itemControllers) {
      controller.dispose();
    }
    _itemControllers.clear();
    _addNewItem();
    setState(() {});
  }

  void _logout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Challan'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'User: ${AuthService.instance.currentUser?.fullName ?? ""}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Logo
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/prasanna_rmc_logo.png',
                        width: 150,
                        height: 75,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_shipping,
                            size: 48,
                            color: Colors.blue,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRASANNA RMC',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'READY MIX CONCRETE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Srisailam Highway, Peddapur Vill., Veldanda Mdl., Nagarkurnool - 509360',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Top Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _toController,
                              decoration: const InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  _dateController.text = DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(date);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _invoiceNoController,
                              decoration: const InputDecoration(
                                labelText: 'Invoice No.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _dcNoController,
                              decoration: const InputDecoration(
                                labelText: 'D.C. No.',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _refNameController,
                              decoration: const InputDecoration(
                                labelText: 'Ref Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cellNoController,
                              decoration: const InputDecoration(
                                labelText: 'Cell No.',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _gradeController,
                              decoration: const InputDecoration(
                                labelText: 'Grade of Concrete',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _purchaseOrderNoController,
                              decoration: const InputDecoration(
                                labelText: 'Purchase Order No.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Table Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Goods Dispatched',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addNewItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Row'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          border: TableBorder.all(),
                          columns: const [
                            DataColumn(label: Text('Vehicle\nNumber')),
                            DataColumn(label: Text('Time of\nRemoval')),
                            DataColumn(label: Text('Grade of\nConcrete')),
                            DataColumn(label: Text('Qty in\nCubic Met')),
                            DataColumn(label: Text('Total Qty in\nCubic Met')),
                            DataColumn(label: Text('Pump')),
                            DataColumn(label: Text('Dump')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _itemControllers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final controller = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(
                                  _buildTableField(controller.vehicleNumber),
                                ),
                                DataCell(
                                  _buildTableField(controller.timeOfRemoval),
                                ),
                                DataCell(
                                  _buildTableField(controller.gradeOfConcrete),
                                ),
                                DataCell(
                                  _buildTableField(controller.qtyInCubicMet),
                                ),
                                DataCell(
                                  _buildTableField(
                                    controller.totalQtyInCubicMet,
                                  ),
                                ),
                                DataCell(_buildTableField(controller.pump)),
                                DataCell(_buildTableField(controller.dump)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _driverNameController,
                              decoration: const InputDecoration(
                                labelText: 'Driver Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _driverCellNoController,
                              decoration: const InputDecoration(
                                labelText: 'Driver Cell No.',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tmGateOutKmsController,
                              decoration: const InputDecoration(
                                labelText: 'TM GATE OUT KMS',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _siteInTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Site in Time',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _sgstController,
                              decoration: const InputDecoration(
                                labelText: 'SGST %',
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tmGateInKmsController,
                              decoration: const InputDecoration(
                                labelText: 'TM GATE IN KMS',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _siteOutTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Site Out Time',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cgstController,
                              decoration: const InputDecoration(
                                labelText: 'CGST %',
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(flex: 2, child: SizedBox()),
                          Expanded(
                            child: TextFormField(
                              controller: _grandTotalController,
                              decoration: const InputDecoration(
                                labelText: 'Grand Total Rs.',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Generate PDF Button
              Center(
                child: SizedBox(
                  width: 300,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePDF,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf, size: 28),
                    label: Text(
                      _isGenerating
                          ? 'Generating...'
                          : 'GENERATE PDF (3 Copies)',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableField(TextEditingController controller) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8),
        ),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class ChallanItemControllers {
  final vehicleNumber = TextEditingController();
  final timeOfRemoval = TextEditingController();
  final gradeOfConcrete = TextEditingController();
  final qtyInCubicMet = TextEditingController();
  final totalQtyInCubicMet = TextEditingController();
  final pump = TextEditingController();
  final dump = TextEditingController();

  ChallanItem toChallanItem() {
    return ChallanItem(
      vehicleNumber: vehicleNumber.text,
      timeOfRemoval: timeOfRemoval.text,
      gradeOfConcrete: gradeOfConcrete.text,
      qtyInCubicMet: qtyInCubicMet.text,
      totalQtyInCubicMet: totalQtyInCubicMet.text,
      pump: pump.text,
      dump: dump.text,
    );
  }

  void dispose() {
    vehicleNumber.dispose();
    timeOfRemoval.dispose();
    gradeOfConcrete.dispose();
    qtyInCubicMet.dispose();
    totalQtyInCubicMet.dispose();
    pump.dispose();
    dump.dispose();
  }
}
