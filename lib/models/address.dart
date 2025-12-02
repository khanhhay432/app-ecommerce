class Address {
  final int id;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String district;
  final String ward;
  final bool isDefault;

  Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.district,
    required this.ward,
    this.isDefault = false,
  });

  String get fullAddress => '$address, $ward, $district, $city';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['streetAddress'] ?? json['address'] ?? '',
      city: json['province'] ?? json['city'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      isDefault: json['isDefault'] ?? json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'district': district,
      'ward': ward,
      'isDefault': isDefault,
    };
  }
}
