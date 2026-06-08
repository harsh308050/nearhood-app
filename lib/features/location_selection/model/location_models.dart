class LocationModel {
  final String? isoCode;
  final String? placeId;
  final String? name;
  final String? phonecode;
  final String? flag;
  final String? pincode;

  const LocationModel({
    this.isoCode,
    this.placeId,
    this.name,
    this.phonecode,
    this.flag,
    this.pincode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      isoCode: json['isoCode'],
      placeId: json['placeId'],
      name: json['name'] ?? json['description'],
      phonecode: json['phonecode'],
      flag: json['flag'],
      pincode: json['pincode'],
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
        other.pincode == pincode;
  }

  @override
  int get hashCode {
    return Object.hash(
      isoCode,
      placeId,
      name,
      phonecode,
      pincode,
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
