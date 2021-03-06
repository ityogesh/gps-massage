import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/alertDialogHelper/dialogHelper.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/firebaseChatHelper/db.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/statusCodeResponseHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/customTextField/text_field_custom.dart';
import 'package:gps_massageapp/customLibraryClasses/dropdowns/dropDownDisableProviderEditScreen.dart';
import 'package:gps_massageapp/customLibraryClasses/dropdowns/dropDownServiceUserRegisterScreen.dart';
import 'package:gps_massageapp/customLibraryClasses/keyboardDoneButton/keyboardActionConfig.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/bankNameDropDownModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/cityList.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/loginResponseModel.dart'
    as loginResponse;
import 'package:gps_massageapp/models/responseModels/serviceProvider/stateList.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<File> files = List<File>();

class ProviderEditProfile extends StatefulWidget {
  @override
  _ProviderEditProfileState createState() => _ProviderEditProfileState();
}

class _ProviderEditProfileState extends State<ProviderEditProfile> {
  final picker = ImagePicker();
  bool passwordVisibility = true;
  bool passwordConfirmVisibility = true;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Regex validation for emojis in text
  RegExp regexEmojis = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  //..updated regex pattern
  RegExp passwordRegex = new RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[~!?@#$%^&*_-]).{8,}$');

  RegExp emailRegex = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  //Regex validation for Username
  RegExp regExpUserName = new RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');

  //Regex validation for Email address
  RegExp regexMail = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  bool visible = false;
  bool gpsAddressVisible = false;
  bool showAddressField = false;
  bool _changeProgressText = false;

  List<String> businessFormDropDownValues = [
    "?????????????????? ?????????????????????",
    "?????????????????? ???????????????????????????????????????",
    "?????????????????? ????????????????????????????????????)",
    "?????????????????? ??????????????????????????????)",
  ];

  List<String> numberOfEmployeesDropDownValues = List<String>();

  List<String> storeTypeDropDownValues = [
    "?????????",
    "???????????????",
    "????????????????????????",
    "??????????????????",
  ];

  List<String> serviceBusinessTripDropDownValues = [
    "????????????",
    "????????????",
  ];

  List<String> coronaMeasuresDropDownValues = [
    "??????",
    "?????????",
  ];

  List<String> childrenMeasuresDropDownValues = [
    "??????????????????????????????",
    "??????????????????",
    "????????????OK",
  ];

  List<String> genderTreatmentDropDownValues = [
    "??????????????????",
    "????????????",
    "????????????",
  ];

  List<String> genderDropDownValues = [
    "??????",
    "??????",
    "?????????????????????",
  ];

  List<String> registrationAddressTypeDropDownValues = [
    "????????????????????????",
    "????????????",
  ];

  List<String> qualificationCertificates = [
    "?????????",
    "????????????",
    "?????????",
    "?????????????????????????????????",
    "???????????????",
    "???????????????",
    "????????????????????????????????????",
    "????????????",
    "?????????",
  ];

  List<dynamic> stateDropDownValues = List<dynamic>();
  List<dynamic> cityDropDownValues = List<dynamic>();
  List<String> childrenMeasuresDropDownValuesSelected = List<String>();
  StatesList states;
  bool businessTripEnabled = true;
  FocusNode storePhoneNumberFocus = FocusNode();

  final statekey = new GlobalKey<FormState>();
  final citykey = new GlobalKey<FormState>();
  var _prefid;
  bool readonly = false;
  String bussinessForm,
      numberOfEmployees,
      serviceBusinessTrips,
      coronaMeasures,
      genderTreatment,
      gender,
      myCity,
      myState;

  int status = 0;
  loginResponse.Data userData;

  int storeTypeDisplayStatus = 0;
  int childrenMeasureStatus = 0;

  List<String> selectedStoreTypeDisplayValues = List<String>();
  Map<String, String> deletedStoreTypeDisplayValues = Map<String, String>();

  DateTime selectedDate = DateTime.now();

  String _selectedDOBDate = 'Tap to select date';
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  int age = 0;
  var _ageOfUser;
  var selectedYear;

  bool _isGPSLocation = false;

  double sizedBoxFormHeight = 15.0;

  TextEditingController providerNameController = new TextEditingController();
  TextEditingController storeNameController = new TextEditingController();
  TextEditingController userDOBController = new TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController storePhoneNumberController =
      new TextEditingController();
  TextEditingController mailAddressController = new TextEditingController();
  TextEditingController gpsAddressController = new TextEditingController();
  TextEditingController manualAddressController = new TextEditingController();
  TextEditingController buildingNameController = new TextEditingController();
  TextEditingController roomNumberController = new TextEditingController();
  TextEditingController bankOtherFieldController = TextEditingController();
  PickedFile _profileImage;
  var identificationverify;
  PickedFile _idProfileImage;
  bool idUploadVisible = true;
  bool uploadVisible = false;
  final bankkey = new GlobalKey<FormState>();
  String accountHolderType;
  var qualification, bankname, accountType;
  List<String> bankNameDropDownList = List<String>();
  final accountnumberkey = new GlobalKey<FormState>();
  TextEditingController branchNameController = TextEditingController();
  TextEditingController branchNumberController = TextEditingController();
  TextEditingController accountnumberController = TextEditingController();
  TextEditingController bankNumberController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  BankNameDropDownModel bankNameDropDownModel;
  Map<String, String> certificateImages = Map<String, String>();
  final identityverification = new GlobalKey<FormState>();
  List<String> oldPrivateQualification = List<String>();
  List<String> privateQualification = List<String>();
  final qualificationupload = new GlobalKey<FormState>();
  Map<String, String> oldCertificateImages = Map<String, String>();
  List<String> oldCertificateImagesJaNames = List<String>();

  double iconHeight = 20.0;
  double iconWidth = 20.0;
  Color iconColor = Colors.black;

  void initState() {
    super.initState();
    getBankName();
    _getState();
    identificationverify = '';
    myState = '';
    myCity = '';
    _prefid = '';
    qualification = '';
    bankname = '';
    qualification = '';
    accountType = '';
    buildNumberOfEmployess();
    //  getProfileDetails();
  }

  _selectDate(BuildContext context) {
    DatePicker.showDatePicker(context,
        locale: LocaleType.jp,
        currentTime: selectedDate,
        minTime: DateTime(1901, 1),
        maxTime: DateTime.now(), onConfirm: (DateTime picked) {
      setState(() {
        selectedDate = picked;
        _selectedDOBDate = new DateFormat("yyyy-MM-dd").format(picked);
        userDOBController.value =
            TextEditingValue(text: _selectedDOBDate.toString());

        //print(_selectedDOBDate);
        selectedYear = picked.year;
        calculateAge();
      });
    });
  }

  void calculateAge() {
    setState(() {
      DateTime currentDate = DateTime.now();
      age = currentDate.year - selectedDate.year;
      int month1 = currentDate.month;
      int month2 = selectedDate.month;
      if (month2 > month1) {
        age--;
      } else if (month1 == month2) {
        int day1 = currentDate.day;
        int day2 = selectedDate.day;
        if (day2 > day1) {
          age--;
        }
      }
      _ageOfUser = age.toString();
      //print('Age : $ageOfUser');
      ageController.value = TextEditingValue(text: _ageOfUser);
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  buildNumberOfEmployess() {
    for (int i = 1; i <= 100; i++) {
      numberOfEmployeesDropDownValues.add(i.toString());
    }
  }

  List<dynamic> newbuildDropDownMenuItems(List<String> listItems) {
    List<dynamic> items = List();
    for (String listItemVal in listItems) {
      items.add({
        "display": listItemVal,
        "value": listItemVal,
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double containerHeight =
        51.0; //height of Every TextFormField wrapped with container
    double containerWidth =
        size.width * 0.9; //width of Every TextFormField wrapped with container
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        elevation: 0.0,
        leading: IconButton(
          padding:
              EdgeInsets.only(left: 4.0, top: 8.0, bottom: 8.0, right: 0.0),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '?????????????????????',
          style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'NotoSansJP',
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: status != 3
          ? Center(
              child: SpinKitDoubleBounce(color: Colors.limeAccent),
            )
          : KeyboardActions(
              config: KeyboardCustomActions()
                  .buildConfig(context, storePhoneNumberFocus),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),
                      Stack(
                        overflow: Overflow.visible,
                        children: [
                          _profileImage != null
                              ? InkWell(
                                  onTap: () {
                                    _showPicker(context, 0);
                                  },
                                  child: Semantics(
                                    child: new Container(
                                        width: 100.0,
                                        height: 100.0,
                                        decoration: new BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black12),
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                                File(_profileImage.path)),
                                          ),
                                        )),
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    _showPicker(context, 0);
                                  },
                                  child: new Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: new BoxDecoration(
                                        border:
                                            Border.all(color: Colors.grey[200]),
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: new NetworkImage(
                                              userData.uploadProfileImgUrl),
                                        ),
                                      )),
                                ),
                          /* Positioned(
                            right: -60.0,
                            top: 60,
                            left: 10.0,
                            child: InkWell(
                              onTap: () {
                                _showPicker(context, 0);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                radius: 13,
                                child: SvgPicture.asset(
                                  "assets/images_gps/edit_button.svg",
                                  /*  height: iconHeight,
                                  width: iconWidth, */
                                  color: iconColor,
                                ),
                              ),
                            ),
                          ), */
                        ],
                      ),
                      SizedBox(height: sizedBoxFormHeight),
                      Container(
                          height: containerHeight,
                          width: containerWidth,
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(splashColor: Colors.black12),
                            child: TextFieldCustom(
                              enabled: false,
                              controller: providerNameController,
                              style: HealingMatchConstants.formTextStyle,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16.0),
                                /*  labelText: HealingMatchConstants.registrationName,
                            labelStyle: HealingMatchConstants.formLabelTextStyle, */
                                filled: true,
                                fillColor: ColorConstants.formFieldFillColor,
                                disabledBorder:
                                    HealingMatchConstants.textFormInputBorder,
                                focusedBorder:
                                    HealingMatchConstants.textFormInputBorder,
                                enabledBorder:
                                    HealingMatchConstants.textFormInputBorder,
                              ),
                              labelText: Text.rich(
                                TextSpan(
                                  text: HealingMatchConstants.registrationName,
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: '*',
                                      style: HealingMatchConstants
                                          .formHintTextStyleStar,
                                    ),
                                  ],
                                  style:
                                      HealingMatchConstants.formLabelTextStyle,
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: sizedBoxFormHeight,
                      ),
                      Container(
                        height: containerHeight,
                        width: containerWidth,
                        //margin: EdgeInsets.all(16.0),
                        margin: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Theme(
                                  data: Theme.of(context)
                                      .copyWith(splashColor: Colors.black12),
                                  child: InkWell(
                                    onTap: () {
                                      //   _selectDate(context);
                                    },
                                    child: TextFieldCustom(
                                        enabled: false,
                                        controller: userDOBController,
                                        labelText: Text.rich(
                                          TextSpan(
                                            text: HealingMatchConstants
                                                .registrationDob,
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '*',
                                                style: HealingMatchConstants
                                                    .formHintTextStyleStar,
                                              ),
                                            ],
                                            style: HealingMatchConstants
                                                .formLabelTextStyle,
                                          ),
                                        ),
                                        style:
                                            HealingMatchConstants.formTextStyle,
                                        decoration: InputDecoration(
                                            /*  labelText: HealingMatchConstants
                                                .editProfileDob,
                                            labelStyle: HealingMatchConstants
                                                .formLabelTextStyle, */
                                            filled: true,
                                            fillColor: ColorConstants
                                                .formFieldFillColor,
                                            focusedBorder: HealingMatchConstants
                                                .textFormInputBorder,
                                            disabledBorder:
                                                HealingMatchConstants
                                                    .textFormInputBorder,
                                            enabledBorder: HealingMatchConstants
                                                .textFormInputBorder,
                                            suffixIcon: IconButton(
                                                icon: SvgPicture.asset(
                                                  "assets/images_gps/calendar.svg",
                                                  height: iconHeight,
                                                  width: iconWidth,
                                                  color: iconColor,
                                                ),
                                                onPressed: () {
                                                  _selectDate(context);
                                                }))),
                                  ),
                                )),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Container(
                                height: containerHeight,
                                child: TextFormField(
                                  textAlign: TextAlign.center,
                                  enabled: false,
                                  controller: ageController,
                                  style: HealingMatchConstants.formTextStyle,
                                  decoration: InputDecoration(
                                    labelText: "??????	",
                                    labelStyle: HealingMatchConstants
                                        .formLabelTextStyle,
                                    filled: true,
                                    fillColor:
                                        ColorConstants.formFieldFillColor,
                                    focusedBorder: HealingMatchConstants
                                        .textFormInputBorder,
                                    disabledBorder: HealingMatchConstants
                                        .textFormInputBorder,
                                    enabledBorder: HealingMatchConstants
                                        .textFormInputBorder,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: sizedBoxFormHeight - 8.0,
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            // height: containerHeight,
                            width: containerWidth,
                            child: DropDownFormField(
                              requiredField: true,
                              enabled: false,
                              hintText: HealingMatchConstants.editProfileGender,
                              value: gender,
                              onSaved: (value) {
                                setState(() {
                                  gender = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  gender = value;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                });
                              },
                              dataSource: genderDropDownValues,
                              isList: true,
                              textField: 'display',
                              valueField: 'value',
                            ),
                          ),
                          gender != null && gender != ''
                              ? Positioned(
                                  left: 12.0,
                                  child: Row(
                                    children: [
                                      Text(
                                        HealingMatchConstants.editProfileGender,
                                        style: TextStyle(
                                            color: ColorConstants
                                                .formHintTextColor,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                      Text(
                                        "*",
                                        style: TextStyle(
                                            color: Colors.redAccent.shade700,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(''),
                        ],
                      ),
                      SizedBox(
                        height: sizedBoxFormHeight,
                      ),
                      Container(
                          height: containerHeight,
                          width: containerWidth,
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(splashColor: Colors.black12),
                            child: TextFieldCustom(
                              enabled: false,
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              style: HealingMatchConstants.formTextStyle,
                              decoration: InputDecoration(
                                /* labelText:
                                    HealingMatchConstants.editProfilePhnNum,
                                labelStyle:
                                    HealingMatchConstants.formLabelTextStyle, */
                                filled: true,
                                fillColor: ColorConstants.formFieldFillColor,
                                disabledBorder:
                                    HealingMatchConstants.textFormInputBorder,
                                focusedBorder:
                                    HealingMatchConstants.textFormInputBorder,
                                enabledBorder:
                                    HealingMatchConstants.textFormInputBorder,
                              ),
                              labelText: Text.rich(
                                TextSpan(
                                  text: HealingMatchConstants.editProfilePhnNum,
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: '*',
                                      style: HealingMatchConstants
                                          .formHintTextStyleStar,
                                    ),
                                  ],
                                  style:
                                      HealingMatchConstants.formLabelTextStyle,
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: sizedBoxFormHeight,
                      ),
                      Container(
                          height: containerHeight,
                          width: containerWidth,
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(splashColor: Colors.black12),
                            child: TextFieldCustom(
                              enabled: true,
                              controller: mailAddressController,
                              style: HealingMatchConstants.formTextStyle,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16.0),
                                /*    labelText:
                                    HealingMatchConstants.editProfileMailAdress,
                                labelStyle:
                                    HealingMatchConstants.formLabelTextStyle, */
                                filled: true,
                                fillColor: ColorConstants.formFieldFillColor,
                                focusedBorder:
                                    HealingMatchConstants.textFormInputBorder,
                                enabledBorder:
                                    HealingMatchConstants.textFormInputBorder,
                              ),
                              labelText: Text.rich(
                                TextSpan(
                                  text: HealingMatchConstants
                                      .editProfileMailAdress,
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: '*',
                                      style: HealingMatchConstants
                                          .formHintTextStyleStar,
                                    ),
                                  ],
                                  style:
                                      HealingMatchConstants.formLabelTextStyle,
                                ),
                              ),
                            ),
                          )),
                      SizedBox(height: sizedBoxFormHeight),
                      Container(
                        height: containerHeight,
                        width: containerWidth,
                        child: InkWell(
                          onTap: () {
                            _showPicker(context, 0);
                          },
                          child: TextFieldCustom(
                            enabled: false,
                            hintText: Text.rich(
                              TextSpan(
                                text: "?????????????????????????????????",
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: '*',
                                    style: HealingMatchConstants
                                        .formHintTextStyleStar,
                                  ),
                                ],
                                style: HealingMatchConstants.formTextStyle,
                              ),
                            ),
                            style: HealingMatchConstants.formHintTextStyle,
                            decoration: new InputDecoration(
                              focusedBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              disabledBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              enabledBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              suffixIcon: IconButton(
                                  padding: EdgeInsets.only(left: 8.0),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 30.0,
                                    color: Colors
                                        .black, //Color.fromRGBO(200, 200, 200, 1),
                                  ),
                                  onPressed: () {
                                    _showPicker(context, 0);
                                  }),
                              filled: true,
                              fillColor: ColorConstants.formFieldFillColor,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: containerHeight,
                        width: containerWidth,
                        child: Text(
                          HealingMatchConstants.registrationFacePhtoText,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 11,
                              color: ColorConstants.formHintTextColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: sizedBoxFormHeight - 10.0),
                      Column(
                        children: [
                          Container(
                            width: containerWidth,
                            child: Text(
                              HealingMatchConstants.registrationPlaceAddress,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ColorConstants.formLabelTextColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            width: containerWidth,
                            child: Text(
                              HealingMatchConstants.registrationIndividualText,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 11,
                                color: ColorConstants.formHintTextColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: sizedBoxFormHeight,
                          ),
                          Stack(
                            children: [
                              Container(
                                width: containerWidth,
                                margin: EdgeInsets.only(top: 8.0),
                                child: DropDownFormField(
                                  requiredField: true,
                                  titleText: null,
                                  hintText: readonly ? myState : '????????????',
                                  onSaved: (value) {
                                    setState(() {
                                      myState = value;
                                    });
                                  },
                                  value: myState,
                                  onChanged: (value) {
                                    setState(() {
                                      myState = value;

                                      _prefid =
                                          stateDropDownValues.indexOf(value) +
                                              1;
                                      print('prefID : ${_prefid.toString()}');
                                      cityDropDownValues.clear();
                                      myCity = '';
                                      _getCityDropDown(_prefid);
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    });
                                  },
                                  dataSource: stateDropDownValues,
                                  isList: true,
                                  textField: 'display',
                                  valueField: 'value',
                                ),
                              ),
                              myState != null && myState != ''
                                  ? Positioned(
                                      left: 12.0,
                                      child: Row(
                                        children: [
                                          Text(
                                            "????????????",
                                            style: TextStyle(
                                                color: ColorConstants
                                                    .formHintTextColor,
                                                fontFamily: 'NotoSansJP',
                                                fontSize: 10.0),
                                          ),
                                          Text(
                                            "*",
                                            style: TextStyle(
                                                color:
                                                    Colors.redAccent.shade700,
                                                fontFamily: 'NotoSansJP',
                                                fontSize: 10.0),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(''),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: sizedBoxFormHeight - 8.0,
                              ),
                              Container(
                                  width: containerWidth,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top: 8.0),
                                              child: DropDownFormField(
                                                requiredField: true,
                                                titleText: null,
                                                hintText:
                                                    readonly ? myCity : '????????????',
                                                onSaved: (value) {
                                                  setState(() {
                                                    myCity = value;
                                                  });
                                                },
                                                value: myCity,
                                                onChanged: (value) {
                                                  setState(() {
                                                    myCity = value;
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            new FocusNode());
                                                  });
                                                },
                                                dataSource: cityDropDownValues,
                                                isList: true,
                                                textField: 'display',
                                                valueField: 'value',
                                              ),
                                            ),
                                            myCity != null && myCity != ''
                                                ? Positioned(
                                                    left: 12.0,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "????????????",
                                                          style: TextStyle(
                                                              color: ColorConstants
                                                                  .formHintTextColor,
                                                              fontFamily:
                                                                  'NotoSansJP',
                                                              fontSize: 10.0),
                                                        ),
                                                        Text(
                                                          "*",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent
                                                                  .shade700,
                                                              fontFamily:
                                                                  'NotoSansJP',
                                                              fontSize: 10.0),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Text(''),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Expanded(
                                        child: Container(
                                            height: containerHeight,
                                            margin: EdgeInsets.only(top: 8.0),
                                            width: containerWidth,
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                  splashColor: Colors.black12),
                                              child: TextFieldCustom(
                                                controller:
                                                    manualAddressController,
                                                style: HealingMatchConstants
                                                    .formTextStyle,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(16.0),
                                                  /*  labelText: "??????, ??????",
                                    labelStyle:
                                          HealingMatchConstants.formLabelTextStyle,
                                     */
                                                  filled: true,
                                                  fillColor: ColorConstants
                                                      .formFieldFillColor,
                                                  disabledBorder:
                                                      HealingMatchConstants
                                                          .textFormInputBorder,
                                                  focusedBorder:
                                                      HealingMatchConstants
                                                          .textFormInputBorder,
                                                  enabledBorder:
                                                      HealingMatchConstants
                                                          .textFormInputBorder,
                                                ),
                                                labelText: Text.rich(
                                                  TextSpan(
                                                    text: "??????, ??????",
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        text: '*',
                                                        style: HealingMatchConstants
                                                            .formHintTextStyleStar,
                                                      ),
                                                    ],
                                                    style: HealingMatchConstants
                                                        .formLabelTextStyle,
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          SizedBox(
                            height: sizedBoxFormHeight,
                          ),
                          Container(
                            height: containerHeight,
                            width: containerWidth,
                            //margin: EdgeInsets.all(16.0),
                            //margin: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Theme(
                                  data: Theme.of(context)
                                      .copyWith(splashColor: Colors.black12),
                                  child: TextFieldCustom(
                                    controller: buildingNameController,
                                    style: HealingMatchConstants.formTextStyle,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(16.0),
                                      /*  labelText: HealingMatchConstants
                                          .editProfileBuildingName,
                                      labelStyle: HealingMatchConstants
                                          .formLabelTextStyle, */
                                      filled: true,
                                      fillColor:
                                          ColorConstants.formFieldFillColor,
                                      focusedBorder: HealingMatchConstants
                                          .textFormInputBorder,
                                      enabledBorder: HealingMatchConstants
                                          .textFormInputBorder,
                                    ),
                                    labelText: Text.rich(
                                      TextSpan(
                                        text: HealingMatchConstants
                                            .registrationBuildingName,
                                        /* children: <InlineSpan>[
                                          TextSpan(
                                            text: '*',
                                            style: HealingMatchConstants
                                                .formHintTextStyleStar,
                                          ),
                                        ], */
                                        style: HealingMatchConstants
                                            .formLabelTextStyle,
                                      ),
                                    ),
                                  ),
                                )),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                  child: Container(
                                      child: Theme(
                                    data: Theme.of(context)
                                        .copyWith(splashColor: Colors.black12),
                                    child: TextFieldCustom(
                                      controller: roomNumberController,
                                      style:
                                          HealingMatchConstants.formTextStyle,
                                      keyboardType: TextInputType.text,
                                      maxLength: 4,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        /*  labelText: HealingMatchConstants
                                              .editProfileRoomNo,
                                          labelStyle: HealingMatchConstants
                                              .formLabelTextStyle, */
                                        filled: true,
                                        fillColor:
                                            ColorConstants.formFieldFillColor,
                                        focusedBorder: HealingMatchConstants
                                            .textFormInputBorder,
                                        enabledBorder: HealingMatchConstants
                                            .textFormInputBorder,
                                      ),
                                      labelText: Text.rich(
                                        TextSpan(
                                          text: HealingMatchConstants
                                              .registrationRoomNo,
                                          /*  children: <InlineSpan>[
                                            TextSpan(
                                              text: '*',
                                              style: HealingMatchConstants
                                                  .formHintTextStyleStar,
                                            ),
                                          ], */
                                          style: HealingMatchConstants
                                              .formLabelTextStyle,
                                        ),
                                      ),
                                    ),
                                  )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizedBoxFormHeight),
                      Container(
                        width: containerWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("*", style: TextStyle(color: Colors.red)),
                            Expanded(
                              child: Text(
                                HealingMatchConstants.registrationPointTxt,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorConstants.formHintTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sizedBoxFormHeight - 8.0),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            height: containerHeight,
                            width: containerWidth,
                            /*  decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                               // color: Colors.black12,
                                                border: Border.all(color: Colors.transparent)), */
                            child: DropDownFormField(
                              requiredField: true,
                              hintText: '????????????',
                              value: bussinessForm,
                              onSaved: (value) {
                                setState(() {
                                  bussinessForm = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  bussinessForm = value;
                                  if (value == "?????????????????? ????????????????????????????????????)" ||
                                      value == "?????????????????? ??????????????????????????????)") {
                                    serviceBusinessTrips = "????????????";
                                    businessTripEnabled = false;
                                  } else {
                                    serviceBusinessTrips = "";
                                    businessTripEnabled = true;
                                  }

                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                });
                              },
                              dataSource: businessFormDropDownValues,
                              isList: true,
                              textField: 'display',
                              valueField: 'value',
                            ),
                          ),
                          bussinessForm != null && bussinessForm != ''
                              ? Positioned(
                                  left: 12.0,
                                  child: Row(
                                    children: [
                                      Text(
                                        "????????????",
                                        style: TextStyle(
                                            color: ColorConstants
                                                .formHintTextColor,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                      Text(
                                        "*",
                                        style: TextStyle(
                                            color: Colors.redAccent.shade700,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(''),
                        ],
                      ),
                      bussinessForm == "?????????????????? ?????????????????????" ||
                              bussinessForm == "?????????????????? ???????????????????????????????????????"
                          ? Column(children: [
                              /*SizedBox(
                                height: sizedBoxFormHeight,
                              ),
                              Container(
                                width: containerWidth,
                                child: Text(
                                  HealingMatchConstants.registrationStoreTxt,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ColorConstants.formHintTextColor,
                                  ),
                                ),
                              ),*/
                              SizedBox(
                                height: sizedBoxFormHeight,
                              ),
                              Container(
                                  height: containerHeight,
                                  width: containerWidth,
                                  child: Theme(
                                    data: Theme.of(context)
                                        .copyWith(splashColor: Colors.black12),
                                    child: TextFieldCustom(
                                      controller: storeNameController,
                                      style:
                                          HealingMatchConstants.formTextStyle,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(16.0),
                                        /*  labelText: HealingMatchConstants
                                        .registrationStoreName,
                                    labelStyle:
                                        HealingMatchConstants.formLabelTextStyle, */
                                        filled: true,
                                        fillColor:
                                            ColorConstants.formFieldFillColor,
                                        focusedBorder: HealingMatchConstants
                                            .textFormInputBorder,
                                        enabledBorder: HealingMatchConstants
                                            .textFormInputBorder,
                                      ),
                                      labelText: Text.rich(
                                        TextSpan(
                                          text: HealingMatchConstants
                                              .registrationStoreName,
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: '*',
                                              style: HealingMatchConstants
                                                  .formHintTextStyleStar,
                                            ),
                                          ],
                                          style: HealingMatchConstants
                                              .formLabelTextStyle,
                                        ),
                                      ),
                                    ),
                                  )),
                            ])
                          : Container(),
                      SizedBox(
                        height: bussinessForm == "?????????????????? ?????????????????????" ||
                                bussinessForm == "?????????????????? ???????????????????????????????????????"
                            ? sizedBoxFormHeight
                            : 0,
                      ),
                      bussinessForm == "?????????????????? ?????????????????????" ||
                              bussinessForm == "?????????????????? ???????????????????????????????????????"
                          ? Container(
                              height: containerHeight,
                              width: containerWidth,
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(splashColor: Colors.black12),
                                child: TextFieldCustom(
                                  focusNode: storePhoneNumberFocus,
                                  controller: storePhoneNumberController,
                                  style: HealingMatchConstants.formTextStyle,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    /*   labelText: HealingMatchConstants
                                        .editProfileStorePhnNum,
                                    labelStyle: HealingMatchConstants
                                        .formLabelTextStyle, */
                                    filled: true,
                                    fillColor:
                                        ColorConstants.formFieldFillColor,
                                    focusedBorder: HealingMatchConstants
                                        .textFormInputBorder,
                                    enabledBorder: HealingMatchConstants
                                        .textFormInputBorder,
                                  ),
                                  labelText: Text.rich(
                                    TextSpan(
                                      text: HealingMatchConstants
                                          .editProfileStorePhnNum,
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: '*',
                                          style: HealingMatchConstants
                                              .formHintTextStyleStar,
                                        ),
                                      ],
                                      style: HealingMatchConstants
                                          .formLabelTextStyle,
                                    ),
                                  ),
                                ),
                              ))
                          : Container(),
                      SizedBox(
                        height: bussinessForm == "?????????????????? ?????????????????????" ||
                                bussinessForm == "?????????????????? ????????????????????????????????????)"
                            ? sizedBoxFormHeight - 8.0
                            : 0.0,
                      ),
                      bussinessForm == "?????????????????? ?????????????????????" ||
                              bussinessForm == "?????????????????? ????????????????????????????????????)"
                          ? Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 8.0),
                                  height: containerHeight,
                                  width: containerWidth,
                                  /*  decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                               // color: Colors.black12,
                                                border: Border.all(color: Colors.black12)), */
                                  child: DropDownFormField(
                                    hintText: '????????????',
                                    value: numberOfEmployees,
                                    onSaved: (value) {
                                      setState(() {
                                        numberOfEmployees = value;
                                      });
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        numberOfEmployees = value;
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      });
                                    },
                                    dataSource: numberOfEmployeesDropDownValues,
                                    isList: true,
                                    textField: 'display',
                                    valueField: 'value',
                                  ),
                                ),
                                numberOfEmployees != null &&
                                        numberOfEmployees != ''
                                    ? Positioned(
                                        left: 12.0,
                                        child: Row(
                                          children: [
                                            Text(
                                              "????????????",
                                              style: TextStyle(
                                                  color: ColorConstants
                                                      .formHintTextColor,
                                                  fontFamily: 'NotoSansJP',
                                                  fontSize: 10.0),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(''),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: sizedBoxFormHeight,
                      ),
                      Container(
                        height: containerHeight,
                        width: containerWidth,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              storeTypeDisplayStatus == 0
                                  ? storeTypeDisplayStatus = 1
                                  : storeTypeDisplayStatus = 0;
                            });
                          },
                          child: TextFieldCustom(
                            enabled: false,
                            hintText: Text.rich(
                              TextSpan(
                                text:
                                    HealingMatchConstants.registrationStoretype,
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: '*',
                                    style: HealingMatchConstants
                                        .formHintTextStyleStar,
                                  ),
                                ],
                                style: HealingMatchConstants.formHintTextStyle,
                              ),
                            ),
                            /*  initialValue:
                                HealingMatchConstants.registrationStoretype, */
                            style: HealingMatchConstants.formHintTextStyle,
                            decoration: new InputDecoration(
                              focusedBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              disabledBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              enabledBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              suffixIcon: IconButton(
                                  padding: EdgeInsets.only(left: 8.0),
                                  icon: storeTypeDisplayStatus == 0
                                      ? Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 30.0,
                                          color: Colors
                                              .black, //Color.fromRGBO(200, 200, 200, 1),
                                        )
                                      : Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 30.0,
                                          color: Colors
                                              .black, //Color.fromRGBO(200, 200, 200, 1),
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      storeTypeDisplayStatus == 0
                                          ? storeTypeDisplayStatus = 1
                                          : storeTypeDisplayStatus = 0;
                                    });
                                  }),
                              filled: true,
                              fillColor: ColorConstants.formFieldFillColor,
                            ),
                          ),
                        ),
                      ),
                      storeTypeDisplayStatus == 1
                          ? Container(
                              width: containerWidth,
                              padding: EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: storeTypeDropDownValues.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return buildStoreTypeDisplayBoxContent(
                                      storeTypeDropDownValues[index],
                                      index,
                                    );
                                  }),
                            )
                          : Container(
                              width: containerWidth,
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.start,
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: selectedStoreTypeDisplayValues
                                    .map((e) {
                                      return Container(
                                        padding: EdgeInsets.all(10.0),
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: Colors.grey,
                                            )),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "$e",
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList()
                                    .cast<Widget>(),
                              ),
                            ),
                      SizedBox(
                        height: sizedBoxFormHeight - 8.0,
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            // height: containerHeight,
                            width: containerWidth,
                            /* decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                                color: Colors.black12,
                                                border: Border.all(color: Colors.black12)), */
                            child: DropDownFormField(
                              enabled: businessTripEnabled,
                              hintText: HealingMatchConstants
                                  .registrationBuisnessTrip,
                              value: serviceBusinessTrips,
                              onSaved: (value) {
                                setState(() {
                                  serviceBusinessTrips = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  serviceBusinessTrips = value;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                });
                              },
                              dataSource: serviceBusinessTripDropDownValues,
                              isList: true,
                              textField: 'display',
                              valueField: 'value',
                            ),
                          ),
                          serviceBusinessTrips != null &&
                                  serviceBusinessTrips != ''
                              ? Positioned(
                                  left: 12.0,
                                  child: Row(
                                    children: [
                                      Text(
                                        HealingMatchConstants
                                            .registrationBuisnessTrip,
                                        style: TextStyle(
                                            color: ColorConstants
                                                .formHintTextColor,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(''),
                        ],
                      ),
                      SizedBox(
                        height: sizedBoxFormHeight - 8.0,
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            width: containerWidth,
                            child: DropDownFormField(
                              hintText:
                                  HealingMatchConstants.registrationCoronaTxt,
                              value: coronaMeasures,
                              onSaved: (value) {
                                setState(() {
                                  coronaMeasures = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  coronaMeasures = value;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                });
                              },
                              dataSource: coronaMeasuresDropDownValues,
                              isList: true,
                              textField: 'display',
                              valueField: 'value',
                            ),
                          ),
                          coronaMeasures != null && coronaMeasures != ''
                              ? Positioned(
                                  left: 12.0,
                                  child: Row(
                                    children: [
                                      Text(
                                        HealingMatchConstants
                                            .registrationCoronaTxt,
                                        style: TextStyle(
                                            color: ColorConstants
                                                .formHintTextColor,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(''),
                        ],
                      ),
                      SizedBox(
                        height: sizedBoxFormHeight,
                      ),
                      Container(
                        width: containerWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("*", style: TextStyle(color: Colors.red)),
                            Text(
                              HealingMatchConstants
                                  .registrationJapanAssociationTxt,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 11,
                                color: ColorConstants.formHintTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: sizedBoxFormHeight,
                      ),
                      Container(
                        height: containerHeight,
                        width: containerWidth,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              childrenMeasureStatus == 0
                                  ? childrenMeasureStatus = 1
                                  : childrenMeasureStatus = 0;
                            });
                          },
                          child: TextFormField(
                            enabled: false,
                            initialValue:
                                HealingMatchConstants.registrationChildrenTxt,
                            style: HealingMatchConstants.formHintTextStyle,
                            decoration: new InputDecoration(
                              focusedBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              disabledBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              enabledBorder:
                                  HealingMatchConstants.textFormInputBorder,
                              suffixIcon: IconButton(
                                  padding: EdgeInsets.only(left: 8.0),
                                  icon: childrenMeasureStatus == 0
                                      ? Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 30.0,
                                          color: Colors
                                              .black, //Color.fromRGBO(200, 200, 200, 1),
                                        )
                                      : Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 30.0,
                                          color: Colors
                                              .black, //Color.fromRGBO(200, 200, 200, 1),
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      childrenMeasureStatus == 0
                                          ? childrenMeasureStatus = 1
                                          : childrenMeasureStatus = 0;
                                    });
                                  }),
                              filled: true,
                              fillColor: ColorConstants.formFieldFillColor,
                            ),
                          ),
                        ),
                      ),
                      childrenMeasureStatus == 1
                          ? Container(
                              width: containerWidth,
                              padding: EdgeInsets.all(8.0),
                              child: ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount:
                                      childrenMeasuresDropDownValues.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return buildChildrenMeasureCheckBoxContent(
                                      childrenMeasuresDropDownValues[index],
                                      index,
                                    );
                                  }),
                            )
                          : Container(
                              width: containerWidth,
                              padding: EdgeInsets.only(top: 8.0),
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.start,
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: childrenMeasuresDropDownValuesSelected
                                    .map((e) {
                                      return Container(
                                        padding: EdgeInsets.all(10.0),
                                        height: 40.0,
                                        //  width: 110.0,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: Colors.grey,
                                            )),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Text(
                                                "$e",
                                                style:
                                                    TextStyle(fontSize: 12.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList()
                                    .cast<Widget>(),
                              ),
                            ),
                      SizedBox(
                        height: sizedBoxFormHeight - 8.0,
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.0),
                            height: containerHeight,
                            width: containerWidth,
                            child: DropDownFormField(
                              hintText: '??????????????????????????????????????????',
                              value: genderTreatment,
                              onSaved: (value) {
                                setState(() {
                                  genderTreatment = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  genderTreatment = value;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                });
                              },
                              dataSource: genderTreatmentDropDownValues,
                              isList: true,
                              textField: 'display',
                              valueField: 'value',
                            ),
                          ),
                          genderTreatment != null && genderTreatment != ''
                              ? Positioned(
                                  left: 12.0,
                                  child: Row(
                                    children: [
                                      Text(
                                        "??????????????????????????????????????????",
                                        style: TextStyle(
                                            color: ColorConstants
                                                .formHintTextColor,
                                            fontFamily: 'NotoSansJP',
                                            fontSize: 10.0),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(''),
                        ],
                      ),
                      SizedBox(
                        height: sizedBoxFormHeight - 8.0,
                      ),
                      Container(
                        width: containerWidth,
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 8.0),
                              child: DropDownFormField(
                                enabled: false,
                                autovalidate: false,
                                requiredField: true,
                                titleText: null,
                                hintText: readonly
                                    ? identificationverify
                                    : HealingMatchConstants
                                        .registrationIdentityVerification,
                                onSaved: (value) {
                                  if (_idProfileImage == null) {
                                    setState(() {
                                      identificationverify = value;
                                      idUploadVisible = true;
                                    });
                                  } else {
                                    showIdSelectError();
                                  }
                                },
                                value: identificationverify,
                                onChanged: (value) {
                                  if (_idProfileImage == null) {
                                    setState(() {
                                      identificationverify = value;
                                      idUploadVisible = true;
                                    });
                                  } else {
                                    showIdSelectError();
                                  }
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                                dataSource: [
                                  {
                                    "display": "???????????????",
                                    "value": "???????????????",
                                  },
                                  {
                                    "display": "?????????????????????",
                                    "value": "?????????????????????",
                                  },
                                  {
                                    "display": "???????????????",
                                    "value": "???????????????",
                                  },
                                  {
                                    "display": "?????????????????????",
                                    "value": "?????????????????????",
                                  },
                                  {
                                    "display": "???????????????",
                                    "value": "???????????????",
                                  },
                                  {
                                    "display": "???????????????????????????",
                                    "value": "???????????????????????????",
                                  },
                                  {
                                    "display": "???????????????????????????",
                                    "value": "???????????????????????????",
                                  },
                                  // {
                                  //   "display": "?????????????????????",
                                  //   "value": "?????????????????????",
                                  // },
                                  {
                                    "display": "?????????",
                                    "value": "?????????",
                                  },
                                ],
                                textField: 'display',
                                valueField: 'value',
                              ),
                            ),
                            identificationverify != null &&
                                    identificationverify != ''
                                ? Positioned(
                                    left: 12.0,
                                    child: Row(
                                      children: [
                                        Text(
                                          HealingMatchConstants
                                              .registrationIdentityVerification,
                                          style: TextStyle(
                                              color: ColorConstants
                                                  .formHintTextColor,
                                              fontFamily: 'NotoSansJP',
                                              fontSize: 10.0),
                                        ),
                                        Text(
                                          "*",
                                          style: TextStyle(
                                              color: Colors.redAccent.shade700,
                                              fontFamily: 'NotoSansJP',
                                              fontSize: 10.0),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(''),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: idUploadVisible ? sizedBoxFormHeight : 0),
                      Container(
                        width: containerWidth,
                        child: Visibility(
                          visible: true,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    //width: 140.0, // MediaQuery.of(context).size.width * 0.38,
                                    //height: MediaQuery.of(context).size.height * 0.19,
                                    width: 140.0,
                                    height: 140.0,
                                    decoration: new BoxDecoration(
                                      //   border: Border.all(color: Colors.black12),
                                      //   shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            userData.proofOfIdentityImgUrl),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sizedBoxFormHeight),
                      Container(
                        width: containerWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  HealingMatchConstants.registrationAdd,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("\n*",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor:
                                  ColorConstants.formFieldFillColor,
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      visible = true;
                                      uploadVisible = false;
                                      qualification = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: visible ? sizedBoxFormHeight : 0),
                      Visibility(
                        visible: visible,
                        child: Form(
                          key: qualificationupload,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                //margin: EdgeInsets.all(0.0),
                                width: containerWidth,
                                child: DropDownFormField(
                                  titleText: null,
                                  hintText: readonly
                                      ? qualification
                                      : HealingMatchConstants
                                          .registrationQualificationDropdown,
                                  onSaved: (value) {
                                    setState(() {
                                      visible = value == "?????????" ? true : false;
                                      qualification = value;
                                      uploadVisible = value == "?????????"
                                          ? false
                                          : certificateImages
                                                  .containsKey(qualification)
                                              ? false
                                              : (value == "????????????") &&
                                                      (privateQualification
                                                              .length ==
                                                          5)
                                                  ? false
                                                  : true;
                                      if (value == "?????????") {
                                        certificateImages.clear();
                                        privateQualification.clear();
                                      }
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    });
                                  },
                                  value: qualification,
                                  onChanged: (value) {
                                    setState(() {
                                      visible = value == "?????????" ? true : false;
                                      qualification = value;
                                      uploadVisible = value == "?????????"
                                          ? false
                                          : certificateImages
                                                  .containsKey(qualification)
                                              ? false
                                              : (value == "????????????") &&
                                                      (privateQualification
                                                                  .length +
                                                              oldPrivateQualification
                                                                  .length >=
                                                          5)
                                                  ? false
                                                  : true;
                                      if (value == "?????????") {
                                        certificateImages.clear();
                                        privateQualification.clear();
                                      }
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                    });
                                  },
                                  dataSource: qualificationCertificates,
                                  isList: true,
                                  textField: 'display',
                                  valueField: 'value',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: !uploadVisible &&
                                certificateImages.length == 0 &&
                                privateQualification.length == 0 &&
                                oldCertificateImages.length == 0
                            ? 0
                            : 195.0, // MediaQuery.of(context).size.height * 0.19,
                        padding: EdgeInsets.only(top: 16.0),

                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Row(
                              children: [
                                /*   Visibility(
                                    visible: uploadVisible &&
                                        !certificateImages.containsKey(qualification),
                                    child: */
                                (uploadVisible &&
                                            !certificateImages
                                                .containsKey(qualification)) &&
                                        (!oldCertificateImages.containsKey(
                                                getQualififcationEngWords(
                                                    qualification)) ||
                                            qualification == "????????????")
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 18.0),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _showPicker(context, 1);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(0.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: ColorConstants
                                                      .formFieldFillColor,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.38,
                                                height: 140.0,
                                                //MediaQuery.of(context).size.height * 0.19,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    /*  Text('??????????????????'),
                                                      Text('?????????'), */
                                                    Center(
                                                      child: FittedBox(
                                                          child: Text(
                                                        "$qualification",
                                                        textAlign:
                                                            TextAlign.center,
                                                      )),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        _showPicker(context, 1);
                                                        /*  if (certificateImages.length ==
                                                              5) {
                                                            showCertificateImageError();
                                                          } else {
                                                            _showPicker(context, 1);
                                                          } */
                                                      },
                                                      icon: SvgPicture.asset(
                                                        "assets/images_gps/upload.svg",
                                                        height: iconHeight,
                                                        width: iconWidth,
                                                        color: iconColor,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      HealingMatchConstants
                                                          .registrationQualificationUpload,
                                                      style: TextStyle(
                                                          fontSize: 8.5),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),

                                //   ),
                                SizedBox(
                                  width: (uploadVisible &&
                                              !certificateImages.containsKey(
                                                  qualification)) &&
                                          (!oldCertificateImages.containsKey(
                                                  getQualififcationEngWords(
                                                      qualification)) ||
                                              qualification == "????????????")
                                      ? 10
                                      : 0,
                                ),
                                ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: oldCertificateImages.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String key = oldCertificateImages.keys
                                          .elementAt(index);
                                      return buildOldQualificationImage(
                                          key, index);
                                    }),
                                ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: certificateImages.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      String key = certificateImages.keys
                                          .elementAt(index);
                                      return buildQualificationImage(
                                          key, index);
                                    }),
                                ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: privateQualification.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return buildPrivateQualificationImage(
                                          privateQualification[index], index);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sizedBoxFormHeight),
                      Container(
                        width: containerWidth,
                        child: Text(
                          HealingMatchConstants.registrationBankDetails,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: sizedBoxFormHeight),
                      Center(
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 8.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: DropDownFormField(
                                        enabled: false,
                                        requiredField: true,
                                        titleText: null,
                                        hintText: readonly
                                            ? bankname
                                            : HealingMatchConstants
                                                .registrationBankName,
                                        onSaved: (value) {
                                          setState(() {
                                            bankname = value;
                                          });
                                        },
                                        value: bankname,
                                        onChanged: (value) {
                                          setState(() {
                                            bankname = value;
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          });
                                        },
                                        dataSource: bankNameDropDownList,
                                        isList: true,
                                        textField: 'display',
                                        valueField: 'value',
                                      ),
                                    ),
                                    bankname != null && bankname != ''
                                        ? Positioned(
                                            left: 12.0,
                                            child: Row(
                                              children: [
                                                Text(
                                                  HealingMatchConstants
                                                      .registrationBankName,
                                                  style: TextStyle(
                                                      color: ColorConstants
                                                          .formHintTextColor,
                                                      fontFamily: 'NotoSansJP',
                                                      fontSize: 10.0),
                                                ),
                                                Text(
                                                  "*",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .redAccent.shade700,
                                                      fontFamily: 'NotoSansJP',
                                                      fontSize: 10.0),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(''),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                bankname ==
                                        HealingMatchConstants
                                            .registrationBankOtherDropdownFiled
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 50.0,
                                              child: TextFieldCustom(
                                                enabled: false,
                                                style: HealingMatchConstants
                                                    .formTextStyle,
                                                controller:
                                                    bankOtherFieldController,
                                                decoration: InputDecoration(
                                                    /*   hintText: "?????????",
                                                    hintStyle:
                                                        HealingMatchConstants
                                                            .formHintTextStyle, */
                                                    contentPadding:
                                                        EdgeInsets.all(16.0),
                                                    /*    EdgeInsets.fromLTRB(
                                                            5, 5, 5, 0) ,*/
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    enabledBorder:
                                                        HealingMatchConstants
                                                            .otherFiledTextFormInputBorder,
                                                    focusedBorder:
                                                        HealingMatchConstants
                                                            .otherFiledTextFormInputBorder,
                                                    disabledBorder:
                                                        HealingMatchConstants
                                                            .otherFiledTextFormInputBorder,
                                                    border: HealingMatchConstants
                                                        .otherFiledTextFormInputBorder),
                                                labelText: Text.rich(
                                                  TextSpan(
                                                    text: "?????????",
                                                    children: <InlineSpan>[
                                                      TextSpan(
                                                        text: '*',
                                                        style: HealingMatchConstants
                                                            .formHintTextStyleStar,
                                                      ),
                                                    ],
                                                    style: HealingMatchConstants
                                                        .formLabelTextStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 8.0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.38,
                                          child: DropDownFormField(
                                            enabled: false,
                                            requiredField: true,
                                            titleText: null,
                                            hintText: readonly
                                                ? accountType
                                                : HealingMatchConstants
                                                    .registrationBankAccountType,
                                            onSaved: (value) {
                                              setState(() {
                                                accountType = value;
                                              });
                                            },
                                            value: accountType,
                                            onChanged: (value) {
                                              setState(() {
                                                accountType = value;
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                              });
                                            },
                                            dataSource: [
                                              {
                                                "display": "??????",
                                                "value": "??????",
                                              },
                                              {
                                                "display": "??????",
                                                "value": "??????",
                                              },
                                              {
                                                "display": "??????",
                                                "value": "??????",
                                              },
                                            ],
                                            textField: 'display',
                                            valueField: 'value',
                                          ),
                                        ),
                                        accountType != null && accountType != ''
                                            ? Positioned(
                                                left: 12.0,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      HealingMatchConstants
                                                          .registrationBankAccountType,
                                                      style: TextStyle(
                                                          color: ColorConstants
                                                              .formHintTextColor,
                                                          fontFamily:
                                                              'NotoSansJP',
                                                          fontSize: 10.0),
                                                    ),
                                                    Text(
                                                      "*",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .redAccent
                                                              .shade700,
                                                          fontFamily:
                                                              'NotoSansJP',
                                                          fontSize: 10.0),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Text(''),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 8.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      child: TextFieldCustom(
                                        enabled: false,
                                        controller: branchNameController,
                                        decoration: new InputDecoration(
                                          /*  labelText: HealingMatchConstants
                                              .registrationBankBranchCode,
                                          labelStyle: HealingMatchConstants
                                              .formLabelTextStyle, */
                                          contentPadding: EdgeInsets.all(14.0),
                                          border: HealingMatchConstants
                                              .textFormInputBorder,
                                          focusedBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          enabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          disabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          filled: true,
                                          fillColor:
                                              ColorConstants.formFieldFillColor,
                                        ),
                                        labelText: Text.rich(
                                          TextSpan(
                                            text: HealingMatchConstants
                                                .registrationBankBranchCode,
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '*',
                                                style: HealingMatchConstants
                                                    .formHintTextStyleStar,
                                              ),
                                            ],
                                            style: HealingMatchConstants
                                                .formLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      child: TextFieldCustom(
                                        enabled: false,
                                        controller: branchNumberController,
                                        decoration: new InputDecoration(
                                          /*  labelText: HealingMatchConstants
                                              .registrationBankBranchNumber,
                                          labelStyle: HealingMatchConstants
                                              .formLabelTextStyle, */
                                          contentPadding: EdgeInsets.all(14.0),
                                          border: HealingMatchConstants
                                              .textFormInputBorder,
                                          focusedBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          enabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          disabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          filled: true,
                                          fillColor:
                                              ColorConstants.formFieldFillColor,
                                        ),
                                        labelText: Text.rich(
                                          TextSpan(
                                            text: HealingMatchConstants
                                                .registrationBankBranchNumber,
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '*',
                                                style: HealingMatchConstants
                                                    .formHintTextStyleStar,
                                              ),
                                            ],
                                            style: HealingMatchConstants
                                                .formLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      child: TextFieldCustom(
                                        enabled: false,
                                        controller: accountnumberController,
                                        decoration: new InputDecoration(
                                          /*  labelText: HealingMatchConstants
                                              .registrationBankAccountNumber,
                                          labelStyle: HealingMatchConstants
                                              .formLabelTextStyle, */
                                          contentPadding: EdgeInsets.all(14.0),
                                          border: HealingMatchConstants
                                              .textFormInputBorder,
                                          focusedBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          enabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          disabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          filled: true,
                                          fillColor:
                                              ColorConstants.formFieldFillColor,
                                        ),
                                        labelText: Text.rich(
                                          TextSpan(
                                            text: HealingMatchConstants
                                                .registrationBankAccountNumber,
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '*',
                                                style: HealingMatchConstants
                                                    .formHintTextStyleStar,
                                              ),
                                            ],
                                            style: HealingMatchConstants
                                                .formLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      child: TextFieldCustom(
                                        enabled: false,
                                        controller: bankNumberController,
                                        style:
                                            HealingMatchConstants.formTextStyle,
                                        decoration: new InputDecoration(
                                          /*  labelText: HealingMatchConstants
                                          .registrationBankNumber,
                                      labelStyle: HealingMatchConstants
                                          .formLabelTextStyle, */
                                          contentPadding: EdgeInsets.all(16.0),
                                          border: HealingMatchConstants
                                              .textFormInputBorder,
                                          focusedBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          enabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          disabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          filled: true,
                                          fillColor:
                                              ColorConstants.formFieldFillColor,
                                        ),
                                        labelText: Text.rich(
                                          TextSpan(
                                            text: HealingMatchConstants
                                                .registrationBankNumber,
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '*',
                                                style: HealingMatchConstants
                                                    .formHintTextStyleStar,
                                              ),
                                            ],
                                            style: HealingMatchConstants
                                                .formLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.38,
                                      child: TextFieldCustom(
                                        enabled: false,
                                        controller: accountHolderNameController,
                                        style:
                                            HealingMatchConstants.formTextStyle,
                                        decoration: new InputDecoration(
                                          labelText: HealingMatchConstants
                                              .registrationHolderName,
                                          labelStyle: HealingMatchConstants
                                              .formLabelTextStyle,
                                          contentPadding: EdgeInsets.all(16.0),
                                          border: HealingMatchConstants
                                              .textFormInputBorder,
                                          focusedBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          enabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          disabledBorder: HealingMatchConstants
                                              .textFormInputBorder,
                                          filled: true,
                                          fillColor:
                                              ColorConstants.formFieldFillColor,
                                        ),
                                        labelText: Text.rich(
                                          TextSpan(
                                            text: HealingMatchConstants
                                                .registrationHolderName,
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '*',
                                                style: HealingMatchConstants
                                                    .formHintTextStyleStar,
                                              ),
                                            ],
                                            style: HealingMatchConstants
                                                .formLabelTextStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 8.0),
                                      // width: MediaQuery.of(context).size.width * 0.38,
                                      child: DisabledDropDownFormField(
                                        enabled: false,
                                        titleText: null,
                                        requiredField: true,
                                        hintText:
                                            accountHolderType == "individual"
                                                ? "??????"
                                                : "??????",
                                        onSaved: (value) {
                                          setState(() {
                                            accountHolderType = value;
                                          });
                                        },
                                        value: accountHolderType,
                                        onChanged: (value) {
                                          setState(() {
                                            accountHolderType = value;
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          });
                                        },
                                        dataSource: [
                                          {
                                            "display": "??????",
                                            "value": "individual",
                                          },
                                          {
                                            "display": "??????",
                                            "value": "company",
                                          },
                                        ],
                                        textField: 'display',
                                        valueField: 'value',
                                      ),
                                    ),
                                    accountHolderType != null &&
                                            accountHolderType != ''
                                        ? Positioned(
                                            left: 12.0,
                                            child: Row(
                                              children: [
                                                Text(
                                                  HealingMatchConstants
                                                      .registrationBankAccountHolderType,
                                                  style: TextStyle(
                                                      color: ColorConstants
                                                          .formHintTextColor,
                                                      fontFamily: 'NotoSansJP',
                                                      fontSize: 10.0),
                                                ),
                                                Text(
                                                  "*",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .redAccent.shade700,
                                                      fontFamily: 'NotoSansJP',
                                                      fontSize: 10.0),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(''),
                                  ],
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: containerHeight,
                        width: containerWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.lime,
                        ),
                        child: RaisedButton(
                          //padding: EdgeInsets.all(15.0),
                          child: Text(
                            HealingMatchConstants.profileUpdateBtn,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          color: Colors.lime,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          onPressed: () {
                            //!Commented for Dev purposes
                            validateFields();

                            /*  NavigationRouter.switchToServiceProviderSecondScreen(
                                  context); */
                          },
                        ),
                      ),
                      SizedBox(height: sizedBoxFormHeight),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  validateFields() async {
    ProgressDialogBuilder.showUserDetailsUpdateProgressDialog(context);

    var userPhoneNumber = phoneNumberController.text.toString();
    var email = mailAddressController.text.toString();
    var userName = providerNameController.text.toString();
    var storename = storeNameController.text.toString();
    var storenumber = storePhoneNumberController.text.toString();
    var age = ageController.text.toString();
    var manualAddresss = manualAddressController.text.toString();
    var buildingname = buildingNameController.text.toString();
    var roomnumber = roomNumberController.text.toString();
    var userDOB = userDOBController.text;
    var genderSelecetedValue = gender;

    //Profile image validation
    if ((_profileImage == null) && userData.uploadProfileImgUrl == null) {
      displaySnackBarError("??????????????????????????????????????????????????????");
      return null;
    }

    //Store Type validation
    if (selectedStoreTypeDisplayValues.isEmpty) {
      displaySnackBarError("??????????????????????????????????????????????????????????????????");

      return null;
    }

    //name Validation
    if (userName.length == 0 || userName.isEmpty || userName == null) {
      displaySnackBarError("???????????????????????????????????????");

      return;
    }

    if (userName.length > 20) {
      displaySnackBarError("????????????20??????????????????????????????????????????");

      return;
    }

    //storename Validation
    if ((bussinessForm == "?????????????????? ?????????????????????" ||
            bussinessForm == "?????????????????? ???????????????????????????????????????") &&
        (storename.length == 0 || storename.isEmpty || storename == null)) {
      displaySnackBarError("???????????????????????????????????????");

      return;
    }

    if ((bussinessForm == "?????????????????? ?????????????????????" ||
            bussinessForm == "?????????????????? ???????????????????????????????????????") &&
        (storename.length > 20)) {
      displaySnackBarError("????????????20??????????????????????????????????????????");

      return;
    }

    // user DOB validation
    if (userDOB == null || userDOB.isEmpty) {
      displaySnackBarError("???????????????????????????????????????????????????");

      return null;
    }

    // age validation
    if (int.parse(age) < 18) {
      displaySnackBarError("???????????????????????????????????????????????????");

      return null;
    }

    // gender validation
    if (genderSelecetedValue == null || genderSelecetedValue.isEmpty) {
      displaySnackBarError("???????????????????????????????????????????????????");

      return null;
    }

    // user phone number validation
    if ((userPhoneNumber == null || userPhoneNumber.isEmpty)) {
      displaySnackBarError("??????????????????????????????????????????");

      return;
    }

    if (userPhoneNumber.length > 11 ||
        userPhoneNumber.length < 10 ||
        userPhoneNumber == null ||
        userPhoneNumber.isEmpty) {
      displaySnackBarError("10???????????????????????????????????????????????????");

      return;
    }

    // store phone number validation
    if ((bussinessForm == "?????????????????? ?????????????????????" ||
            bussinessForm == "?????????????????? ???????????????????????????????????????") &&
        (storenumber == null || storenumber.isEmpty)) {
      displaySnackBarError("???????????????????????????????????????????????????");

      return;
    }

    if ((bussinessForm == "?????????????????? ?????????????????????" ||
            bussinessForm == "?????????????????? ???????????????????????????????????????") &&
        (storenumber.length > 11 ||
            storenumber.length < 10 ||
            storenumber == null ||
            storenumber.isEmpty)) {
      displaySnackBarError("10????????????????????????????????????????????????????????????");

      return;
    }

    if ((bussinessForm == "?????????????????? ?????????????????????" ||
            bussinessForm == "?????????????????? ???????????????????????????????????????") &&
        storenumber.substring(0, 1) == '0' &&
        storenumber.length <= 10) {
      displaySnackBarError("????????????????????????????????????????????????????????????");

      return;
    }

    //email validation
    if ((email == null || email.isEmpty)) {
      displaySnackBarError("???????????????????????????????????????????????????");

      return;
    }

    if (!(email.contains(regexMail))) {
      displaySnackBarError("????????????????????????????????????????????????????????????");

      return;
    }
    if (email.length > 50) {
      displaySnackBarError("????????????????????????50??????????????????????????????????????????");

      return;
    }
    if ((email.contains(regexEmojis))) {
      displaySnackBarError("????????????????????????????????????????????????????????????");

      return;
    }

    //manual address Validation
    if ((manualAddresss == null || manualAddresss.isEmpty)) {
      displaySnackBarError("???????????????????????????????????????");

      return;
    }

    //prefecture Validation
    if ((myState == null || myState.isEmpty)) {
      displaySnackBarError("?????????????????????????????????????????????");

      return null;
    }

    //city validation
    if ((myCity == null || myCity.isEmpty)) {
      displaySnackBarError("??????????????????????????????????????????");

      return null;
    }

    //building Validation
    if (buildingname.length > 20) {
      displaySnackBarError("????????????20??????????????????????????????????????????");

      return;
    }

    //roomno length Validation
    if (roomnumber.length > 4) {
      displaySnackBarError("4???????????????????????????????????????????????????");

      return;
    }

    if (bankname == null || bankname == '') {
      displaySnackBarError("????????????????????????????????????????????????????????????");

      return;
    }

    if (bankname == '?????????' &&
        (bankOtherFieldController.text == '' ||
            bankOtherFieldController.text == null)) {
      displaySnackBarError("????????????????????????????????????????????????????????????");

      return;
    }

    if (bankname == '?????????' && bankOtherFieldController.text.length > 25) {
      displaySnackBarError("????????????????????????????????????????????????");

      return;
    }

    if (accountType == null || accountType == '') {
      displaySnackBarError("???????????????????????????????????????????????????????????????");

      return;
    }

    if (branchNameController.text == null || branchNameController.text == '') {
      displaySnackBarError("???????????????????????????????????????");

      return;
    }

    if (branchNameController.text.length > 20) {
      displaySnackBarError("????????????20??????????????????????????????????????????");

      return;
    }

    if (branchNumberController.text == null ||
        branchNumberController.text == '') {
      displaySnackBarError("??????????????????????????????????????????");

      return;
    }

    if (branchNumberController.text.length > 3 ||
        branchNumberController.text.length < 3) {
      displaySnackBarError("3???????????????????????????????????????????????????");

      return;
    }
    if (bankNumberController.text == null || bankNumberController.text == '') {
      displaySnackBarError("??????????????????????????????????????????");

      return;
    }

    if (bankNumberController.text.length > 4 ||
        bankNumberController.text.length < 4) {
      displaySnackBarError("4???????????????????????????????????????????????????");

      return;
    }

    if (accountnumberController.text == null ||
        accountnumberController.text == '') {
      displaySnackBarError("??????????????????????????????????????????");

      return;
    }

    if (accountnumberController.text.length > 8 ||
        accountnumberController.text.length < 7) {
      displaySnackBarError("7-8???????????????????????????????????????????????????");

      return;
    }

    if (accountHolderNameController.text == null ||
        accountHolderNameController.text == '') {
      displaySnackBarError("?????????????????????????????????????????????????????????????????????????????????");

      return;
    }

    if (accountHolderNameController.text.length > 20) {
      displaySnackBarError("????????????????????????????????????20??????????????????????????????????????????");

      return;
    }

    if (accountHolderType == null || accountHolderType == '') {
      displaySnackBarError("??????????????????????????????????????????????????????????????????");

      return;
    }

    /*  //certificate Validation
    if (certificateImages.isEmpty &&
        qualification != "?????????" &&
        privateQualification.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ColorConstants.snackBarColor,
        content: Text('???????????????????????????????????????????????????????????????',
            style: TextStyle(fontFamily: 'NotoSansJP')),
        action: SnackBarAction(
            onPressed: () {
              _scaffoldKey.currentState.hideCurrentSnackBar();
            },
            label: '??????',
            textColor: Colors.white),
      ));
      return;
    } */

    //Save Values to Constants
    HealingMatchConstants.profileImage = _profileImage;
    HealingMatchConstants.serviceProviderUserName = userName;
    HealingMatchConstants.serviceProviderStoreName = storename;
    HealingMatchConstants.serviceProviderDOB = userDOBController.text;
    HealingMatchConstants.serviceProviderAge = age;
    HealingMatchConstants.serviceProviderGender = gender;
    HealingMatchConstants.serviceProviderPhoneNumber = userPhoneNumber;
    HealingMatchConstants.serviceProviderStorePhoneNumber = storenumber;
    HealingMatchConstants.serviceProviderEmailAddress = email;
    HealingMatchConstants.serviceProviderBuildingName = buildingname;
    HealingMatchConstants.serviceProviderRoomNumber = roomnumber;
    HealingMatchConstants.serviceProviderBusinessForm = bussinessForm;
    HealingMatchConstants.serviceProviderNumberOfEmpl = numberOfEmployees;
    HealingMatchConstants.serviceProviderStoreType.clear();
    HealingMatchConstants.serviceProviderStoreType
        .addAll(selectedStoreTypeDisplayValues);
    HealingMatchConstants.serviceProviderBusinessTripService =
        serviceBusinessTrips;
    HealingMatchConstants.serviceProviderCoronaMeasure = coronaMeasures;
    HealingMatchConstants.serviceProviderChildrenMeasure.clear();
    HealingMatchConstants.serviceProviderChildrenMeasure
        .addAll(childrenMeasuresDropDownValuesSelected);
    HealingMatchConstants.serviceProviderGenderService = genderTreatment;

    String address = buildingname != null || buildingname != ''
        ? myState +
            ' ' +
            myCity +
            ' ' +
            manualAddresss +
            ' ' +
            buildingname +
            ' ' +
            roomnumber
        : myState + ' ' + myCity + ' ' + manualAddresss + ' ' + roomnumber;

    String query = myCity + ',' + myState;
    try {
      List<Location> locations =
          await locationFromAddress(query, localeIdentifier: "ja_JP");
      HealingMatchConstants.serviceProviderCurrentLatitude =
          locations[0].latitude;
      print("Lat: ${HealingMatchConstants.serviceProviderCurrentLatitude}");
      HealingMatchConstants.serviceProviderCurrentLongitude =
          locations[0].longitude;
      print("Long??: ${HealingMatchConstants.serviceProviderCurrentLongitude}");

      HealingMatchConstants.serviceProviderAddress = address;
      HealingMatchConstants.serviceProviderPrefecture = myState;
      HealingMatchConstants.serviceProviderCity = myCity;
      HealingMatchConstants.serviceProviderArea = manualAddresss;
      updateProfile();
    } catch (e) {
      displaySnackBarError("??????????????????????????????????????????????????????????????????");

      return;
    }
  }

  void displaySnackBarError(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: ColorConstants.snackBarColor,
      content: Text('$text', style: TextStyle(fontFamily: 'NotoSansJP')),
      action: SnackBarAction(
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
          label: '??????',
          textColor: Colors.white),
    ));
    ProgressDialogBuilder.hideUserDetailsUpdateProgressDialog(context);
  }

  void updateProfile() async {
    String qualification = '';

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int i = 0;
    List<MultipartFile> multipartList = new List<MultipartFile>();

    certificateImages.forEach((key, value) {
      if (i == 0) {
        qualification = key;
      } else {
        qualification = qualification + "," + key;
      }
      i++;
    });

    if (privateQualification.length != 0 &&
        !(oldPrivateQualification.length == 0)) {
      if (qualification != '') {
        qualification = qualification + "," + '????????????';
      } else {
        qualification = '????????????';
      }
    }

    qualification = qualification == ""
        ? userData.qulaificationCertImgUrl
        : userData.qulaificationCertImgUrl == "?????????" ||
                userData.qulaificationCertImgUrl == "?????????,"
            ? qualification
            : userData.qulaificationCertImgUrl + "," + qualification;

    String childrenMeasure = '';
    if (HealingMatchConstants.serviceProviderChildrenMeasure.isEmpty) {
      childrenMeasure = '';
    } else {
      for (int i = 0;
          i < HealingMatchConstants.serviceProviderChildrenMeasure.length;
          i++) {
        if (i == 0) {
          childrenMeasure =
              HealingMatchConstants.serviceProviderChildrenMeasure[0];
        } else {
          childrenMeasure = childrenMeasure +
              "," +
              HealingMatchConstants.serviceProviderChildrenMeasure[i];
        }
      }
    }

    updateAddressValues();

    updateBankValues();

    String storeTypeDisplay = '';
    if (HealingMatchConstants.serviceProviderStoreType.isEmpty) {
      storeTypeDisplay = '';
    } else {
      for (int i = 0;
          i < HealingMatchConstants.serviceProviderStoreType.length;
          i++) {
        if (i == 0) {
          storeTypeDisplay = HealingMatchConstants.serviceProviderStoreType[0];
        } else {
          storeTypeDisplay = storeTypeDisplay +
              "," +
              HealingMatchConstants.serviceProviderStoreType[i];
        }
      }
    }

    var headers = {
      'Content-Type': 'application/json',
      'x-access-token': HealingMatchConstants.accessToken
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(HealingMatchConstants.UPDATE_PROVIDER_DETAILS_URL));
    request.fields.addAll({
      'id': userData.id.toString(),
      'isTherapist': '1',
      'email': HealingMatchConstants.serviceProviderEmailAddress,
      /* 'storeName': bussinessForm == "?????????????????? ?????????????????????" ||
              bussinessForm == "?????????????????? ???????????????????????????????????????"
          ? HealingMatchConstants.serviceProviderStoreName
          : '', */
      /*  'storePhone': bussinessForm == "?????????????????? ?????????????????????" ||
              bussinessForm == "?????????????????? ????????????????????????????????????)"
          ? HealingMatchConstants.serviceProviderStorePhoneNumber
          : '0', */
      'genderOfService':
          HealingMatchConstants.serviceProviderGenderService != null
              ? HealingMatchConstants.serviceProviderGenderService
              : '',
      'storeType': storeTypeDisplay,
      'numberOfEmp': (bussinessForm == "?????????????????? ?????????????????????" ||
                  bussinessForm == "?????????????????? ????????????????????????????????????)") &&
              HealingMatchConstants.serviceProviderNumberOfEmpl != null
          ? HealingMatchConstants.serviceProviderNumberOfEmpl
          : '0',
      'businessTrip':
          HealingMatchConstants.serviceProviderBusinessTripService == "????????????"
              ? '1'
              : '0',
      'coronaMeasure':
          HealingMatchConstants.serviceProviderCoronaMeasure == "??????"
              ? '1'
              : '0',

      'childrenMeasure': childrenMeasure,
      'businessForm': HealingMatchConstants.serviceProviderBusinessForm,
      'bankDetails': json.encode(userData.bankDetails),
      'addressTypeSelection': "????????????",
      'address': json.encode(userData.addresses), //address update in json
      "isShop": HealingMatchConstants.serviceProviderBusinessForm ==
                  "?????????????????? ?????????????????????" ||
              HealingMatchConstants.serviceProviderBusinessForm ==
                  "?????????????????? ???????????????????????????????????????"
          ? "true"
          : "false",
      'qulaificationCertImgUrl': qualification,
    });
    if (bussinessForm == "?????????????????? ?????????????????????" ||
        bussinessForm == "?????????????????? ???????????????????????????????????????") {
      request.fields.addAll({
        "storePhone": HealingMatchConstants.serviceProviderStorePhoneNumber,
        'storeName': HealingMatchConstants.serviceProviderStoreName,
      });
    } else {
      request.fields.addAll({
        'storeName': "",
      });
    }
    if (deletedStoreTypeDisplayValues.isNotEmpty) {
      var keys = deletedStoreTypeDisplayValues.keys;
      for (var key in keys) {
        switch (key) {
          case "?????????":
            request.fields.addAll({"deleteEsthetic": "1"});
            break;
          case "???????????????":
            request.fields.addAll({"deleteOrteopathic": "1"});
            break;
          case "????????????????????????":
            request.fields.addAll({"deleteRelaxation": "1"});
            break;
          case "??????????????????":
            request.fields.addAll({"deleteFitness": "1"});
            break;
        }
      }
    }
    /* if (storePhoneNumberController.text != '' &&
        storePhoneNumberController.text != null) {
      request.fields.addAll({
        'storePhone': HealingMatchConstants.serviceProviderStorePhoneNumber
      });
    } else {
      request.fields.addAll({'storePhone': ''});
    } */
    if (userData.qulaificationCertImgUrl != null &&
        userData.qulaificationCertImgUrl != '') {
      if (qualification != '') {
        request.fields.addAll({
          'qulaificationCertImgUrl':
              userData.qulaificationCertImgUrl + ',' + qualification
        });
      } else {
        request.fields.addAll(
            {'qulaificationCertImgUrl': userData.qulaificationCertImgUrl});
      }
    } else {
      request.fields.addAll({'qulaificationCertImgUrl': qualification});
    }

    //Upload Profile Image if not null
    if (HealingMatchConstants.profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'uploadProfileImgUrl', HealingMatchConstants.profileImage.path));
    }

    //Upload Certificate Files
    certificateImages.forEach((key, value) async {
      request.files.add(await http.MultipartFile.fromPath(key, value));
      print('abc');
    });

    //Upload Private Qualification Images
    int privateQualificationLength = oldPrivateQualification.length + 1;
    for (var certificate in privateQualification) {
      request.files.add(await http.MultipartFile.fromPath(
          'privateQualification' + (privateQualificationLength++).toString(),
          certificate));
    }
    request.headers.addAll(headers);

    try {
      final userDetailsRequest = await request.send();
      print("This is request : ${userDetailsRequest.request}");
      final response = await http.Response.fromStream(userDetailsRequest);
      print("This is response: ${response.statusCode}\n${response.body}");
      if (StatusCodeHelper.isProfileUpdateSuccess(
          response.statusCode, context, response.body)) {
        loginResponse.LoginResponseModel loginResponseModel =
            loginResponse.LoginResponseModel.fromJson(
                json.decode(response.body));
        sharedPreferences.setString(
            "userData", json.encode(loginResponseModel.data));
        HealingMatchConstants.userData = loginResponseModel.data;
        HealingMatchConstants.numberOfEmployeeRegistered =
            HealingMatchConstants.userData.numberOfEmp;
        ProgressDialogBuilder.hideUserDetailsUpdateProgressDialog(context);
        print('Update response : ${loginResponseModel.toJson()}');
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        String firebaseUserId = firebaseAuth.currentUser.uid;
        Map<String, dynamic> updateProviderDetails = {
          "imageUrl": loginResponseModel.data.uploadProfileImgUrl,
          "username": HealingMatchConstants.serviceProviderBusinessForm ==
                      "?????????????????? ?????????????????????" ||
                  HealingMatchConstants.serviceProviderBusinessForm ==
                      "?????????????????? ???????????????????????????????????????"
              ? loginResponseModel.data.storeName
              : loginResponseModel.data.userName,
          'searchKey': HealingMatchConstants.serviceProviderBusinessForm ==
                      "?????????????????? ?????????????????????" ||
                  HealingMatchConstants.serviceProviderBusinessForm ==
                      "?????????????????? ???????????????????????????????????????"
              ? loginResponseModel.data.storeName.toLowerCase()
              : loginResponseModel.data.userName.toLowerCase(),
        };
        DB db = DB();
        db.updateUserOnlineInfo(firebaseUserId, updateProviderDetails);
        DialogHelper.showProviderProfileUpdatedSuccessDialog(context);
      } else {
        ProgressDialogBuilder.hideUserDetailsUpdateProgressDialog(context);
        print('Response error occured!');
      }
    } on SocketException catch (_) {
      //handle socket Exception
      ProgressDialogBuilder.hideUserDetailsUpdateProgressDialog(context);
      NavigationRouter.switchToNetworkHandler(context);
      print('Network error !!');
    } catch (e) {
      //handle other error
      print("Error $e");
      ProgressDialogBuilder.hideUserDetailsUpdateProgressDialog(context);
    }
  }

  void updateBankValues() {
    userData.bankDetails[0].userId = userData.id;
    userData.bankDetails[0].bankName =
        bankname == HealingMatchConstants.registrationBankOtherDropdownFiled
            ? bankOtherFieldController.text
            : bankname;
    userData.bankDetails[0].bankCode = bankNumberController.text;
    userData.bankDetails[0].branchName = branchNameController.text;
    userData.bankDetails[0].branchNumber = branchNumberController.text;
    userData.bankDetails[0].accountNumber = accountnumberController.text;
    userData.bankDetails[0].accountType = accountType;
    userData.bankDetails[0].accountHolderType = accountHolderType;
    userData.bankDetails[0].accountHolderName =
        accountHolderNameController.text;
    userData.bankDetails[0].updatedAt = DateTime.now();
  }

  void updateAddressValues() {
    userData.addresses[0].address =
        HealingMatchConstants.serviceProviderAddress;
    userData.addresses[0].area = HealingMatchConstants.serviceProviderArea;
    userData.addresses[0].buildingName =
        HealingMatchConstants.serviceProviderBuildingName;
    userData.addresses[0].userRoomNumber =
        HealingMatchConstants.serviceProviderRoomNumber;
    userData.addresses[0].cityName = HealingMatchConstants.serviceProviderCity;
    userData.addresses[0].capitalAndPrefecture =
        HealingMatchConstants.serviceProviderPrefecture;
    userData.addresses[0].lat =
        HealingMatchConstants.serviceProviderCurrentLatitude;
    userData.addresses[0].lon =
        HealingMatchConstants.serviceProviderCurrentLongitude;

    userData.addresses[0].citiesId = cityDropDownValues.indexOf(myCity) + 1;
    userData.addresses[0].capitalAndPrefectureId =
        stateDropDownValues.indexOf(myState) + 1;
  }

  void _showPicker(context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('????????????????????????????????????'),
                      onTap: () {
                        _imgFromGallery(index);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('???????????????????????????'),
                    onTap: () {
                      _imgFromCamera(index);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera(int index) async {
    PickedFile pickedFile;
    final image = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);

    setState(() {
      pickedFile = image;
      if (index == 0) {
        _profileImage = pickedFile;
      } else {
        if (qualification == "????????????") {
          privateQualification.add(pickedFile.path);
          uploadVisible = false;
        } else {
          certificateImages[qualification] = pickedFile.path;
        }
      }
    });
    print('image path : ${pickedFile.path}');
  }

  _imgFromGallery(int index) async {
    PickedFile pickedFile;
    final image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      pickedFile = image;
      if (index == 0) {
        _profileImage = pickedFile;
      } else {
        if (qualification == "????????????") {
          privateQualification.add(pickedFile.path);
          uploadVisible = false;
        } else {
          certificateImages[qualification] = pickedFile.path;
        }
      }
    });
    print('image path : ${pickedFile.path}');
  }

  // CityList cityResponse;
  _getCityDropDown(var prefid) async {
    ProgressDialogBuilder.showGetCitiesProgressDialog(context);
    await post(HealingMatchConstants.CITY_PROVIDER_URL,
        body: {"prefecture_id": prefid.toString()}).then((response) {
      if (response.statusCode == 200) {
        CityList cityResponse = CityList.fromJson(json.decode(response.body));
        print(cityResponse.toJson());
        for (var cityList in cityResponse.data) {
          cityDropDownValues.add(cityList.cityJa + cityList.specialDistrictJa);
          print(cityDropDownValues);
        }
        ProgressDialogBuilder.hideGetCitiesProgressDialog(context);
        setState(() {
          //  myCity = userData.addresses[0].cityName;
        });
      }
    });
  }

  Widget buildChildrenMeasureCheckBoxContent(
      String childrenMeasuresValue, int index) {
    bool checkValue =
        childrenMeasuresDropDownValuesSelected.contains(childrenMeasuresValue);
    return Column(
      children: [
        Row(
          children: [
            checkValue
                ? Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Checkbox(
                      tristate: true,
                      activeColor: Colors.black,
                      checkColor: Colors.black,
                      value: checkValue,
                      onChanged: (value) {
                        if (value == null) {
                          setState(() {
                            childrenMeasuresDropDownValuesSelected
                                .remove(childrenMeasuresValue);
                          });
                        } else {
                          setState(() {
                            childrenMeasuresDropDownValuesSelected
                                .add(childrenMeasuresValue);
                          });
                        }
                      },
                    ),
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        childrenMeasuresDropDownValuesSelected
                            .add(childrenMeasuresValue);
                      });
                    },
                    child: Container(
                      height: 25.0,
                      width: 25.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[400],
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
            SizedBox(
              width: 10.0,
            ),
            Text("$childrenMeasuresValue", style: TextStyle(fontSize: 14.0)),
          ],
        ),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  Widget buildStoreTypeDisplayBoxContent(
      String storeTypeDisplayValues, int index) {
    bool checkValue =
        selectedStoreTypeDisplayValues.contains(storeTypeDisplayValues);
    return Column(
      children: [
        Row(
          children: [
            checkValue
                ? Container(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Checkbox(
                      tristate: true,
                      activeColor: Colors.black,
                      checkColor: Colors.black,
                      value: checkValue,
                      onChanged: (value) {
                        /*  setState(() {
                          checkValue = value;
                        }); */
                        if (value == null) {
                          setState(() {
                            selectedStoreTypeDisplayValues
                                .remove(storeTypeDisplayValues);
                            deletedStoreTypeDisplayValues[
                                    storeTypeDisplayValues] =
                                storeTypeDisplayValues;
                          });
                        } else {
                          setState(() {
                            selectedStoreTypeDisplayValues
                                .add(storeTypeDisplayValues);
                            if (deletedStoreTypeDisplayValues[
                                    storeTypeDisplayValues] !=
                                null) {
                              deletedStoreTypeDisplayValues
                                  .remove(storeTypeDisplayValues);
                            }
                          });
                        }
                      },
                    ),
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        selectedStoreTypeDisplayValues
                            .add(storeTypeDisplayValues);
                        if (deletedStoreTypeDisplayValues[
                                storeTypeDisplayValues] !=
                            null) {
                          deletedStoreTypeDisplayValues
                              .remove(storeTypeDisplayValues);
                        }
                      });
                    },
                    child: Container(
                      height: 25.0,
                      width: 25.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[400],
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
            SizedBox(
              width: 10.0,
            ),
            Text("$storeTypeDisplayValues", style: TextStyle(fontSize: 14.0)),
          ],
        ),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  void _showPicker1(context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('?????????????????????????????????'),
                      onTap: () {
                        _imgFromGallery1(index);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('????????????????????????'),
                    onTap: () {
                      _imgFromCamera1(index);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera1(int index) async {
    final image = await ImagePicker().getImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);

    setState(() {
      _profileImage = image;
      if (index == 0) {
        _idProfileImage = _profileImage;
      } else {
        if (qualification == "????????????") {
          privateQualification.add(_profileImage.path);
          uploadVisible = false;
        } else {
          certificateImages[qualification] = _profileImage.path;
        }
      }
    });
    print('image path : ${_profileImage.path}');
  }

  _imgFromGallery1(int index) async {
    final image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _profileImage = image;
      if (index == 0) {
        _idProfileImage = _profileImage;
      } else {
        if (qualification == "????????????") {
          privateQualification.add(_profileImage.path);
          uploadVisible = false;
        } else {
          certificateImages[qualification] = _profileImage.path;
        }
      }
    });
    print('image path : ${_profileImage.path}');
  }

  void showProgressDialog() {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*  _progressDialog.showProgressDialog(context,
        textToBeDisplayed: '??????????????????????????????...', dismissAfter: Duration(seconds: 5)); */
  }

  void hideProgressDialog() {
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
    /* _progressDialog.dismissProgressDialog(context); */
  }

  void showIdSelectError() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: ColorConstants.snackBarColor,
      content: Text('??????????????????????????????????????????1??????????????????',
          style: TextStyle(fontFamily: 'NotoSansJP')),
      action: SnackBarAction(
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
          label: '??????',
          textColor: Colors.white),
    ));
    return;
  }

  void showCertificateImageError() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: ColorConstants.snackBarColor,
      content: Text('?????????????????????????????????????????????5??????????????????',
          style: TextStyle(fontFamily: 'NotoSansJP')),
      action: SnackBarAction(
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
          label: '??????',
          textColor: Colors.white),
    ));
    return;
  }

  void getBankName() async {
    await http
        .get(HealingMatchConstants.REGISTER_PROVIDER_GET_BANK_LIST_URL)
        .then((response) {
      if (response.statusCode == 200) {
        bankNameDropDownModel =
            BankNameDropDownModel.fromJson(json.decode(response.body));
        for (var bankList in bankNameDropDownModel.data) {
          bankNameDropDownList.add(bankList.value);
        }
        setState(() {
          bankNameDropDownList
              .add(HealingMatchConstants.registrationBankOtherDropdownFiled);
          status = status + 1;
          print("b Status: $status");
          if (status == 2) {
            getProfileDetails();
          }
        });
      } else {
        print(response.reasonPhrase);
      }
    });
  }

  Widget buildOldQualificationImage(String key, int index) {
    String keyJaValue = getQualififcationJaWords(key);
    return Container(
      padding: EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                    padding: EdgeInsets.all(8),
                    width: 140.0, // MediaQuery.of(context).size.width * 0.38,
                    height: 140.0, //MediaQuery.of(context).size.height * 0.19,
                    decoration: new BoxDecoration(
                      //   border: Border.all(color: Colors.black12),
                      //   shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(oldCertificateImages[key]),
                      ),
                    )),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text("$keyJaValue"),
        ],
      ),
    );
  }

  Widget buildQualificationImage(String key, int index) {
    return Container(
      padding: EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                    padding: EdgeInsets.all(8),
                    width: 140.0, // MediaQuery.of(context).size.width * 0.38,
                    height: 140.0, //MediaQuery.of(context).size.height * 0.19,
                    decoration: new BoxDecoration(
                      //   border: Border.all(color: Colors.black12),
                      //   shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(certificateImages[key])),
                      ),
                    )),
              ),
              Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          certificateImages.remove(key);
                        });
                      },
                      child: CircleAvatar(
                        radius: 15.0,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.close_outlined,
                          color: Colors.black,
                          size: 20.0,
                        ),
                      )))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text("$key"),
        ],
      ),
    );
  }

  Widget buildPrivateQualificationImage(
      String privateQualificationImage, int index) {
    return Container(
      padding: EdgeInsets.only(
          left:
              16.0 /*  index == 0 &&
                  (oldCertificateImages.length == 0 &&
                      certificateImages.length == 0)
              ? 16.0
              : 0.0 */
          ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                    padding: EdgeInsets.all(8),
                    width: 140.0, // MediaQuery.of(context).size.width * 0.38,
                    height: 140.0, //MediaQuery.of(context).size.height * 0.19,
                    decoration: new BoxDecoration(
                      //   border: Border.all(color: Colors.black12),
                      //   shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(privateQualificationImage)),
                      ),
                    )),
              ),
              Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          privateQualification.removeAt(index);
                        });
                      },
                      child: CircleAvatar(
                        radius: 15.0,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.close_outlined,
                          color: Colors.black,
                          size: 20.0,
                        ),
                      )))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text("????????????"),
        ],
      ),
    );
  }

  void getProfileDetails() {
    var certificateUpload;
    userData = HealingMatchConstants.userData;
    bussinessForm = userData.businessForm;
    if (userData.numberOfEmp != 0) {
      numberOfEmployees = userData.numberOfEmp.toString();
    }
    selectedStoreTypeDisplayValues = userData.storeType.split(',');

    serviceBusinessTrips = userData.businessTrip ? '????????????' : '????????????';
    if (bussinessForm == "?????????????????? ????????????????????????????????????)" ||
        bussinessForm == "?????????????????? ??????????????????????????????)") {
      businessTripEnabled = false;
    }
    coronaMeasures = userData.coronaMeasure ? '??????' : '?????????';
    if (userData.childrenMeasure != null && userData.childrenMeasure != '') {
      childrenMeasuresDropDownValuesSelected =
          userData.childrenMeasure.split(',');
    }
    genderTreatment = userData.genderOfService;
    providerNameController.text = userData.userName;
    storeNameController.text =
        userData.storeName != null ? userData.storeName : '';
    userDOBController.text =
        DateFormat("yyyy-MM-dd").format(userData.dob).toString();
    ageController.text = userData.age.toString();
    gender = userData.gender;
    phoneNumberController.text = userData.phoneNumber.toString();
    if (/* userData.storePhone.toString() != '' && */
        userData.storePhone != null && userData.storePhone != 0) {
      storePhoneNumberController.text = userData.storePhone.toString();
    }
    mailAddressController.text = userData.email;
    manualAddressController.text = userData.addresses[0].area;
    //   myCity = userData.addresses[0].cityName;
    myState = userData.addresses[0].capitalAndPrefecture;
    _prefid = stateDropDownValues.indexOf(myState) + 1;
    _getCityDropDown(_prefid);

    identificationverify = userData.proofOfIdentityType;
    if (userData.qulaificationCertImgUrl == "?????????") {
      visible = true;
      qualification = userData.qulaificationCertImgUrl;
    }
    roomNumberController.text = userData.addresses[0].userRoomNumber;
    buildingNameController.text = userData.addresses[0].buildingName;
    if (userData.bankDetails.isNotEmpty) {
      if (bankNameDropDownList.contains(userData.bankDetails[0].bankName)) {
        bankname = userData.bankDetails[0].bankName;
      } else {
        bankname = HealingMatchConstants.registrationBankOtherDropdownFiled;
        bankOtherFieldController.text = userData.bankDetails[0].bankName;
      }
      accountType = userData.bankDetails[0].accountType;
      accountnumberController.text = userData.bankDetails[0].accountNumber;
      branchNameController.text = userData.bankDetails[0].branchName;
      branchNumberController.text = userData.bankDetails[0].branchNumber;
      accountHolderNameController.text =
          userData.bankDetails[0].accountHolderName;
      accountHolderType = userData.bankDetails[0].accountHolderType;
      bankNumberController.text = userData.bankDetails[0].bankCode;
    }

    userData = HealingMatchConstants.userData;
    certificateUpload = userData.certificationUploads[0].toJson();
    certificateUpload.remove('id');
    certificateUpload.remove('userId');
    certificateUpload.remove('createdAt');
    certificateUpload.remove('updatedAt');
    certificateUpload.forEach((key, value) async {
      if (certificateUpload[key] != null) {
        oldCertificateImages[key] = value;
        if (getQualififcationJaWords(key) == "????????????") {
          oldPrivateQualification.add(value);
        }
      }
    });
    //remove unqualified value from dropddown if certififcate already uploaded
    if (oldCertificateImages.length != 0) {
      qualificationCertificates.removeLast();
    }
    setState(() {
      status = 3;
      myCity = userData.addresses[0].cityName;
    });
  }

  _getState() async {
    await http.get(HealingMatchConstants.STATE_PROVIDER_URL).then((response) {
      states = StatesList.fromJson(json.decode(response.body));
      for (var stateList in states.data) {
        stateDropDownValues.add(stateList.prefectureJa);
      }
      setState(() {
        status = status + 1;
        print("s Status: $status");
        if (status == 2) {
          getProfileDetails();
        }
      });
    });
  }

  String getQualififcationJaWords(String key) {
    switch (key) {
      case 'acupuncturist':
        return '?????????';
        break;
      case 'moxibutionist':
        return '????????????';
        break;
      case 'acupuncturistAndMoxibustion':
        return '?????????';
        break;
      case 'anmaMassageShiatsushi':
        return '?????????????????????????????????';
        break;
      case 'judoRehabilitationTeacher':
        return '???????????????';
        break;
      case 'physicalTherapist':
        return '???????????????';
        break;
      case 'acquireNationalQualifications':
        return '????????????????????????????????????';
        break;
      case 'privateQualification1':
        return '????????????';
      case 'privateQualification2':
        return '????????????';
      case 'privateQualification3':
        return '????????????';
      case 'privateQualification4':
        return '????????????';
      case 'privateQualification5':
        return '????????????';
        break;
    }
  }

  String getQualififcationEngWords(String key) {
    switch (key) {
      case '?????????':
        return 'acupuncturist';
        break;
      case '????????????':
        return 'moxibutionist';
        break;
      case '?????????':
        return 'acupuncturistAndMoxibustion';
        break;
      case '?????????????????????????????????':
        return 'anmaMassageShiatsushi';
        break;
      case '???????????????':
        return 'judoRehabilitationTeacher';
        break;
      case '???????????????':
        return 'physicalTherapist';
        break;
      case '????????????????????????????????????':
        return 'acquireNationalQualifications';
        break;
      case '????????????':
        return 'privateQualification1';
        break;
    }
  }
}
