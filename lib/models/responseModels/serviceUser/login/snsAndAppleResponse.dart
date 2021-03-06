// To parse this JSON data, do
//
//     final snsAndAppleLogin = snsAndAppleLoginFromJson(jsonString);

import 'dart:convert';

SnsAndAppleLogin snsAndAppleLoginFromJson(String str) => SnsAndAppleLogin.fromJson(json.decode(str));

String snsAndAppleLoginToJson(SnsAndAppleLogin data) => json.encode(data.toJson());

class SnsAndAppleLogin {
  SnsAndAppleLogin({
    this.status,
    this.accessToken,
    this.data,
  });

  String status;
  String accessToken;
  Data data;

  factory SnsAndAppleLogin.fromJson(Map<String, dynamic> json) => SnsAndAppleLogin(
    status: json["status"],
    accessToken: json["accessToken"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "accessToken": accessToken,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.id,
    this.email,
    this.phoneNumber,
    this.firebaseUdid,
    this.fcmToken,
    this.lineBotUserId,
    this.appleUserId,
    this.userName,
    this.gender,
    this.dob,
    this.age,
    this.isTherapist,
    this.isVerified,
    this.isActive,
    this.userOccupation,
    this.uploadProfileImgUrl,
    this.userSearchRadiusDistance,
    this.addresses,
  });

  int id;
  String email;
  int phoneNumber;
  String firebaseUdid;
  String fcmToken;
  String lineBotUserId;
  String appleUserId;
  String userName;
  String gender;
  DateTime dob;
  int age;
  bool isTherapist;
  bool isVerified;
  bool isActive;
  String userOccupation;
  String uploadProfileImgUrl;
  dynamic userSearchRadiusDistance;
  List<Address> addresses;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    email: json["email"],
    phoneNumber: json["phoneNumber"],
    firebaseUdid: json["firebaseUDID"],
    fcmToken: json["fcmToken"],
    lineBotUserId: json["lineBotUserId"],
    appleUserId: json["appleUserId"],
    userName: json["userName"],
    gender: json["gender"],
    dob: DateTime.parse(json["dob"]),
    age: json["age"],
    isTherapist: json["isTherapist"],
    isVerified: json["isVerified"],
    isActive: json["isActive"],
    userOccupation: json["userOccupation"],
    uploadProfileImgUrl: json["uploadProfileImgUrl"],
    userSearchRadiusDistance: json["userSearchRadiusDistance"],
    addresses: List<Address>.from(json["addresses"].map((x) => Address.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "phoneNumber": phoneNumber,
    "firebaseUDID": firebaseUdid,
    "fcmToken": fcmToken,
    "lineBotUserId": lineBotUserId,
    "appleUserId": appleUserId,
    "userName": userName,
    "gender": gender,
    "dob": "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
    "age": age,
    "isTherapist": isTherapist,
    "isVerified": isVerified,
    "isActive": isActive,
    "userOccupation": userOccupation,
    "uploadProfileImgUrl": uploadProfileImgUrl,
    "userSearchRadiusDistance": userSearchRadiusDistance,
    "addresses": List<dynamic>.from(addresses.map((x) => x.toJson())),
  };
}

class Address {
  Address({
    this.id,
    this.userId,
    this.addressTypeSelection,
    this.address,
    this.userRoomNumber,
    this.userPlaceForMassage,
    this.otherAddressType,
    this.capitalAndPrefecture,
    this.capitalAndPrefectureId,
    this.cityName,
    this.citiesId,
    this.area,
    this.buildingName,
    this.postalCode,
    this.geomet,
    this.lat,
    this.lon,
    this.createdUser,
    this.updatedUser,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  int userId;
  String addressTypeSelection;
  String address;
  String userRoomNumber;
  String userPlaceForMassage;
  String otherAddressType;
  String capitalAndPrefecture;
  dynamic capitalAndPrefectureId;
  String cityName;
  dynamic citiesId;
  String area;
  String buildingName;
  dynamic postalCode;
  Geomet geomet;
  double lat;
  double lon;
  String createdUser;
  String updatedUser;
  bool isDefault;
  DateTime createdAt;
  DateTime updatedAt;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json["id"],
    userId: json["userId"],
    addressTypeSelection: json["addressTypeSelection"],
    address: json["address"],
    userRoomNumber: json["userRoomNumber"],
    userPlaceForMassage: json["userPlaceForMassage"],
    otherAddressType: json["otherAddressType"],
    capitalAndPrefecture: json["capitalAndPrefecture"],
    capitalAndPrefectureId: json["capitalAndPrefectureId"],
    cityName: json["cityName"],
    citiesId: json["citiesId"],
    area: json["area"],
    buildingName: json["buildingName"],
    postalCode: json["postalCode"],
    geomet: Geomet.fromJson(json["geomet"]),
    lat: json["lat"].toDouble(),
    lon: json["lon"].toDouble(),
    createdUser: json["createdUser"],
    updatedUser: json["updatedUser"],
    isDefault: json["isDefault"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "addressTypeSelection": addressTypeSelection,
    "address": address,
    "userRoomNumber": userRoomNumber,
    "userPlaceForMassage": userPlaceForMassage,
    "otherAddressType": otherAddressType,
    "capitalAndPrefecture": capitalAndPrefecture,
    "capitalAndPrefectureId": capitalAndPrefectureId,
    "cityName": cityName,
    "citiesId": citiesId,
    "area": area,
    "buildingName": buildingName,
    "postalCode": postalCode,
    "geomet": geomet.toJson(),
    "lat": lat,
    "lon": lon,
    "createdUser": createdUser,
    "updatedUser": updatedUser,
    "isDefault": isDefault,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class Geomet {
  Geomet({
    this.type,
    this.coordinates,
  });

  String type;
  List<double> coordinates;

  factory Geomet.fromJson(Map<String, dynamic> json) => Geomet(
    type: json["type"],
    coordinates: List<double>.from(json["coordinates"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}
