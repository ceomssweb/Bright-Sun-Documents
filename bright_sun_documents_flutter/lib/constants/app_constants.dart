class AppConstants {
  AppConstants._();

  static const String appName = 'Bright Sun Documents';
  static const String appTagline = 'Professional Document Writing & Translation';
  static const String copyright = '\u00a9 2024 Bright Sun Documents. All rights reserved.';
  static const String adminEmail = 'saravanan039@hotmail.com';

  static const List<String> documentTypes = [
    'Sale Deed',
    'Gift Deed / Settlement',
    'Release Deed',
    'Exchange Deed',
    'Mortgage Deed',
    'Partition Deed',
    'Power of Attorney',
    'Rental / Lease Agreement',
    'Will Deed',
    'Trust Deed',
    'Affidavit',
    'Agreement of Sale',
    'General Power of Attorney (GPA)',
    'Promissory Note',
    'Relinquishment Deed',
    'Others',
  ];

  static const List<String> genders = ['Male', 'Female', 'Other'];

  static const List<String> relations = [
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Spouse',
    'Brother',
    'Sister',
    'Grand Son',
    'Grand Daughter',
    'Others',
  ];

  static const List<String> paymentStatuses = [
    'Paid',
    'Pending',
    'Partial',
    'Not Paid',
  ];

  static const List<String> documentStatuses = [
    'Ready for Processing',
    'In Progress',
    'Under Review',
    'Completed',
    'Delivered',
    'On Hold',
    'Cancelled',
  ];
}
