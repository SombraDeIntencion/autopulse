import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'admin' | 'technician' | 'manager'
  final String workshopId;
  final String language;
  final String subscriptionTier; // 'basic' | 'professional' | 'enterprise'
  final DateTime? subscriptionExpiresAt;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'technician',
    required this.workshopId,
    this.language = 'es',
    this.subscriptionTier = 'basic',
    this.subscriptionExpiresAt,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'technician',
      workshopId: data['workshopId'] ?? '',
      language: data['language'] ?? 'es',
      subscriptionTier: data['subscriptionTier'] ?? 'basic',
      subscriptionExpiresAt: data['subscriptionExpiresAt'] != null
          ? (data['subscriptionExpiresAt'] as Timestamp).toDate()
          : null,
      emailVerified: data['emailVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'workshopId': workshopId,
      'language': language,
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiresAt': subscriptionExpiresAt != null
          ? Timestamp.fromDate(subscriptionExpiresAt!)
          : null,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    String? workshopId,
    String? language,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      workshopId: workshopId ?? this.workshopId,
      language: language ?? this.language,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check subscription status
  bool get hasActiveSubscription {
    if (subscriptionExpiresAt == null) return false;
    return DateTime.now().isBefore(subscriptionExpiresAt!);
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Check if user is manager
  bool get isManager => role == 'manager';

  // Check if user is technician
  bool get isTechnician => role == 'technician';
}
