class ClientUser {
  String? key;
  String fullName;
  String fatherName;
  String email;
  String mobileNumber;
  String selectedDoc;
  String currentOwnerName;
  String currentOwnerAddress;
  String currentOwnerAge;
  String currentOwnerGender;
  String selectBuyerRelation;
  String buyerName;
  String buyerAddress;
  String buyerAge;
  String selectedBuyGender;
  List<String> originalNames;
  String paymentStatus;
  String finalDocStatus;
  String notes;
  String createdAt;
  String updatedAt;

  ClientUser({
    this.key,
    required this.fullName,
    required this.fatherName,
    required this.email,
    required this.mobileNumber,
    required this.selectedDoc,
    required this.currentOwnerName,
    required this.currentOwnerAddress,
    required this.currentOwnerAge,
    required this.currentOwnerGender,
    required this.selectBuyerRelation,
    required this.buyerName,
    required this.buyerAddress,
    required this.buyerAge,
    required this.selectedBuyGender,
    this.originalNames = const [],
    this.paymentStatus = '',
    this.finalDocStatus = 'Ready for Processing',
    this.notes = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'fatherName': fatherName,
        'email': email,
        'mobileNumber': mobileNumber,
        'selectedDoc': selectedDoc,
        'currentOwnerName': currentOwnerName,
        'currentOwnerAddress': currentOwnerAddress,
        'currentOwnerAge': currentOwnerAge,
        'currentOwnerGender': currentOwnerGender,
        'selectBuyerRelation': selectBuyerRelation,
        'buyerName': buyerName,
        'buyerAddress': buyerAddress,
        'buyerAge': buyerAge,
        'selectedBuyGender': selectedBuyGender,
        'originalNames': originalNames,
        'paymentStatus': paymentStatus,
        'finalDocStatus': finalDocStatus,
        'notes': notes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory ClientUser.fromMap(Map<dynamic, dynamic> map, {String? key}) => ClientUser(
        key: key,
        fullName: map['fullName']?.toString() ?? '',
        fatherName: map['fatherName']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        mobileNumber: map['mobileNumber']?.toString() ?? '',
        selectedDoc: map['selectedDoc']?.toString() ?? '',
        currentOwnerName: map['currentOwnerName']?.toString() ?? '',
        currentOwnerAddress: map['currentOwnerAddress']?.toString() ?? '',
        currentOwnerAge: map['currentOwnerAge']?.toString() ?? '',
        currentOwnerGender: map['currentOwnerGender']?.toString() ?? map['currentOwnergender']?.toString() ?? '',
        selectBuyerRelation: map['selectBuyerRelation']?.toString() ?? '',
        buyerName: map['buyerName']?.toString() ?? '',
        buyerAddress: map['buyerAddress']?.toString() ?? '',
        buyerAge: map['buyerAge']?.toString() ?? '',
        selectedBuyGender: map['selectedBuyGender']?.toString() ?? '',
        originalNames: (map['originalNames'] is List) ? List<String>.from(map['originalNames']) : [],
        paymentStatus: map['paymentStatus']?.toString() ?? '',
        finalDocStatus: map['finalDocStatus']?.toString() ?? 'Ready for Processing',
        notes: map['notes']?.toString() ?? '',
        createdAt: map['createdAt']?.toString() ?? '',
        updatedAt: map['updatedAt']?.toString() ?? '',
      );

  ClientUser copyWith({
    String? key,
    String? fullName,
    String? fatherName,
    String? email,
    String? mobileNumber,
    String? selectedDoc,
    String? currentOwnerName,
    String? currentOwnerAddress,
    String? currentOwnerAge,
    String? currentOwnerGender,
    String? selectBuyerRelation,
    String? buyerName,
    String? buyerAddress,
    String? buyerAge,
    String? selectedBuyGender,
    List<String>? originalNames,
    String? paymentStatus,
    String? finalDocStatus,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) =>
      ClientUser(
        key: key ?? this.key,
        fullName: fullName ?? this.fullName,
        fatherName: fatherName ?? this.fatherName,
        email: email ?? this.email,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        selectedDoc: selectedDoc ?? this.selectedDoc,
        currentOwnerName: currentOwnerName ?? this.currentOwnerName,
        currentOwnerAddress: currentOwnerAddress ?? this.currentOwnerAddress,
        currentOwnerAge: currentOwnerAge ?? this.currentOwnerAge,
        currentOwnerGender: currentOwnerGender ?? this.currentOwnerGender,
        selectBuyerRelation: selectBuyerRelation ?? this.selectBuyerRelation,
        buyerName: buyerName ?? this.buyerName,
        buyerAddress: buyerAddress ?? this.buyerAddress,
        buyerAge: buyerAge ?? this.buyerAge,
        selectedBuyGender: selectedBuyGender ?? this.selectedBuyGender,
        originalNames: originalNames ?? this.originalNames,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        finalDocStatus: finalDocStatus ?? this.finalDocStatus,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
