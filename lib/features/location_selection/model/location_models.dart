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
    if (other is! LocationModel) return false;
    
    if (placeId != null && other.placeId != null) {
      return placeId == other.placeId;
    }
    if (isoCode != null && other.isoCode != null) {
      return isoCode == other.isoCode;
    }
    return name?.toLowerCase() == other.name?.toLowerCase();
  }

  @override
  int get hashCode {
    if (placeId != null) return placeId.hashCode;
    if (isoCode != null) return isoCode.hashCode;
    return name?.toLowerCase().hashCode ?? 0;
  }

  @override
  String toString() {
    if (flag != null && name != null) {
      return '$flag $name';
    }
    return name ?? '';
  }
}
