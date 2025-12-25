class DeliveryChallan {
  final int? id;
  final String to;
  final String date;
  final String invoiceNo;
  final String refName;
  final String cellNo;
  final String dcNo;
  final String grade;
  final String purchaseOrderNo;
  final List<ChallanItem> items;
  final String driverName;
  final String driverCellNo;
  final String amount;
  final String tmGateOutKms;
  final String siteInTime;
  final String sgst;
  final String tmGateInKms;
  final String siteOutTime;
  final String cgst;
  final String grandTotal;
  final String createdBy;
  final DateTime createdAt;
  final String? pdfPath1;
  final String? pdfPath2;
  final String? pdfPath3;

  DeliveryChallan({
    this.id,
    required this.to,
    required this.date,
    required this.invoiceNo,
    required this.refName,
    required this.cellNo,
    required this.dcNo,
    required this.grade,
    required this.purchaseOrderNo,
    required this.items,
    required this.driverName,
    required this.driverCellNo,
    required this.amount,
    required this.tmGateOutKms,
    required this.siteInTime,
    required this.sgst,
    required this.tmGateInKms,
    required this.siteOutTime,
    required this.cgst,
    required this.grandTotal,
    required this.createdBy,
    DateTime? createdAt,
    this.pdfPath1,
    this.pdfPath2,
    this.pdfPath3,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_to': to,
      'date': date,
      'invoiceNo': invoiceNo,
      'refName': refName,
      'cellNo': cellNo,
      'dcNo': dcNo,
      'grade': grade,
      'purchaseOrderNo': purchaseOrderNo,
      'items': items.map((item) => item.toMap()).toList().toString(),
      'driverName': driverName,
      'driverCellNo': driverCellNo,
      'amount': amount,
      'tmGateOutKms': tmGateOutKms,
      'siteInTime': siteInTime,
      'sgst': sgst,
      'tmGateInKms': tmGateInKms,
      'siteOutTime': siteOutTime,
      'cgst': cgst,
      'grandTotal': grandTotal,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'pdfPath1': pdfPath1,
      'pdfPath2': pdfPath2,
      'pdfPath3': pdfPath3,
    };
  }

  factory DeliveryChallan.fromMap(Map<String, dynamic> map) {
    return DeliveryChallan(
      id: map['id'],
      to: map['customer_to'] ?? '',
      date: map['date'] ?? '',
      invoiceNo: map['invoiceNo'] ?? '',
      refName: map['refName'] ?? '',
      cellNo: map['cellNo'] ?? '',
      dcNo: map['dcNo'] ?? '',
      grade: map['grade'] ?? '',
      purchaseOrderNo: map['purchaseOrderNo'] ?? '',
      items: [], // Parse from string if needed
      driverName: map['driverName'] ?? '',
      driverCellNo: map['driverCellNo'] ?? '',
      amount: map['amount'] ?? '',
      tmGateOutKms: map['tmGateOutKms'] ?? '',
      siteInTime: map['siteInTime'] ?? '',
      sgst: map['sgst'] ?? '',
      tmGateInKms: map['tmGateInKms'] ?? '',
      siteOutTime: map['siteOutTime'] ?? '',
      cgst: map['cgst'] ?? '',
      grandTotal: map['grandTotal'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      pdfPath1: map['pdfPath1'],
      pdfPath2: map['pdfPath2'],
      pdfPath3: map['pdfPath3'],
    );
  }

  DeliveryChallan copyWith({
    int? id,
    String? to,
    String? date,
    String? invoiceNo,
    String? refName,
    String? cellNo,
    String? dcNo,
    String? grade,
    String? purchaseOrderNo,
    List<ChallanItem>? items,
    String? driverName,
    String? driverCellNo,
    String? amount,
    String? tmGateOutKms,
    String? siteInTime,
    String? sgst,
    String? tmGateInKms,
    String? siteOutTime,
    String? cgst,
    String? grandTotal,
    String? createdBy,
    DateTime? createdAt,
    String? pdfPath1,
    String? pdfPath2,
    String? pdfPath3,
  }) {
    return DeliveryChallan(
      id: id ?? this.id,
      to: to ?? this.to,
      date: date ?? this.date,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      refName: refName ?? this.refName,
      cellNo: cellNo ?? this.cellNo,
      dcNo: dcNo ?? this.dcNo,
      grade: grade ?? this.grade,
      purchaseOrderNo: purchaseOrderNo ?? this.purchaseOrderNo,
      items: items ?? this.items,
      driverName: driverName ?? this.driverName,
      driverCellNo: driverCellNo ?? this.driverCellNo,
      amount: amount ?? this.amount,
      tmGateOutKms: tmGateOutKms ?? this.tmGateOutKms,
      siteInTime: siteInTime ?? this.siteInTime,
      sgst: sgst ?? this.sgst,
      tmGateInKms: tmGateInKms ?? this.tmGateInKms,
      siteOutTime: siteOutTime ?? this.siteOutTime,
      cgst: cgst ?? this.cgst,
      grandTotal: grandTotal ?? this.grandTotal,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      pdfPath1: pdfPath1 ?? this.pdfPath1,
      pdfPath2: pdfPath2 ?? this.pdfPath2,
      pdfPath3: pdfPath3 ?? this.pdfPath3,
    );
  }
}

class ChallanItem {
  final String vehicleNumber;
  final String timeOfRemoval;
  final String gradeOfConcrete;
  final String qtyInCubicMet;
  final String totalQtyInCubicMet;
  final String pump;
  final String dump;

  ChallanItem({
    required this.vehicleNumber,
    required this.timeOfRemoval,
    required this.gradeOfConcrete,
    required this.qtyInCubicMet,
    required this.totalQtyInCubicMet,
    required this.pump,
    required this.dump,
  });

  Map<String, dynamic> toMap() {
    return {
      'vehicleNumber': vehicleNumber,
      'timeOfRemoval': timeOfRemoval,
      'gradeOfConcrete': gradeOfConcrete,
      'qtyInCubicMet': qtyInCubicMet,
      'totalQtyInCubicMet': totalQtyInCubicMet,
      'pump': pump,
      'dump': dump,
    };
  }

  factory ChallanItem.fromMap(Map<String, dynamic> map) {
    return ChallanItem(
      vehicleNumber: map['vehicleNumber'] ?? '',
      timeOfRemoval: map['timeOfRemoval'] ?? '',
      gradeOfConcrete: map['gradeOfConcrete'] ?? '',
      qtyInCubicMet: map['qtyInCubicMet'] ?? '',
      totalQtyInCubicMet: map['totalQtyInCubicMet'] ?? '',
      pump: map['pump'] ?? '',
      dump: map['dump'] ?? '',
    );
  }
}
