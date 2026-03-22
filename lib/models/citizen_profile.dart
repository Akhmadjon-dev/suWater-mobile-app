class CitizenProfile {
  final String id;
  final String userId;
  final String? fullName;
  final String? homeNumber;
  final String? meterNumber;
  final String? abonentNumber;
  final String? installedDate;
  final String? meterPhotoUrl;
  final String? region;
  final String? district;
  final String? address;

  CitizenProfile({
    required this.id,
    required this.userId,
    this.fullName,
    this.homeNumber,
    this.meterNumber,
    this.abonentNumber,
    this.installedDate,
    this.meterPhotoUrl,
    this.region,
    this.district,
    this.address,
  });

  factory CitizenProfile.fromJson(Map<String, dynamic> json) {
    return CitizenProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      homeNumber: json['home_number'] as String?,
      meterNumber: json['meter_number'] as String?,
      abonentNumber: json['abonent_number'] as String?,
      installedDate: json['installed_date'] as String?,
      meterPhotoUrl: json['meter_photo_url'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      address: json['address'] as String?,
    );
  }
}
