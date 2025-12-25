import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size, Rect, Offset;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/delivery_challan.dart';
import 'package:path/path.dart' as path;

/// Generates pixel-perfect Delivery Challan PDFs using manual positioning.
class PDFService {
  static final PDFService instance = PDFService._init();
  PDFService._init();

  /// Loads logo image from assets as PdfBitmap
  Future<PdfBitmap?> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load(
        'assets/images/prasanna_rmc_logo.png',
      );
      final List<int> imageBytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      return PdfBitmap(imageBytes);
    } catch (e) {
      // Logo file not found, return null
      return null;
    }
  }

  /// Loads template/form image from assets as PdfBitmap
  /// This image should contain the complete layout with all lines, labels, borders, etc.
  Future<PdfBitmap?> _loadTemplate() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/templete.jpg');
      final List<int> imageBytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      return PdfBitmap(imageBytes);
    } catch (e) {
      // Template file not found, return null
      return null;
    }
  }

  /// Generates 3 copies of the challan PDF (A5, portrait, no margins).
  /// Returns both file paths and PDF bytes for preview.
  Future<({List<String> paths, List<int> bytes})> generatePDF(
    DeliveryChallan challan,
  ) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = PdfPageSize.a5;
    // Set all page margins to 0
    document.pageSettings.margins.all = 0;
    final PdfPage page = document.pages.add();
    final PdfGraphics g = page.graphics;
    final Size size = page.getClientSize();

    // No margins - content starts at edge
    const double margin = 0;
    double y = margin;

    // Fonts
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final PdfFont bold9 = PdfStandardFont(
      PdfFontFamily.helvetica,
      9,
      style: PdfFontStyle.bold,
    );
    final PdfFont bold10 = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );
    final PdfFont underlined = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.underline,
    );
    final PdfFont headerBig = PdfStandardFont(
      PdfFontFamily.helvetica,
      18,
      style: PdfFontStyle.bold,
    );
    final PdfFont headerLarge = PdfStandardFont(
      PdfFontFamily.helvetica,
      24,
      style: PdfFontStyle.bold,
    );
    final PdfFont headerSmall = PdfStandardFont(
      PdfFontFamily.helvetica,
      13,
      style: PdfFontStyle.bold,
    );

    double centerX(String text, PdfFont font) =>
        (size.width - font.measureString(text).width) / 2;

    void drawText(String text, PdfFont font, double x, double yPos) {
      g.drawString(
        text,
        font,
        bounds: Rect.fromLTWH(x, yPos, size.width, font.height),
      );
    }

    // Helper function for template mode - draws text with a narrower bounding box for better alignment
    void drawTextOnTemplate(String text, PdfFont font, double x, double yPos) {
      // Use a reasonable width (300 points) instead of full page width for better alignment
      const double textWidth = 300.0;
      g.drawString(
        text,
        font,
        bounds: Rect.fromLTWH(x, yPos, textWidth, font.height),
      );
    }

    // Helper function to draw horizontal lines
    void drawHorizontalLine(double x, double y, double length) {
      final PdfPen linePen = PdfPen(PdfColor(0, 0, 0), width: 0.5);
      g.drawLine(linePen, Offset(x, y), Offset(x + length, y));
    }

    // Helper function to split text into multiple lines
    List<String> splitIntoLines(String text, int maxCharsPerLine) {
      if (text.length <= maxCharsPerLine) {
        return [text];
      }

      List<String> lines = [];
      int start = 0;
      while (start < text.length) {
        int end = (start + maxCharsPerLine < text.length)
            ? start + maxCharsPerLine
            : text.length;
        lines.add(text.substring(start, end));
        start = end;
      }
      return lines;
    }

    // ── CHECK FOR TEMPLATE MODE ──
    // Load template image (background with all layout, lines, labels, etc.)
    final PdfBitmap? templateImage = await _loadTemplate();

    // If template exists, use template-based approach
    if (templateImage != null) {
      // Draw template as background first (covers entire page)
      g.drawImage(templateImage, Rect.fromLTWH(0, 0, size.width, size.height));

      // ═══════════════════════════════════════════════════════════════
      // TEMPLATE MODE: Only draw dynamic values at specific coordinates
      // ═══════════════════════════════════════════════════════════════
      //
      // TO ADJUST ALIGNMENT:
      // 1. Generate a test PDF and see where values are positioned
      // 2. Adjust the X (horizontal) and Y (vertical) values below
      // 3. X increases from left to right, Y increases from top to bottom
      // 4. Small adjustments (5-10 points) usually work best
      //
      // ═══════════════════════════════════════════════════════════════
      // COORDINATE CONSTANTS - Adjust these to align with your template
      // ═══════════════════════════════════════════════════════════════

      // LEFT COLUMN - Customer Details
      const double leftColX = 30; // X position for left column
      const double toY1 = 90; // "To" field - Line 1
      const double toY2 = toY1 + 20; // "To" field - Line 2
      const double toY3 = toY2 + 20; // "To" field - Line 3
      const double refNameY = toY3 + 20; // "Ref. Name" field
      const double cellNoY = refNameY + 20; // "Cell No." field

      // RIGHT COLUMN - Date, Invoice, DC No.
      const double rightColX = 320; // X position for right column
      const double dateY = 100; // "Date" field
      const double invoiceNoY = dateY + 35; // "Invoice No." field
      const double dcNoY = invoiceNoY + 30; // "D.C. No." field

      // BODY SECTION
      const double gradeX = 320;
      const double gradeY = 210; // "Grade" field
      const double purchaseOrderX = 250;
      const double purchaseOrderY = 225; // "Purchase Order No." field

      // VEHICLE/DELIVERY INFO
      const double row1X = 20;
      const double row1Y = 300;
      const double vehicleX = 20;
      const double vehicleNumberY = 400; // "Vehicle Number" field
      const double timeOfRemovalY = 400; // "Time of Removal" field

      // DRIVER INFO
      const double driverX = 80;
      const double driverNameY = 440;
      // "Driver Name" field
      const double driverCellNoX = 190;
      const double driverCellNoY = 440; // "Driver Cell No." field

      // GATE & SITE DETAILS
      const double gateLeftX = 100;
      const double gateRightX = 220;
      const double tmGateOutY = 460; // "TM GATE OUT KMS" field
      const double tmGateInY = 480; // "TM GATE IN KMS" field
      const double siteInTimeY = 460; // "Site in Time" field
      const double siteOutTimeY = 480; // "Site Out Time" field

      // AMOUNT DETAILS
      const double amountX = 380;
      const double totalQtyY = 460; // "Total Qty." field
      const double amountY = 440; // "Amount" field
      const double sgstY = 460; // "SGST" field
      const double cgstY = 480; // "CGST" field
      const double grandTotalY = 500; // "Grand Total" field

      // FOOTER
      const double footerX = 50;
      const double footerDateY = 650; // Footer "Date" field
      const double footerInvoiceY = 665; // Footer "Invoice No." field
      const double footerDcNoY = 680; // Footer "D.C. No." field

      // ═══════════════════════════════════════════════════════════════
      // DRAW VALUES ON TEMPLATE
      // ═══════════════════════════════════════════════════════════════

      // Customer "To" field - 3 lines
      List<String> toLines = splitIntoLines(challan.to, 40);
      if (toLines.isNotEmpty)
        drawTextOnTemplate(toLines[0], bodyFont, leftColX, toY1);
      if (toLines.length > 1)
        drawTextOnTemplate(toLines[1], bodyFont, leftColX, toY2);
      if (toLines.length > 2)
        drawTextOnTemplate(toLines[2], bodyFont, leftColX, toY3);

      // Ref. Name
      drawTextOnTemplate(challan.refName, bodyFont, leftColX + 50, refNameY);

      // Cell No.
      drawTextOnTemplate(challan.cellNo, bodyFont, leftColX + 50, cellNoY);

      // Right column: Date, Invoice No., D.C. No.
      drawTextOnTemplate(challan.date, bodyFont, rightColX, dateY);
      drawTextOnTemplate(
        challan.invoiceNo,
        bodyFont,
        rightColX + 30,
        invoiceNoY,
      );
      drawTextOnTemplate(challan.dcNo, bodyFont, rightColX + 20, dcNoY);

      // Body text fields
      drawTextOnTemplate(challan.grade, bodyFont, gradeX, gradeY);
      drawTextOnTemplate(
        challan.purchaseOrderNo,
        bodyFont,
        purchaseOrderX,
        purchaseOrderY,
      );

      // Vehicle/Delivery info (from first item)
      // Draw first row
      if (challan.items.isNotEmpty) {
        drawTextOnTemplate(
          challan.items[0].vehicleNumber,
          bodyFont,
          row1X,
          row1Y,
        );
        drawTextOnTemplate(
          challan.items[0].timeOfRemoval,
          bodyFont,
          row1X + 80,
          row1Y,
        );
        drawTextOnTemplate(
          challan.items[0].gradeOfConcrete,
          bodyFont,
          row1X + 130,
          row1Y,
        );
        drawTextOnTemplate(
          challan.items[0].qtyInCubicMet,
          bodyFont,
          row1X + 180,
          row1Y,
        );
        drawTextOnTemplate(
          challan.items[0].totalQtyInCubicMet,
          bodyFont,
          row1X + 250,
          row1Y,
        );
        drawTextOnTemplate(challan.items[0].pump, bodyFont, row1X + 310, row1Y);
        drawTextOnTemplate(challan.items[0].dump, bodyFont, row1X + 350, row1Y);

        // Draw additional items, one row below for each
        double rowSpacing = 25; // Adjust as needed for your layout
        for (int i = 1; i < challan.items.length; i++) {
          double currentY = row1Y + i * rowSpacing;
          drawTextOnTemplate(
            challan.items[i].vehicleNumber,
            bodyFont,
            row1X,
            currentY,
          );
          drawTextOnTemplate(
            challan.items[i].timeOfRemoval,
            bodyFont,
            row1X + 80,
            currentY,
          );
          drawTextOnTemplate(
            challan.items[i].gradeOfConcrete,
            bodyFont,
            row1X + 130,
            currentY,
          );
          drawTextOnTemplate(
            challan.items[i].qtyInCubicMet,
            bodyFont,
            row1X + 180,
            currentY,
          );
          drawTextOnTemplate(
            challan.items[i].totalQtyInCubicMet,
            bodyFont,
            row1X + 250,
            currentY,
          );
          drawTextOnTemplate(
            challan.items[i].pump,
            bodyFont,
            row1X + 310,
            currentY,
          );
          drawTextOnTemplate(
            challan.items[i].dump,
            bodyFont,
            row1X + 350,
            currentY,
          );
        }
      }

      // Driver info
      drawTextOnTemplate(challan.driverName, bodyFont, driverX, driverNameY);
      drawTextOnTemplate(
        challan.driverCellNo,
        bodyFont,
        driverCellNoX,
        driverCellNoY,
      );

      // Gate & Site details
      drawTextOnTemplate(
        challan.tmGateOutKms,
        bodyFont,
        gateLeftX + 10,
        tmGateOutY,
      );
      drawTextOnTemplate(challan.tmGateInKms, bodyFont, gateLeftX, tmGateInY);
      drawTextOnTemplate(challan.siteInTime, bodyFont, gateRightX, siteInTimeY);
      drawTextOnTemplate(
        challan.siteOutTime,
        bodyFont,
        gateRightX,
        siteOutTimeY,
      );

      // Amount details
      double totalQty = 0;
      for (var item in challan.items) {
        final qty = double.tryParse(item.totalQtyInCubicMet) ?? 0;
        totalQty += qty;
      }
      String totalQtyStr = totalQty > 0 ? totalQty.toStringAsFixed(2) : '';

      drawTextOnTemplate(totalQtyStr, bodyFont, amountX, totalQtyY);
      drawTextOnTemplate(challan.amount, bodyFont, amountX, amountY);
      drawTextOnTemplate('${challan.sgst}%', bodyFont, amountX, sgstY);
      drawTextOnTemplate('${challan.cgst}%', bodyFont, amountX, cgstY);
      drawTextOnTemplate(challan.grandTotal, bodyFont, amountX, grandTotalY);

      // Footer fields
      drawTextOnTemplate(challan.date, bodyFont, footerX, footerDateY);
      drawTextOnTemplate(challan.invoiceNo, bodyFont, footerX, footerInvoiceY);
      drawTextOnTemplate(challan.dcNo, bodyFont, footerX, footerDcNoY);

      // Save and return the PDF
      final List<int> bytes = await document.save();
      document.dispose();

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String challanDir = path.join(
        appDocDir.path,
        'delivery_challan',
        'pdfs',
      );
      final Directory dir = Directory(challanDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String baseFileName = 'DC_${challan.dcNo}_$timestamp';

      final List<String> pdfPaths = [];
      for (int i = 1; i <= 3; i++) {
        final String filePath = path.join(
          challanDir,
          '${baseFileName}_copy$i.pdf',
        );
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        pdfPaths.add(filePath);
      }

      return (paths: pdfPaths, bytes: bytes);
    }

    // FALLBACK: Manual drawing mode (if template not found, use original code)

    // ── HEADER SECTION ──
    // Load logo
    final PdfBitmap? logo = await _loadLogo();

    // Header layout: Logo on left (30% width), Text on right (70% width)
    double logoAreaWidth = size.width * 0.30;
    double textAreaStartX = logoAreaWidth + 10;
    double textAreaWidth = size.width - textAreaStartX - margin;

    double headerStartY = y;

    // Left side: Logo with text below
    if (logo != null) {
      double logoSize = 60; // Logo height
      double logoWidth = 100; // Logo width
      double logoX = margin + 5;
      double logoY = y + 5;

      // Draw logo
      g.drawImage(logo, Rect.fromLTWH(logoX, logoY, logoWidth, logoSize));

      // // Draw "PRASANNA RMC" text below logo
      // double logoTextY = logoY + logoSize + 2;
      // drawText('PRASANNA RMC', bold9, logoX, logoTextY);
    } else {
      // If logo not found, just draw text
      drawText('PRASANNA RMC', bold9, margin + 5, y + 20);
    }

    // Right side: Text elements (centered within text area)
    double rightTextStartX = textAreaStartX + (textAreaWidth / 2);

    // "DELIVERY CHALLAN" at top (centered in right area)
    y += underlined.height + 2;
    double deliveryChallanX =
        rightTextStartX - (underlined.measureString('DELIVERY CHALLAN').width);
    drawText('DELIVERY CHALLAN', underlined, deliveryChallanX, y);
    y += headerSmall.height + 2;

    // "PRASANNA RMC" (centered in right area)
    double companyNameX =
        rightTextStartX - (headerBig.measureString('PRASANNA RMC').width);
    // Use the boldest/strongest font for 'PRASANNA RMC'
    drawText('PRASANNA RMC', headerLarge, companyNameX, y);
    y += headerLarge.height + 4;

    // "READY MIX CONCRETE" (centered in right area)
    double readyMixX =
        rightTextStartX - (bold10.measureString('READY MIX CONCRETE').width);
    drawText('READY MIX CONCRETE', bold10, readyMixX, y);
    y += bold10.height + 4;

    // Address (centered, two lines)
    String addressLine1 =
        'Srisailam Highway, Peddapur Vill., Veldanda Mdl.,Nagarkurnool - 509360.';
    double addr1X =
        rightTextStartX - (bodyFont.measureString(addressLine1).width * 0.7);
    drawText(addressLine1, bodyFont, addr1X, y);
    y += bodyFont.height + 2;

    // Set y to the bottom of header (logo area or text area, whichever is taller)
    double headerHeight = logo != null ? 100 : 70;
    y = headerStartY + headerHeight + 2;

    // Draw separator line after header
    final PdfPen separatorPen = PdfPen(PdfColor(0, 0, 0), width: 1.0);
    g.drawLine(separatorPen, Offset(margin, y), Offset(size.width - margin, y));
    y += 10;

    // ── CUSTOMER DETAIL SECTION (Two Columns) ──
    double leftColX = margin;
    double rightColX =
        size.width / 2 + 20; // Start right column at mid-point with some offset
    double lineStartOffset = 45; // Offset for lines after labels
    double lineLength = 200; // Length of blank lines

    double currentY = y;

    // LEFT COLUMN
    // "To" label with 3 horizontal lines
    drawText('To', bold9, leftColX, currentY);
    double toLineX = leftColX + lineStartOffset;
    double toLineY = currentY + bold9.height - 2;

    // Draw 3 lines for "To" field
    drawHorizontalLine(toLineX, toLineY, lineLength);
    drawHorizontalLine(toLineX, toLineY + bold9.height + 2, lineLength);
    drawHorizontalLine(toLineX, toLineY + (bold9.height + 2) * 2, lineLength);

    // Draw "To" value on top of first line (split into lines if needed)
    List<String> toLines = splitIntoLines(challan.to, 40);
    for (int i = 0; i < toLines.length && i < 3; i++) {
      drawText(toLines[i], bodyFont, toLineX, toLineY + i * (bold9.height + 2));
    }

    currentY += bold9.height + 6 + (bold9.height + 2) * 2; // Space for 3 lines

    // "Ref. Name" label with 1 horizontal line
    drawText('Ref. Name', bodyFont, leftColX, currentY);
    double refLineX = leftColX + lineStartOffset + 15;
    double refLineY = currentY + bodyFont.height - 2;
    drawHorizontalLine(refLineX, refLineY, lineLength - 15);
    drawText(challan.refName, bodyFont, refLineX, refLineY);
    currentY += bodyFont.height + 8;

    // "Cell No." label with 1 horizontal line
    drawText('Cell No.', bodyFont, leftColX, currentY);
    double cellLineX = leftColX + lineStartOffset;
    double cellLineY = currentY + bodyFont.height - 2;
    drawHorizontalLine(cellLineX, cellLineY, lineLength);
    drawText(challan.cellNo, bodyFont, cellLineX, cellLineY);

    // RIGHT COLUMN (aligned with left column's vertical position)
    currentY = y;
    double rightLabelWidth = 80; // Approximate width for right column labels
    double rightLineX = rightColX + rightLabelWidth;
    double rightLineLength = size.width - rightLineX - margin - 10;

    // "Date :" label with 1 horizontal line
    drawText('Date :', bodyFont, rightColX, currentY);
    double dateLineY = currentY + bodyFont.height - 2;
    drawHorizontalLine(rightLineX, dateLineY, rightLineLength);
    drawText(challan.date, bodyFont, rightLineX, dateLineY);
    currentY += bodyFont.height + 6;

    // "Invoice No. :" label with 1 horizontal line
    drawText('Invoice No. :', bodyFont, rightColX, currentY);
    double invoiceLineY = currentY + bodyFont.height - 2;
    drawHorizontalLine(rightLineX, invoiceLineY, rightLineLength);
    drawText(challan.invoiceNo, bodyFont, rightLineX, invoiceLineY);
    currentY += bodyFont.height + 6;

    // "D.C. No." label with 1 horizontal line
    drawText('D.C. No.', bodyFont, rightColX, currentY);
    double dcLineY = currentY + bodyFont.height - 2;
    drawHorizontalLine(rightLineX, dcLineY, rightLineLength);
    drawText(challan.dcNo, bodyFont, rightLineX, dcLineY);

    // Update y to continue after customer details (use left column's y position)
    y =
        y +
        bold9.height +
        6 +
        (bold9.height + 2) * 2 +
        bodyFont.height +
        8 +
        bodyFont.height +
        12;

    // ── BODY TEXT ──
    drawText('Dear Sir,', bodyFont, margin, y);
    y += bodyFont.height + 6;

    drawText('Sub : Supply of Ready Mix Concrete - Grade', bodyFont, margin, y);
    drawText(challan.grade, bodyFont, margin + 225, y);
    y += bodyFont.height + 6;

    drawText('Ref. : Your Purchase Order No. :', bodyFont, margin, y);
    drawText(challan.purchaseOrderNo, bodyFont, margin + 200, y);
    y += bodyFont.height + 6;

    drawText(
      'The Details of goods dispatched are as follows :',
      bodyFont,
      margin,
      y,
    );
    y += bodyFont.height + 10;

    // ── VEHICLE / DELIVERY INFO ──
    // Get first item's vehicle info if available
    String vehicleNumber = challan.items.isNotEmpty
        ? challan.items[0].vehicleNumber
        : '';
    String timeOfRemoval = challan.items.isNotEmpty
        ? challan.items[0].timeOfRemoval
        : '';
    String pumpDump = challan.items.isNotEmpty
        ? '${challan.items[0].pump} / ${challan.items[0].dump}'
        : '';

    drawText('Vehicle Number :', bodyFont, margin, y);
    drawText(vehicleNumber, bodyFont, margin + 95, y);
    y += bodyFont.height + 6;

    drawText('Time of Removal :', bodyFont, margin, y);
    drawText(timeOfRemoval, bodyFont, margin + 95, y);
    y += bodyFont.height + 6;

    drawText('Pump Dump :', bodyFont, margin, y);
    drawText(pumpDump, bodyFont, margin + 70, y);
    y += bodyFont.height + 12;

    // ── MATERIAL DETAILS ──
    drawText(
      'READY MIX CONCRETE',
      bold10,
      centerX('READY MIX CONCRETE', bold10),
      y,
    );
    y += bold10.height + 6;

    drawText('Grade of Concrete :', bodyFont, margin, y);
    drawText(challan.grade, bodyFont, margin + 105, y);
    y += bodyFont.height + 6;

    // Calculate total quantity from items
    double totalQty = 0;
    for (var item in challan.items) {
      final qty = double.tryParse(item.totalQtyInCubicMet) ?? 0;
      totalQty += qty;
    }
    String totalQtyStr = totalQty > 0 ? totalQty.toStringAsFixed(2) : '';

    drawText('Qty. in Cubic Met.', bodyFont, margin, y);
    drawText(totalQtyStr, bodyFont, margin + 95, y);
    y += bodyFont.height + 12;

    // ── RECEIVER & DRIVER SECTION ──
    drawText('Signature of the Receiver', bodyFont, margin, y);
    y += bodyFont.height + 4;
    drawText('Delivery', bodyFont, margin, y);
    y += bodyFont.height + 4;
    drawText('Seal', bodyFont, margin, y);

    // Right aligned driver info
    double rightX = size.width / 2 + 30;
    double yRight = y - (bodyFont.height + 4) * 2;
    drawText('Driver Name :', bodyFont, rightX, yRight);
    drawText(challan.driverName, bodyFont, rightX + 75, yRight);
    yRight += bodyFont.height + 6;
    drawText('Cell No.', bodyFont, rightX, yRight);
    drawText(challan.driverCellNo, bodyFont, rightX + 45, yRight);
    y += bodyFont.height + 16;

    // ── GATE & SITE DETAILS ──
    double colLeftX = margin;
    double colRightX = size.width / 2 + 10;
    double rowY = y;

    drawText('TM GATE OUT KMS :', bodyFont, colLeftX, rowY);
    drawText(challan.tmGateOutKms, bodyFont, colLeftX + 115, rowY);
    rowY += bodyFont.height + 8;

    drawText('TM GATE IN KMS :', bodyFont, colLeftX, rowY);
    drawText(challan.tmGateInKms, bodyFont, colLeftX + 110, rowY);

    rowY = y;
    drawText('Site in Time :', bodyFont, colRightX, rowY);
    drawText(challan.siteInTime, bodyFont, colRightX + 70, rowY);
    rowY += bodyFont.height + 8;

    drawText('Site Out Time :', bodyFont, colRightX, rowY);
    drawText(challan.siteOutTime, bodyFont, colRightX + 80, rowY);

    y += (bodyFont.height + 8) * 2 + 10;

    // ── CONFIRMATION ──
    drawText('Received the above items in good condition', bodyFont, margin, y);
    y += bodyFont.height + 12;

    // ── AMOUNT SUMMARY (right) ──
    double amtX = size.width / 2 + 50;
    double amtY = y;
    drawText('Total Qty. in Cubic Met.', bodyFont, amtX, amtY);
    drawText(totalQtyStr, bodyFont, amtX + 130, amtY);
    amtY += bodyFont.height + 6;
    drawText('Amount', bodyFont, amtX, amtY);
    drawText(challan.amount, bodyFont, amtX + 130, amtY);
    amtY += bodyFont.height + 6;
    drawText('SGST@ ${challan.sgst}%', bodyFont, amtX, amtY);
    amtY += bodyFont.height + 6;
    drawText('CGST@ ${challan.cgst}%', bodyFont, amtX, amtY);
    amtY += bodyFont.height + 6;
    drawText('Grand Total Rs.', bodyFont, amtX, amtY);
    drawText(challan.grandTotal, bodyFont, amtX + 130, amtY);
    y += (bodyFont.height + 6) * 5 + 10;

    // ── FOOTER ──
    double footerY = size.height - margin - (bodyFont.height * 3 + 12);
    drawText('Date :', bodyFont, margin, footerY);
    drawText(challan.date, bodyFont, margin + 30, footerY);
    footerY += bodyFont.height + 6;

    drawText('Invoice No. :', bodyFont, margin, footerY);
    drawText(challan.invoiceNo, bodyFont, margin + 65, footerY);
    footerY += bodyFont.height + 6;

    drawText('D.C. No.', bodyFont, margin, footerY);
    drawText(challan.dcNo, bodyFont, margin + 40, footerY);

    double footerRightY = size.height - margin - (bodyFont.height * 3 + 12);
    double footerRightX = size.width - margin - 140;
    drawText('For PRASANNA RMC', bodyFont, footerRightX, footerRightY);
    footerRightY += bodyFont.height + 24;
    drawText('Authorised Signature', bodyFont, footerRightX, footerRightY);

    // Save 3 copies
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String challanDir = path.join(
      appDocDir.path,
      'delivery_challan',
      'pdfs',
    );
    final Directory dir = Directory(challanDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String baseFileName = 'DC_${challan.dcNo}_$timestamp';

    final List<String> pdfPaths = [];
    final List<int> bytes = await document.save();
    document.dispose();

    for (int i = 1; i <= 3; i++) {
      final String filePath = path.join(
        challanDir,
        '${baseFileName}_copy$i.pdf',
      );
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      pdfPaths.add(filePath);
    }

    return (paths: pdfPaths, bytes: bytes);
  }

  Future<void> printPDF(String pdfPath) async {
    final file = File(pdfPath);
    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  /// Previews the PDF in-app without downloading.
  /// Uses the PDF bytes directly from memory.
  /// Shows a preview dialog that can be printed or shared.
  Future<void> previewPDF(List<int> pdfBytes) async {
    final bytes = Uint8List.fromList(pdfBytes);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }
}
