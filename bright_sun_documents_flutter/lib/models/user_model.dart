class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final bool emailVerified;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoURL = '',
    this.emailVerified = false,
    this.role = 'staff',
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'emailVerified': emailVerified,
        'role': role,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        email: map['email'] ?? '',
        displayName: map['displayName'] ?? '',
        photoURL: map['photoURL'] ?? '',
        emailVerified: map['emailVerified'] ?? false,
        role: map['role'] ?? 'staff',
        createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      );

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? role,
    DateTime? createdAt,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoURL: photoURL ?? this.photoURL,
        emailVerified: emailVerified ?? this.emailVerified,
        role: role ?? this.role,
        createdAt: createdAt ?? this.createdAt,
      );
}
