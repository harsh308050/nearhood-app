class ChatUser {
  final String id;
  final String fullName;
  final String? profilePhotoUrl;
  final bool isVerified;
  final String locality;
  final String? phoneNumber;
  final String? phoneCountryCode;

  ChatUser({
    required this.id,
    required this.fullName,
    this.profilePhotoUrl,
    this.isVerified = false,
    this.locality = '',
    this.phoneNumber,
    this.phoneCountryCode,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      isVerified: json['isVerified'] ?? false,
      locality: json['location']?['locality']?['name'] ?? json['locality'] ?? '',
      phoneNumber: json['phone']?['number'],
      phoneCountryCode: json['phone']?['countryCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'profilePhotoUrl': profilePhotoUrl,
      'isVerified': isVerified,
      'locality': locality,
      'phoneNumber': phoneNumber,
      'phoneCountryCode': phoneCountryCode,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
