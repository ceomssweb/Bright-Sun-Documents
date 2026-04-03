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
  String currentOwnergender;
  String selectBuyerRelation;
  String buyerName;
  String buyerAddress;
  String buyerAge;
  String selectedBuyGender;
  List<String> originalNames;
  String paymentStatus;
  String finalDocStatus;

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
    required this.currentOwnergender,
    required this.selectBuyerRelation,
    required this.buyerName,
    required this.buyerAddress,
    required this.buyerAge,
    required this.selectedBuyGender,
    this.originalNames = const [],
    this.paymentStatus = '',
    this.finalDocStatus = 'Ready for Processing',
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'fatherName': fatherName,
      'email': email,
      'mobileNumber': mobileNumber,
      'selectedDoc': selectedDoc,
      'currentOwnerName': currentOwnerName,
      'currentOwnerAddress': currentOwnerAddress,
      'currentOwnerAge': currentOwnerAge,
      'currentOwnergender': currentOwnergender,
      'selectBuyerRelation': selectBuyerRelation,
      'buyerName': buyerName,
      'buyerAddress': buyerAddress,
      'buyerAge': buyerAge,
      'selectedBuyGender': selectedBuyGender,
      'originalNames': originalNames,
      'paymentStatus': paymentStatus,
      'finalDocStatus': finalDocStatus,
    };
  }

  factory ClientUser.fromMap(Map<dynamic, dynamic> map, {String? key}) {
    return ClientUser(
      key: key,
      fullName: map['fullName']?.toString() ?? '',
      fatherName: map['fatherName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      mobileNumber: map['mobileNumber']?.toString() ?? '',
      selectedDoc: map['selectedDoc']?.toString() ?? '',
      currentOwnerName: map['currentOwnerName']?.toString() ?? '',
      currentOwnerAddress: map['currentOwnerAddress']?.toString() ?? '',
      currentOwnerAge: map['currentOwnerAge']?.toString() ?? '',
      currentOwnergender: map['currentOwnergender']?.toString() ?? '',
      selectBuyerRelation: map['selectBuyerRelation']?.toString() ?? '',
      buyerName: map['buyerName']?.toString() ?? '',
      buyerAddress: map['buyerAddress']?.toString() ?? '',
      buyerAge: map['buyerAge']?.toString() ?? '',
      selectedBuyGender: map['selectedBuyGender']?.toString() ?? '',
      originalNames: (map['originalNames'] is List)
          ? List<String>.from(map['originalNames'])
          : [],
      paymentStatus: map['paymentStatus']?.toString() ?? '',
      finalDocStatus: map['finalDocStatus']?.toString() ?? 'Ready for Processing',
    );
  }
}
