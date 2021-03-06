import 'dart:convert';

class AddUserSubAddress {
  var _userId;
  String _address;
  String _lat;
  String _lon;
  String _addressType;
  String _addressCategory;
  String _city;
  String _prefecture;
  String _roomNumber;
  String _buildingName;
  String _area;
  int cityID;
  int prefectureID;

  AddUserSubAddress(
      this._userId,
      this._address,
      this._lat,
      this._lon,
      this._addressType,
      this._addressCategory,
      this._city,
      this._prefecture,
      this._roomNumber,
      this._buildingName,
      this._area,
      {this.cityID,
      this.prefectureID});

  //userAddressAdd.fromAddress(this._lat, this._lng, this._addressType);

  String get subAddress => _address;

  String get lat => _lat;

  String get lon => _lon;

  String get addressType => _addressType;

  String get addressCategory => _addressCategory;

  String get city => _city;

  String get prefecture => _prefecture;

  String get roomNumber => _roomNumber;

  String get buildingName => _buildingName;

  String get area => _area;

  int get cityId => cityID;

  int get stateID => prefectureID;

  set subAddress(String subAddress) {
    this._address = subAddress;
  }

  set lat(String lat) {
    this._lat = lat;
  }

  set lon(String lon) {
    this._lon = lon;
  }

  set addressType(String addressType) {
    this._addressType = addressType;
  }

  set addressCategory(String addressCategory) {
    this._addressCategory = addressCategory;
  }

  set city(String city) {
    this._city = city;
  }

  set prefecture(String prefecture) {
    this._prefecture = prefecture;
  }

  set roomNumber(String roomNumber) {
    this._roomNumber = roomNumber;
  }

  set buildingName(String buildingName) {
    this._buildingName = buildingName;
  }

  set area(String area) {
    this._area = area;
  }

  AddUserSubAddress.fromJson(Map<String, dynamic> json) {
    //_addressKey = json['addressKey'];
    _userId = json['userId'];
    _address = json['subAddress'];
    _lat = json['lat'];
    lon = json['lon'];
    _addressType = json['addressTypeSelection'];
    _addressCategory = json['userPlaceForMassage'];
    _city = json['cityName'];
    _prefecture = json['capitalAndPrefecture'];
    _roomNumber = json['roomNumber'];
    _buildingName = json['buildingName'];
    _area = json['area'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this._userId;
    data['subAddress'] = this._address;
    data['lat'] = this._lat;
    data['lon'] = this.lon;
    data['addressTypeSelection'] = this._addressType;
    data['userPlaceForMassage'] = this._addressCategory;
    data['cityName'] = this._city;
    data['capitalAndPrefecture'] = this._prefecture;
    data['roomNumber'] = this._roomNumber;
    data['buildingName'] = this._buildingName;
    data['area'] = this._area;
    return data;
  }

  get userId => _userId;

  set userId(value) {
    _userId = value;
  }

  static String encode(List<AddUserSubAddress> subAddress) => json.encode(
        subAddress
            .map<Map<String, dynamic>>(
                (subAddress) => AddUserSubAddress.toMap(subAddress))
            .toList(),
      );

  static List<AddUserSubAddress> decode(String subAddress) =>
      (json.decode(subAddress) as List<dynamic>)
          .map<AddUserSubAddress>((item) => AddUserSubAddress.fromJson(item))
          .toList();

  static toMap(AddUserSubAddress subAddress) => {
        'userId': subAddress._userId,
        'subAddress': subAddress._address,
        'lat': subAddress._lat,
        'lon': subAddress.lon,
        'addressTypeSelection': subAddress._addressType,
        'userPlaceForMassage': subAddress._addressCategory,
        'cityName': subAddress._city,
        'capitalAndPrefecture': subAddress._prefecture,
        'roomNumber': subAddress._roomNumber,
        'buildingName': subAddress._buildingName,
        'area': subAddress._area
      };

  String get address => _address;

  set address(String value) {
    _address = value;
  }
}
