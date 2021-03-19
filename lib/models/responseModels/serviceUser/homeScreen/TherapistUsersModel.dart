class TherapistUsersModel {
  String status;
  TherapistData therapistData;

  TherapistUsersModel({this.status, this.therapistData});

  TherapistUsersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    therapistData = json['therapistData'] != null
        ? new TherapistData.fromJson(json['therapistData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.therapistData != null) {
      data['therapistData'] = this.therapistData.toJson();
    }
    return data;
  }
}

class TherapistData {
  int count;
  List<TherapistUserList> therapistUserList;
  int totalPages;
  int pageNumber;

  TherapistData(
      {this.count, this.therapistUserList, this.totalPages, this.pageNumber});

  TherapistData.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['therapistUserList'] != null) {
      therapistUserList = new List<TherapistUserList>();
      json['therapistUserList'].forEach((v) {
        therapistUserList.add(new TherapistUserList.fromJson(v));
      });
    }
    totalPages = json['totalPages'];
    pageNumber = json['pageNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.therapistUserList != null) {
      data['therapistUserList'] =
          this.therapistUserList.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = this.totalPages;
    data['pageNumber'] = this.pageNumber;
    return data;
  }
}

class TherapistUserList {
  int id;
  int userId;
  int orteopathicId;
  String name;
  int sixtyMin;
  int nintyMin;
  int oneTwentyMin;
  int oneFifityMin;
  int oneEightyMin;
  String createdAt;
  String updatedAt;
  User user;
  int fitnessId;
  int estheticId;
  int relaxationId;

  TherapistUserList(
      {this.id,
        this.userId,
        this.orteopathicId,
        this.name,
        this.sixtyMin,
        this.nintyMin,
        this.oneTwentyMin,
        this.oneFifityMin,
        this.oneEightyMin,
        this.createdAt,
        this.updatedAt,
        this.user,
        this.fitnessId,
        this.estheticId,
        this.relaxationId});

  TherapistUserList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    orteopathicId = json['orteopathicId'];
    name = json['name'];
    sixtyMin = json['sixtyMin'];
    nintyMin = json['nintyMin'];
    oneTwentyMin = json['oneTwentyMin'];
    oneFifityMin = json['oneFifityMin'];
    oneEightyMin = json['oneEightyMin'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    fitnessId = json['fitnessId'];
    estheticId = json['estheticId'];
    relaxationId = json['relaxationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['orteopathicId'] = this.orteopathicId;
    data['name'] = this.name;
    data['sixtyMin'] = this.sixtyMin;
    data['nintyMin'] = this.nintyMin;
    data['oneTwentyMin'] = this.oneTwentyMin;
    data['oneFifityMin'] = this.oneFifityMin;
    data['oneEightyMin'] = this.oneEightyMin;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user.toJson();
    }
    data['fitnessId'] = this.fitnessId;
    data['estheticId'] = this.estheticId;
    data['relaxationId'] = this.relaxationId;
    return data;
  }
}

class User {
  int id;
  String userId;
  String email;
  int phoneNumber;
  dynamic fcmToken;
  dynamic lineBotUserId;
  dynamic appleUserId;
  String userName;
  String dob;
  int age;
  String gender;
  bool isTherapist;
  bool isVerified;
  bool isActive;
  int isAccepted;
  String rejectReason;
  String updatedUser;
  String uploadProfileImgUrl;
  String proofOfIdentityType;
  String proofOfIdentityImgUrl;
  String qulaificationCertImgUrl;
  String businessForm;
  int numberOfEmp;
  bool businessTrip;
  bool coronaMeasure;
  String storeName;
  String storeType;
  int storePhone;
  dynamic storeDescription;
  dynamic userOccupation;
  String genderOfService;
  String childrenMeasure;
  dynamic customerId;
  String createdAt;
  String updatedAt;
  List<Addresses> addresses;
  List<CertificationUploads> certificationUploads;
  List<BankDetails> bankDetails;
  List<Banners> banners;

