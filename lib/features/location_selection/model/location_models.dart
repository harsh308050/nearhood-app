class LocationModel {
  final String? isoCode;
  final String? placeId;
  final String? name;
  final String? phonecode;
  final String? flag;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const LocationModel({
    this.isoCode,
    this.placeId,
    this.name,
    this.phonecode,
    this.flag,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      isoCode: json['isoCode'],
      placeId: json['placeId'],
      name: json['name'] ?? json['description'],
      phonecode: json['phonecode'],
      flag: json['flag'],
      pincode: json['pincode'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.isoCode == isoCode &&
        other.placeId == placeId &&
        other.name == name &&
        other.phonecode == phonecode &&
        other.pincode == pincode &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      isoCode,
      placeId,
      name,
      phonecode,
      pincode,
      latitude,
      longitude,
    );
  }

  @override
  String toString() {
    if (flag != null && name != null) {
      return '$flag $name';
    }
    return name ?? '';
  }
}