  User(
      {this.id,
        this.userId,
        this.email,
        this.phoneNumber,
        this.fcmToken,
        this.lineBotUserId,
        this.appleUserId,
        this.userName,
        this.dob,
        this.age,
        this.gender,
        this.isTherapist,
        this.isVerified,
        this.isActive,
        this.isAccepted,
        this.rejectReason,
        this.updatedUser,
        this.uploadProfileImgUrl,
        this.proofOfIdentityType,
        this.proofOfIdentityImgUrl,
        this.qulaificationCertImgUrl,
        this.businessForm,
        this.numberOfEmp,
        this.businessTrip,
        this.coronaMeasure,
        this.storeName,
        this.storeType,
        this.storePhone,
        this.storeDescription,
        this.userOccupation,
        this.genderOfService,
        this.childrenMeasure,
        this.customerId,
        this.createdAt,
        this.updatedAt,
        this.addresses,
        this.certificationUploads,
        this.bankDetails,
        this.banners});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    fcmToken = json['fcmToken'];
    lineBotUserId = json['lineBotUserId'];
    appleUserId = json['appleUserId'];
    userName = json['userName'];
    dob = json['dob'];
    age = json['age'];
    gender = json['gender'];
    isTherapist = json['isTherapist'];
    isVerified = json['isVerified'];
    isActive = json['isActive'];
    isAccepted = json['isAccepted'];
    rejectReason = json['rejectReason'];
    updatedUser = json['updatedUser'];
    uploadProfileImgUrl = json['uploadProfileImgUrl'];
    proofOfIdentityType = json['proofOfIdentityType'];
    proofOfIdentityImgUrl = json['proofOfIdentityImgUrl'];
    qulaificationCertImgUrl = json['qulaificationCertImgUrl'];
    businessForm = json['businessForm'];
    numberOfEmp = json['numberOfEmp'];
    businessTrip = json['businessTrip'];
    coronaMeasure = json['coronaMeasure'];
    storeName = json['storeName'];
    storeType = json['storeType'];
    storePhone = json['storePhone'];
    storeDescription = json['storeDescription'];
    userOccupation = json['userOccupation'];
    genderOfService = json['genderOfService'];
    childrenMeasure = json['childrenMeasure'];
    customerId = json['customerId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['addresses'] != null) {
      addresses = new List<Addresses>();
      json['addresses'].forEach((v) {
        addresses.add(new Addresses.fromJson(v));
      });
    }
    if (json['certification_uploads'] != null) {
      certificationUploads = new List<CertificationUploads>();
      json['certification_uploads'].forEach((v) {
        certificationUploads.add(new CertificationUploads.fromJson(v));
      });
    }
    if (json['bankDetails'] != null) {
      bankDetails = new List<BankDetails>();
      json['bankDetails'].forEach((v) {
        bankDetails.add(new BankDetails.fromJson(v));
      });
    }
    if (json['banners'] != null) {
      banners = new List<Banners>();
      json['banners'].forEach((v) {
        banners.add(new Banners.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['fcmToken'] = this.fcmToken;
    data['lineBotUserId'] = this.lineBotUserId;
    data['appleUserId'] = this.appleUserId;
    data['userName'] = this.userName;
    data['dob'] = this.dob;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['isTherapist'] = this.isTherapist;
    data['isVerified'] = this.isVerified;
    data['isActive'] = this.isActive;
    data['isAccepted'] = this.isAccepted;
    data['rejectReason'] = this.rejectReason;
    data['updatedUser'] = this.updatedUser;
    data['uploadProfileImgUrl'] = this.uploadProfileImgUrl;
    data['proofOfIdentityType'] = this.proofOfIdentityType;
    data['proofOfIdentityImgUrl'] = this.proofOfIdentityImgUrl;
    data['qulaificationCertImgUrl'] = this.qulaificationCertImgUrl;
    data['businessForm'] = this.businessForm;
    data['numberOfEmp'] = this.numberOfEmp;
    data['businessTrip'] = this.businessTrip;
    data['coronaMeasure'] = this.coronaMeasure;
    data['storeName'] = this.storeName;
    data['storeType'] = this.storeType;
    data['storePhone'] = this.storePhone;
    data['storeDescription'] = this.storeDescription;
    data['userOccupation'] = this.userOccupation;
    data['genderOfService'] = this.genderOfService;
    data['childrenMeasure'] = this.childrenMeasure;
    data['customerId'] = this.customerId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.addresses != null) {
      data['addresses'] = this.addresses.map((v) => v.toJson()).toList();
    }
    if (this.certificationUploads != null) {
      data['certification_uploads'] =
          this.certificationUploads.map((v) => v.toJson()).toList();
    }
    if (this.bankDetails != null) {
      data['bankDetails'] = this.bankDetails.map((v) => v.toJson()).toList();
    }
    if (this.banners != null) {
      data['banners'] = this.banners.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Addresses {
  int id;
  int userId;
  String addressTypeSelection;
  String address;
  String userRoomNumber;
  dynamic userPlaceForMassage;
  dynamic otherAddressType;
  String capitalAndPrefecture;
  dynamic capitalAndPrefectureId;
  String cityName;
  dynamic citiesId;
  String area;
  String buildingName;
  dynamic postalCode;
  double lat;
  double lon;
  dynamic userSearchRadiusDistance;
  String createdUser;
  String updatedUser;
  bool isDefault;
  String createdAt;
  String updatedAt;

  Addresses(
      {this.id,
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
        this.lat,
        this.lon,
        this.userSearchRadiusDistance,
        this.createdUser,
        this.updatedUser,
        this.isDefault,
        this.createdAt,
        this.updatedAt});

  Addresses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    addressTypeSelection = json['addressTypeSelection'];
    address = json['address'];
    userRoomNumber = json['userRoomNumber'];
    userPlaceForMassage = json['userPlaceForMassage'];
    otherAddressType = json['otherAddressType'];
    capitalAndPrefecture = json['capitalAndPrefecture'];
    capitalAndPrefectureId = json['capitalAndPrefectureId'];
    cityName = json['cityName'];
    citiesId = json['citiesId'];
    area = json['area'];
    buildingName = json['buildingName'];
    postalCode = json['postalCode'];
    lat = json['lat'];
    lon = json['lon'];
    userSearchRadiusDistance = json['userSearchRadiusDistance'];
    createdUser = json['createdUser'];
    updatedUser = json['updatedUser'];
    isDefault = json['isDefault'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['addressTypeSelection'] = this.addressTypeSelection;
    data['address'] = this.address;
    data['userRoomNumber'] = this.userRoomNumber;
    data['userPlaceForMassage'] = this.userPlaceForMassage;
    data['otherAddressType'] = this.otherAddressType;
    data['capitalAndPrefecture'] = this.capitalAndPrefecture;
    data['capitalAndPrefectureId'] = this.capitalAndPrefectureId;
    data['cityName'] = this.cityName;
    data['citiesId'] = this.citiesId;
    data['area'] = this.area;
    data['buildingName'] = this.buildingName;
    data['postalCode'] = this.postalCode;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['userSearchRadiusDistance'] = this.userSearchRadiusDistance;
    data['createdUser'] = this.createdUser;
    data['updatedUser'] = this.updatedUser;
    data['isDefault'] = this.isDefault;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class CertificationUploads {
  int id;
  int userId;
  String acupuncturist;
  String moxibutionist;
  String acupuncturistAndMoxibustion;
  String anmaMassageShiatsushi;
  String judoRehabilitationTeacher;
  String physicalTherapist;
  String acquireNationalQualifications;
  String privateQualification1;
  String privateQualification2;
  String privateQualification3;
  String privateQualification4;
  String privateQualification5;
  String createdAt;
  String updatedAt;

  CertificationUploads(
      {this.id,
        this.userId,
        this.acupuncturist,
        this.moxibutionist,
        this.acupuncturistAndMoxibustion,
        this.anmaMassageShiatsushi,
        this.judoRehabilitationTeacher,
        this.physicalTherapist,
        this.acquireNationalQualifications,
        this.privateQualification1,
        this.privateQualification2,
        this.privateQualification3,
        this.privateQualification4,
        this.privateQualification5,
        this.createdAt,
        this.updatedAt});

  CertificationUploads.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    acupuncturist = json['acupuncturist'];
    moxibutionist = json['moxibutionist'];
    acupuncturistAndMoxibustion = json['acupuncturistAndMoxibustion'];
    anmaMassageShiatsushi = json['anmaMassageShiatsushi'];
    judoRehabilitationTeacher = json['judoRehabilitationTeacher'];
    physicalTherapist = json['physicalTherapist'];
    acquireNationalQualifications = json['acquireNationalQualifications'];
    privateQualification1 = json['privateQualification1'];
    privateQualification2 = json['privateQualification2'];
    privateQualification3 = json['privateQualification3'];
    privateQualification4 = json['privateQualification4'];
    privateQualification5 = json['privateQualification5'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['acupuncturist'] = this.acupuncturist;
    data['moxibutionist'] = this.moxibutionist;
    data['acupuncturistAndMoxibustion'] = this.acupuncturistAndMoxibustion;
    data['anmaMassageShiatsushi'] = this.anmaMassageShiatsushi;
    data['judoRehabilitationTeacher'] = this.judoRehabilitationTeacher;
    data['physicalTherapist'] = this.physicalTherapist;
    data['acquireNationalQualifications'] = this.acquireNationalQualifications;
    data['privateQualification1'] = this.privateQualification1;
    data['privateQualification2'] = this.privateQualification2;
    data['privateQualification3'] = this.privateQualification3;
    data['privateQualification4'] = this.privateQualification4;
    data['privateQualification5'] = this.privateQualification5;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class BankDetails {
  int id;
  int userId;
  String bankName;
  String branchCode;
  String branchNumber;
  String accountNumber;
  String accountType;
  String createdAt;
  String updatedAt;

  BankDetails(
      {this.id,
        this.userId,
        this.bankName,
        this.branchCode,
        this.branchNumber,
        this.accountNumber,
        this.accountType,
        this.createdAt,
        this.updatedAt});

  BankDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    bankName = json['bankName'];
    branchCode = json['branchCode'];
    branchNumber = json['branchNumber'];
    accountNumber = json['accountNumber'];
    accountType = json['accountType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['bankName'] = this.bankName;
    data['branchCode'] = this.branchCode;
    data['branchNumber'] = this.branchNumber;
    data['accountNumber'] = this.accountNumber;
    data['accountType'] = this.accountType;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Banners {
  int id;
  int userId;
  String bannerImageUrl1;
  String bannerImageUrl2;
  String bannerImageUrl3;
  String bannerImageUrl4;
  String bannerImageUrl5;
  String createdAt;
  String updatedAt;

  Banners(
      {this.id,
        this.userId,
        this.bannerImageUrl1,
        this.bannerImageUrl2,
        this.bannerImageUrl3,
        this.bannerImageUrl4,
        this.bannerImageUrl5,
        this.createdAt,
        this.updatedAt});

  Banners.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    bannerImageUrl1 = json['bannerImageUrl1'];
    bannerImageUrl2 = json['bannerImageUrl2'];
    bannerImageUrl3 = json['bannerImageUrl3'];
    bannerImageUrl4 = json['bannerImageUrl4'];
    bannerImageUrl5 = json['bannerImageUrl5'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['bannerImageUrl1'] = this.bannerImageUrl1;
    data['bannerImageUrl2'] = this.bannerImageUrl2;
    data['bannerImageUrl3'] = this.bannerImageUrl3;
    data['bannerImageUrl4'] = this.bannerImageUrl4;
    data['bannerImageUrl5'] = this.bannerImageUrl5;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}