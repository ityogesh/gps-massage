import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/alertDialogHelper/dialogHelper.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/dropdowns/dropDownServiceUserRegisterScreen.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/register/cityListResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/register/stateListResponseModel.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<dynamic> addressValues = List();
final addedFirstAddressController = new TextEditingController();
final addedSecondSubAddressController = new TextEditingController();
final addedThirdController = new TextEditingController();

class UpdateServiceUserDetails extends StatefulWidget {
  @override
  _UpdateServiceUserDetailsState createState() =>
      _UpdateServiceUserDetailsState();
}

class _UpdateServiceUserDetailsState extends State<UpdateServiceUserDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressFields();
  }

  Future<SharedPreferences> _sharedPreferences =
      SharedPreferences.getInstance();
  var userAddressType = '';
  final _searchRadiusKey = new GlobalKey<FormState>();
  String _mySearchRadiusDistance = '';
  final formKey = GlobalKey<FormState>();
  TextEditingController _userDOBController = new TextEditingController();

  String _selectedDOBDate = 'Tap to select date';
  final Geolocator geoLocator = Geolocator()..forceAndroidLocationManager;
  final Geolocator addAddressgeoLocator = Geolocator()
    ..forceAndroidLocationManager;
  Position _currentPosition;
  Position _addAddressPosition;
  String _currentAddress = '';
  String _addedAddress = '';
  double age = 0.0;
  var selectedYear;
  final ageController = TextEditingController();
  var _ageOfUser = '';
  String _myGender = '';
  String _myOccupation = '';
  String _myAddressInputType = '';
  String _myAddedAddressInputType = '';
  String _myCategoryPlaceForMassage = '';
  String _myPrefecture = '';
  String _myCity = '';
  String _myAddedPrefecture = '';
  String _myAddedCity = '';
  File _profileImage;
  final picker = ImagePicker();
  Placemark currentLocationPlaceMark;
  Placemark userAddedAddressPlaceMark;

  bool _showCurrentLocationInput = false;
  bool _isLoggedIn = false;
  bool _isGPSLocation = false;
  bool _isAddedGPSLocation = false;
  final _registerUserFormKey = new GlobalKey<FormState>();
  final _genderKey = new GlobalKey<FormState>();
  final _occupationKey = new GlobalKey<FormState>();
  final _addressTypeKey = new GlobalKey<FormState>();
  final _addedAddressTypeKey = new GlobalKey<FormState>();
  final _addAddressKey = new GlobalKey<FormState>();
  final _placeOfAddressKey = new GlobalKey<FormState>();
  final _perfectureKey = new GlobalKey<FormState>();
  final _cityKey = new GlobalKey<FormState>();
  final _addedPrefectureKey = new GlobalKey<FormState>();
  final _addedCityKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final userNameController = new TextEditingController();
  final phoneNumberController = new TextEditingController();
  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();
  final confirmPasswordController = TextEditingController();
  final buildingNameController = new TextEditingController();
  final userAreaController = new TextEditingController();
  final gpsAddressController = new TextEditingController();
  final roomNumberController = new TextEditingController();

  final additionalAddressController = new TextEditingController();

  //final gpsAddressController = new TextEditingController();

  bool _changeProgressText = false;

  List<dynamic> stateDropDownValues = List();
  List<dynamic> cityDropDownValues = List();

  List<dynamic> addedAddressStateDropDownValues = List();
  List<dynamic> addedAddressCityDropDownValues = List();

  StatesListResponseModel states;
  CitiesListResponseModel cities;
  var _prefId, _addedAddressPrefId;
  int _count = 0;

  //CityListResponseModel city;

  _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        //locale : const Locale("ja","JP"),
        initialDatePickerMode: DatePickerMode.day,
        initialDate: DateTime.now(),
        firstDate: DateTime(1901, 1),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _selectedDOBDate = new DateFormat("yyyy-MM-dd").format(picked);
        _userDOBController.value =
            TextEditingValue(text: _selectedDOBDate.toString());
        //print(_selectedDOBDate);
        selectedYear = picked.year;
        calculateAge();
      });
    }
  }

  void calculateAge() {
    setState(() {
      age = (DateTime.now().year - selectedYear).toDouble();
      _ageOfUser = age.toString();
      //print('Age : $ageOfUser');
      ageController.value = TextEditingValue(text: age.toStringAsFixed(0));
    });
  }

  //Regex validation for Username
  RegExp regExpUserName = new RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');

  //numeric check user name
  RegExp _numeric = RegExp(r'^-?[0-9]+$');

  //Regex validation for Email address
  RegExp regexMail = new RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  //Regex validation for emojis in text
  RegExp regexEmojis = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  //finding Japanese characters in text regex
  RegExp regexJapanese =
      RegExp(r'(/[一-龠]+|[ぁ-ゔ]+|[ァ-ヴー]+|[a-zA-Z0-9]+|[ａ-ｚＡ-Ｚ０-９]+|[々〆〤]+/u)');

  // Password combination
  /*r'^
  (?=.*[A-Z])       // should contain at least one upper case
  (?=.*[a-z])       // should contain at least one lower case
  (?=.*?[0-9])          // should contain at least one digit
  (?=.*?[!@#\$&*~]).{8,}  // should contain at least one Special character
  $*/
  // Password combination ==> r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$'

  //..old regex pattern
  /*RegExp passwordRegex = new RegExp(
      r'^(?=.*[0-9])(?=.*[A-Za-z])(?=.*[~!?@#$%^&*_-])[A-Za-z0-9~!?@#$%^&*_-]{8,40}$');*/

//..updated regex pattern
  RegExp passwordRegex = new RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[~!?@#$%^&*_-]).{8,}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'マイアカウント',
          style: TextStyle(
              fontFamily: 'Oxygen',
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Form(
            key: _registerUserFormKey,
            child: ListView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      overflow: Overflow.visible,
                      children: [
                        HealingMatchConstants.profileImageInBytes != null
                            ? InkWell(
                                onTap: () {
                                  _showPicker(context);
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
                                          image: MemoryImage(
                                              HealingMatchConstants
                                                  .profileImageInBytes),
                                        ),
                                      )),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  _showPicker(context);
                                },
                                child: new Container(
                                    width: 95.0,
                                    height: 95.0,
                                    decoration: new BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[200]),
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.none,
                                        image: new AssetImage(
                                            'assets/images_gps/user.png'),
                                      ),
                                    )),
                              ),
                        _profileImage != null
                            ? Visibility(
                                visible: false,
                                child: Positioned(
                                  right: -70.0,
                                  top: 65,
                                  left: 10.0,
                                  child: InkWell(
                                    onTap: () {},
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[500],
                                      radius: 13,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[100],
                                        radius: 12,
                                        child: Icon(Icons.edit,
                                            color: Colors.grey[400],
                                            size: 20.0),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Visibility(
                                visible: true,
                                child: Positioned(
                                  right: -70.0,
                                  top: 65,
                                  left: 10.0,
                                  child: InkWell(
                                    onTap: () {
                                      _showPicker(context);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[500],
                                      radius: 13,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[100],
                                        radius: 12,
                                        child: Icon(Icons.edit,
                                            color: Colors.grey[400],
                                            size: 20.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        //enableInteractiveSelection: false,
                        //maxLength: 20,
                        autofocus: false,
                        controller: userNameController,
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: ColorConstants.formFieldFillColor,
                          labelText: 'お名前',
                          //hintText: 'お名前 *',
                          /*hintStyle: TextStyle(
                            color: Colors.grey[400],
                          ),*/
                          labelStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oxygen',
                              fontSize: 14),
                          focusColor: Colors.grey[100],
                          border: HealingMatchConstants.textFormInputBorder,
                          focusedBorder:
                              HealingMatchConstants.textFormInputBorder,
                          disabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                          enabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              // height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.63,
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    //enableInteractiveSelection: false,
                                    controller: _userDOBController,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Oxygen'),
                                    cursorColor: Colors.redAccent,
                                    readOnly: true,
                                    decoration: new InputDecoration(
                                      filled: true,
                                      fillColor:
                                          ColorConstants.formFieldFillColor,
                                      labelText: '生年月日',
                                      hintText: '生年月日',
                                      hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14),
                                      labelStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      suffixIcon: Icon(
                                        Icons.calendar_today,
                                        color: Color.fromRGBO(211, 211, 211, 1),
                                      ),
                                      border: HealingMatchConstants
                                          .textFormInputBorder,
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
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            //age
                            Container(
                              // height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.20,
                              alignment: Alignment.topCenter,
                              child: TextFormField(
                                //enableInteractiveSelection: false,
                                controller: ageController,
                                autofocus: false,
                                readOnly: true,
                                decoration: new InputDecoration(
                                  filled: true,
                                  fillColor: ColorConstants.formFieldFillColor,
                                  labelText: '年齢',
                                  labelStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: 'Oxygen',
                                      fontSize: 14),
                                  border:
                                      HealingMatchConstants.textFormInputBorder,
                                  focusedBorder:
                                      HealingMatchConstants.textFormInputBorder,
                                  disabledBorder:
                                      HealingMatchConstants.textFormInputBorder,
                                  enabledBorder:
                                      HealingMatchConstants.textFormInputBorder,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // Drop down gender user
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0, right: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '性別',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Oxygen',
                                fontWeight: FontWeight.w300),
                          ),
                          Form(
                            key: _genderKey,
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                child: DropDownFormField(
                                  hintText: '性別',
                                  value: _myGender,
                                  onSaved: (value) {
                                    setState(() {
                                      _myGender = value;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _myGender = value;
                                      //print(_myBldGrp.toString());
                                    });
                                  },
                                  dataSource: [
                                    {
                                      "display": "男性",
                                      "value": "M",
                                    },
                                    {
                                      "display": "女性",
                                      "value": "F",
                                    },
                                    {
                                      "display": "どちらでもない",
                                      "value": "O",
                                    },
                                  ],
                                  textField: 'display',
                                  valueField: 'value',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // Drop down occupation user
                    Form(
                      key: _occupationKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: DropDownFormField(
                                hintText: '職業',
                                value: _myOccupation,
                                onSaved: (value) {
                                  setState(() {
                                    _myOccupation = value;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _myOccupation = value;
                                    //print(_myBldGrp.toString());
                                  });
                                },
                                dataSource: [
                                  {
                                    "display": "会社員",
                                    "value": "会社員",
                                  },
                                  {
                                    "display": "公務員",
                                    "value": "公務員",
                                  },
                                  {
                                    "display": "自営業",
                                    "value": "自営業",
                                  },
                                  {
                                    "display": "会社役員",
                                    "value": "会社役員",
                                  },
                                  {
                                    "display": "会社経営",
                                    "value": "会社経営",
                                  },
                                  {
                                    "display": "自由業",
                                    "value": "自由業",
                                  },
                                  {
                                    "display": "専業主婦（夫）",
                                    "value": "専業主婦（夫）",
                                  },
                                  {
                                    "display": "学生",
                                    "value": "学生",
                                  },
                                  {
                                    "display": "パート・アルバイト",
                                    "value": "パート・アルバイト",
                                  },
                                  {
                                    "display": "無職",
                                    "value": "無職",
                                  },
                                ],
                                textField: 'display',
                                valueField: 'value',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        //enableInteractiveSelection: false,
                        autofocus: false,
                        //maxLength: 10,
                        controller: phoneNumberController,
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: ColorConstants.formFieldFillColor,
                          labelText: '電話番号',
                          /*hintText: '電話番号 *',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                          ),*/
                          labelStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oxygen',
                              fontSize: 14),
                          focusColor: Colors.grey[100],
                          border: HealingMatchConstants.textFormInputBorder,
                          focusedBorder:
                              HealingMatchConstants.textFormInputBorder,
                          disabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                          enabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                        ),
                        // validator: (value) => _validateEmail(value),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        //enableInteractiveSelection: false,
                        autofocus: false,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: ColorConstants.formFieldFillColor,
                          labelText: 'メールアドレス',
                          labelStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'Oxygen',
                              fontSize: 14),
                          focusColor: Colors.grey[100],
                          border: HealingMatchConstants.textFormInputBorder,
                          focusedBorder:
                              HealingMatchConstants.textFormInputBorder,
                          disabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                          enabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                        ),
                        // validator: (value) => _validateEmail(value),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Drop down address input type
                    Form(
                      key: _addressTypeKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: DropDownFormField(
                                hintText: '検索地点の登録',
                                value: _myAddressInputType,
                                onSaved: (value) {
                                  setState(() {
                                    _myAddressInputType = value;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _myAddressInputType = value;
                                    if (_myAddressInputType != null &&
                                        _myAddressInputType
                                            .contains('現在地を取得する')) {
                                      gpsAddressController.clear();
                                      buildingNameController.clear();
                                      roomNumberController.clear();
                                      _showCurrentLocationInput = true;
                                      _getCurrentLocation();
                                    } else if (_myAddressInputType != null &&
                                        _myAddressInputType
                                            .contains('直接入力する')) {
                                      cityDropDownValues.clear();
                                      stateDropDownValues.clear();
                                      buildingNameController.clear();
                                      roomNumberController.clear();
                                      _myPrefecture = '';
                                      _myCity = '';
                                      _isGPSLocation = false;
                                      _showCurrentLocationInput = false;
                                      _getStates();
                                    }
                                    print(
                                        'Address type : ${_myAddressInputType.toString()}');
                                  });
                                },
                                dataSource: [
                                  {
                                    "display": "現在地を取得する",
                                    "value": "現在地を取得する",
                                  },
                                  {
                                    "display": "直接入力する",
                                    "value": "直接入力する",
                                  },
                                ],
                                textField: 'display',
                                valueField: 'value',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    _myAddressInputType.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Form(
                                key: _placeOfAddressKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        child: DropDownFormField(
                                          hintText: '登録する地点のカテゴリー ',
                                          value: _myCategoryPlaceForMassage,
                                          onSaved: (value) {
                                            setState(() {
                                              _myCategoryPlaceForMassage =
                                                  value;
                                            });
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              _myCategoryPlaceForMassage =
                                                  value;
                                            });
                                          },
                                          dataSource: [
                                            {
                                              "display": "自宅",
                                              "value": "自宅",
                                            },
                                            {
                                              "display": "オフィス",
                                              "value": "オフィス",
                                            },
                                            {
                                              "display": "実家",
                                              "value": "実家",
                                            },
                                            {
                                              "display": "その他（直接入力）",
                                              "value": "その他（直接入力）",
                                            },
                                          ],
                                          textField: 'display',
                                          valueField: 'value',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              !_showCurrentLocationInput
                                  ? SizedBox(height: 5)
                                  : SizedBox(height: 15),
                              Visibility(
                                visible: _showCurrentLocationInput,
                                child: Container(
                                  // height: MediaQuery.of(context).size.height * 0.07,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: TextFormField(
                                    controller: gpsAddressController,
                                    decoration: new InputDecoration(
                                      filled: true,
                                      fillColor:
                                          ColorConstants.formFieldFillColor,
                                      labelText: '現在地を取得する',
                                      /*hintText: '現在地を取得する *',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),*/
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.location_on, size: 28),
                                        onPressed: () {
                                          setState(() {
                                            _changeProgressText = true;
                                            print(
                                                'location getting.... : $_changeProgressText');
                                          });
                                          _getCurrentLocation();
                                        },
                                      ),
                                      labelStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12),
                                      focusColor: Colors.grey[100],
                                      border: HealingMatchConstants
                                          .textFormInputBorder,
                                      focusedBorder: HealingMatchConstants
                                          .textFormInputBorder,
                                      disabledBorder: HealingMatchConstants
                                          .textFormInputBorder,
                                      enabledBorder: HealingMatchConstants
                                          .textFormInputBorder,
                                    ),
                                    style: TextStyle(color: Colors.black54),
                                    // validator: (value) => _validateEmail(value),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: !_showCurrentLocationInput,
                                  child: SizedBox(height: 10)),
                              Visibility(
                                visible: !_showCurrentLocationInput,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Form(
                                    key: _perfectureKey,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Center(
                                              child: stateDropDownValues != null
                                                  ? Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.39,
                                                      child: DropDownFormField(
                                                          hintText: '府県',
                                                          value: _myPrefecture,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _myPrefecture =
                                                                  value;
                                                            });
                                                          },
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _myPrefecture =
                                                                  value;
                                                              print(
                                                                  'Prefecture value : ${_myPrefecture.toString()}');
                                                              _prefId = stateDropDownValues
                                                                      .indexOf(
                                                                          value) +
                                                                  1;
                                                              print(
                                                                  'prefID : ${_prefId.toString()}');
                                                              cityDropDownValues
                                                                  .clear();
                                                              _myCity = '';
                                                              _getCities(
                                                                  _prefId);
                                                            });
                                                          },
                                                          dataSource:
                                                              stateDropDownValues,
                                                          isList: true,
                                                          textField: 'display',
                                                          valueField: 'value'),
                                                    )
                                                  : Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.39,
                                                      child: DropDownFormField(
                                                          hintText: '府県',
                                                          value: _myPrefecture,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _myPrefecture =
                                                                  value;
                                                            });
                                                          },
                                                          dataSource: [],
                                                          isList: true,
                                                          textField: 'display',
                                                          valueField: 'value'),
                                                    )),
                                        ),
                                        Expanded(
                                          child: Form(
                                              key: _cityKey,
                                              child: cityDropDownValues != null
                                                  ? Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.39,
                                                      child: DropDownFormField(
                                                          hintText: '市',
                                                          value: _myCity,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _myCity = value;
                                                            });
                                                          },
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _myCity = value;
                                                              //print(_myBldGrp.toString());
                                                            });
                                                          },
                                                          dataSource:
                                                              cityDropDownValues,
                                                          isList: true,
                                                          textField: 'display',
                                                          valueField: 'value'),
                                                    )
                                                  : Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.39,
                                                      child: DropDownFormField(
                                                          hintText: '市',
                                                          value: _myCity,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _myCity = value;
                                                            });
                                                          },
                                                          dataSource: [],
                                                          isList: true,
                                                          textField: 'display',
                                                          valueField: 'value'),
                                                    )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              !_showCurrentLocationInput
                                  ? Visibility(
                                      visible: true,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Center(
                                                child: Container(
                                                  // height: MediaQuery.of(context).size.height * 0.07,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.39,
                                                  child: TextFormField(
                                                    //enableInteractiveSelection: false,
                                                    autofocus: false,
                                                    controller:
                                                        userAreaController,
                                                    decoration:
                                                        new InputDecoration(
                                                      filled: true,
                                                      fillColor: ColorConstants
                                                          .formFieldFillColor,
                                                      labelText: '丁目, 番地',
                                                      /*hintText: '都、県選 *',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),*/
                                                      labelStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily: 'Oxygen',
                                                          fontSize: 14),
                                                      focusColor:
                                                          Colors.grey[100],
                                                      border: HealingMatchConstants
                                                          .textFormInputBorder,
                                                      focusedBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      disabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      enabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                    ),
                                                    // validator: (value) => _validateEmail(value),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                // height: MediaQuery.of(context).size.height * 0.07,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.39,
                                                child: TextFormField(
                                                  //enableInteractiveSelection: false,
                                                  // keyboardType: TextInputType.number,
                                                  autofocus: false,
                                                  controller:
                                                      buildingNameController,
                                                  decoration:
                                                      new InputDecoration(
                                                    filled: true,
                                                    fillColor: ColorConstants
                                                        .formFieldFillColor,
                                                    labelText: '建物名',
                                                    /*hintText: 'ビル名 *',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),*/
                                                    labelStyle: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontFamily: 'Oxygen',
                                                        fontSize: 14),
                                                    focusColor:
                                                        Colors.grey[100],
                                                    border: HealingMatchConstants
                                                        .textFormInputBorder,
                                                    focusedBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                    disabledBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                    enabledBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                  ),
                                                  // validator: (value) => _validateEmail(value),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Visibility(
                                      visible: true,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Center(
                                                child: Container(
                                                  // height: MediaQuery.of(context).size.height * 0.07,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.39,
                                                  child: TextFormField(
                                                    //enableInteractiveSelection: false,
                                                    // keyboardType: TextInputType.number,
                                                    autofocus: false,
                                                    controller:
                                                        buildingNameController,
                                                    decoration:
                                                        new InputDecoration(
                                                      filled: true,
                                                      fillColor: ColorConstants
                                                          .formFieldFillColor,
                                                      labelText: '建物名',
                                                      labelStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily: 'Oxygen',
                                                          fontSize: 14),
                                                      focusColor:
                                                          Colors.grey[100],
                                                      border: HealingMatchConstants
                                                          .textFormInputBorder,
                                                      focusedBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      disabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      enabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                    ),
                                                    // validator: (value) => _validateEmail(value),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                // height: MediaQuery.of(context).size.height * 0.07,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.39,
                                                child: TextFormField(
                                                  //enableInteractiveSelection: false,
                                                  autofocus: false,
                                                  controller:
                                                      roomNumberController,
                                                  decoration:
                                                      new InputDecoration(
                                                    filled: true,
                                                    fillColor: ColorConstants
                                                        .formFieldFillColor,
                                                    labelText: '号室',
                                                    labelStyle: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontFamily: 'Oxygen',
                                                        fontSize: 14),
                                                    focusColor:
                                                        Colors.grey[100],
                                                    border: HealingMatchConstants
                                                        .textFormInputBorder,
                                                    focusedBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                    disabledBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                    enabledBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                  ),
                                                  // validator: (value) => _validateEmail(value),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              Visibility(
                                  visible: !_showCurrentLocationInput,
                                  child: SizedBox(height: 15)),
                              Visibility(
                                visible: !_showCurrentLocationInput,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Center(
                                          child: Container(
                                            // height: MediaQuery.of(context).size.height * 0.07,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.39,
                                            child: TextFormField(
                                              //enableInteractiveSelection: false,
                                              autofocus: false,
                                              controller: roomNumberController,
                                              decoration: new InputDecoration(
                                                filled: true,
                                                fillColor: ColorConstants
                                                    .formFieldFillColor,
                                                labelText: '号室',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontFamily: 'Oxygen',
                                                    fontSize: 14),
                                                focusColor: Colors.grey[100],
                                                border: HealingMatchConstants
                                                    .textFormInputBorder,
                                                focusedBorder:
                                                    HealingMatchConstants
                                                        .textFormInputBorder,
                                                disabledBorder:
                                                    HealingMatchConstants
                                                        .textFormInputBorder,
                                                enabledBorder:
                                                    HealingMatchConstants
                                                        .textFormInputBorder,
                                              ),
                                              // validator: (value) => _validateEmail(value),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    _myAddressInputType.isNotEmpty
                        ? SizedBox(height: 15)
                        : SizedBox(),
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: TextFormField(
                        readOnly: true,
                        enableInteractiveSelection: false,
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: ColorConstants.formFieldFillColor,
                          hintText: 'その他の登録場所',
                          suffixIcon: IconButton(
                            icon:
                                Icon(Icons.add, size: 28, color: Colors.black),
                            onPressed: () {
                              NavigationRouter.switchToUserAddAddressScreen(
                                  context);
                            },
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                          focusColor: Colors.grey[100],
                          border: HealingMatchConstants.textFormInputBorder,
                          focusedBorder:
                              HealingMatchConstants.textFormInputBorder,
                          disabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                          enabledBorder:
                              HealingMatchConstants.textFormInputBorder,
                        ),
                        style: TextStyle(color: Colors.black54),
                        // validator: (value) => _validateEmail(value),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'メインの地点以外に3箇所まで地点登録ができます',
                      style: TextStyle(
                          fontFamily: 'Oxygen',
                          fontSize: 14,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 15),
                    addressValues != null
                        ? Container(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: addressValues.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return index == 0
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: TextFormField(
                                                controller:
                                                    addedFirstAddressController,
                                                decoration: new InputDecoration(
                                                  filled: true,
                                                  fillColor: ColorConstants
                                                      .formFieldFillColor,
                                                  hintText:
                                                      '${addressValues[0]}',
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 14),
                                                  focusColor: Colors.grey[100],
                                                  border: HealingMatchConstants
                                                      .textFormInputBorder,
                                                  focusedBorder:
                                                      HealingMatchConstants
                                                          .textFormInputBorder,
                                                  disabledBorder:
                                                      HealingMatchConstants
                                                          .textFormInputBorder,
                                                  enabledBorder:
                                                      HealingMatchConstants
                                                          .textFormInputBorder,
                                                ),
                                                style: TextStyle(
                                                    color: Colors.black54),
                                                // validator: (value) => _validateEmail(value),
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                          ],
                                        )
                                      : index == 1
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  child: TextFormField(
                                                    controller:
                                                        addedSecondSubAddressController,
                                                    decoration:
                                                        new InputDecoration(
                                                      filled: true,
                                                      fillColor: ColorConstants
                                                          .formFieldFillColor,
                                                      hintText:
                                                          '${addressValues[1]}',
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontSize: 14),
                                                      focusColor:
                                                          Colors.grey[100],
                                                      border: HealingMatchConstants
                                                          .textFormInputBorder,
                                                      focusedBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      disabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      enabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                    ),
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                    // validator: (value) => _validateEmail(value),
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  child: TextFormField(
                                                    controller:
                                                        addedThirdController,
                                                    decoration:
                                                        new InputDecoration(
                                                      filled: true,
                                                      fillColor: ColorConstants
                                                          .formFieldFillColor,
                                                      hintText:
                                                          '${addressValues[2]}',
                                                      hintStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontSize: 14),
                                                      focusColor:
                                                          Colors.grey[100],
                                                      border: HealingMatchConstants
                                                          .textFormInputBorder,
                                                      focusedBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      disabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      enabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                    ),
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                    // validator: (value) => _validateEmail(value),
                                                  ),
                                                ),
                                              ],
                                            );
                                }),
                          )
                        : Container(),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'セラピスト検索範囲値',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Oxygen',
                                fontWeight: FontWeight.normal),
                          ),
                          Form(
                            key: _searchRadiusKey,
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                child: DropDownFormField(
                                  hintText: '検索範囲値',
                                  value: _mySearchRadiusDistance,
                                  onSaved: (value) {
                                    setState(() {
                                      _mySearchRadiusDistance = value;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _mySearchRadiusDistance = value;
                                      //print(_myBldGrp.toString());
                                    });
                                  },
                                  dataSource: [
                                    {
                                      "display": "５Ｋｍ圏内",
                                      "value": "５",
                                    },
                                    {
                                      "display": "１０Ｋｍ圏内",
                                      "value": "１０",
                                    },
                                    {
                                      "display": "１５Ｋｍ圏内",
                                      "value": "１５",
                                    },
                                  ],
                                  textField: 'display',
                                  valueField: 'value',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: new RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          //side: BorderSide(color: Colors.black),
                        ),
                        color: Colors.lime,
                        onPressed: () {
                          //_updateUserDetails();
                          DialogHelper.showUserProfileUpdatedSuccessDialog(
                              context);
                        },
                        child: new Text(
                          '更新',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Oxygen',
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get current address from Latitude Longitude
  _getCurrentLocation() {
    ProgressDialogBuilder.showLocationProgressDialog(context);
    geoLocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geoLocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      currentLocationPlaceMark = p[0];

      HealingMatchConstants.currentLatitude = _currentPosition.latitude;
      HealingMatchConstants.currentLongitude = _currentPosition.longitude;

      setState(() {
        _currentAddress =
            '${currentLocationPlaceMark.locality},${currentLocationPlaceMark.subAdministrativeArea},${currentLocationPlaceMark.administrativeArea},${currentLocationPlaceMark.postalCode}'
            ',${currentLocationPlaceMark.country}';
        if (_currentAddress != null && _currentAddress.isNotEmpty) {
          print(
              'Current address : $_currentAddress : ${HealingMatchConstants.currentLatitude} && '
              '${HealingMatchConstants.currentLongitude}');
          gpsAddressController.value = TextEditingValue(text: _currentAddress);
          setState(() {
            _isGPSLocation = true;
          });
          HealingMatchConstants.serviceUserCity =
              currentLocationPlaceMark.locality;
          HealingMatchConstants.serviceUserPrefecture =
              currentLocationPlaceMark.administrativeArea;
        } else {
          ProgressDialogBuilder.hideLocationProgressDialog(context);
          return null;
        }
      });
      ProgressDialogBuilder.hideLocationProgressDialog(context);
    } catch (e) {
      ProgressDialogBuilder.hideLocationProgressDialog(context);
      print(e);
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('プロフィール画像を選択してください。'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('プロフィール写真を撮ってください。'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    final pickedImage = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);

    setState(() {
      if (pickedImage != null) {
        _profileImage = File(pickedImage.path);
        print('image camera path : ${_profileImage.path}');
      } else {
        print('No camera image selected.');
      }
    });
  }

  _imgFromGallery() async {
    final pickedImage =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      if (pickedImage != null) {
        _profileImage = File(pickedImage.path);
        print('image gallery path : ${_profileImage.path}');
      } else {
        print('No gallery image selected.');
      }
    });
  }

  _getStates() async {
    await http.get(HealingMatchConstants.STATE_PROVIDER_URL).then((response) {
      states = StatesListResponseModel.fromJson(json.decode(response.body));
      print(states.toJson());
      for (var stateList in states.data) {
        setState(() {
          stateDropDownValues.add(stateList.prefectureJa);
        });
      }
    });
  }

  // CityList cityResponse;
  _getCities(var prefId) async {
    ProgressDialogBuilder.showGetCitiesProgressDialog(context);
    await http.post(HealingMatchConstants.CITY_PROVIDER_URL,
        body: {'prefecture_id': prefId.toString()}).then((response) {
      cities = CitiesListResponseModel.fromJson(json.decode(response.body));
      print(cities.toJson());
      for (var cityList in cities.data) {
        setState(() {
          cityDropDownValues.add(cityList.cityJa + cityList.specialDistrictJa);
        });
      }
      ProgressDialogBuilder.hideGetCitiesProgressDialog(context);
      print('Response City list : ${response.body}');
    });
  }

  _updateUserDetails() async {}

  void getAddressFields() {
    _sharedPreferences.then((value) {
      userAddressType = value.getString('addressType');
      print('User Address Type : $userAddressType');
    });
    print('Entering adress fields....');
    for (int i = 0; i < addressValues.length; i++) {
      if (i == 0) {
        addedFirstAddressController.value =
            TextEditingValue(text: '${addressValues[0]}');
      } else if (i == 1) {
        addedSecondSubAddressController.value =
            TextEditingValue(text: '${addressValues[1]}');
      } else if (i == 2) {
        addedThirdController.value =
            TextEditingValue(text: '${addressValues[2]}');
      } else {
        return;
      }
    }
  }
}

class AddAddress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final Geolocator addAddressgeoLocator = Geolocator()
    ..forceAndroidLocationManager;
  Position _addAddressPosition;
  String _addedAddress = '';
  String _myAddedAddressInputType = '';
  String _myAddedPrefecture = '';
  String _myAddedCity = '';
  Placemark userGPSAddressPlaceMark;
  Placemark userManualAddressPlaceMark;
  final _addedAddressTypeKey = new GlobalKey<FormState>();
  final _addedPrefectureKey = new GlobalKey<FormState>();
  final _addedCityKey = new GlobalKey<FormState>();
  final additionalAddressController = new TextEditingController();
  final addedBuildingNameController = new TextEditingController();
  final addedUserAreaController = new TextEditingController();
  final addedRoomNumberController = new TextEditingController();
  List<dynamic> addedAddressStateDropDownValues = List();
  List<dynamic> addedAddressCityDropDownValues = List();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  StatesListResponseModel states;
  CitiesListResponseModel cities;
  var _addedAddressPrefId;
  bool _isAddedGPSLocation = false;
  bool _showRequiredFields = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      body: Center(
        child: new AnimatedContainer(
            // Define how long the animation should take.
            duration: Duration(seconds: 3),
            // Provide an optional curve to make the animation feel smoother.
            curve: Curves.bounceIn,
            width: MediaQuery.of(context).size.width * 0.90,
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(16.0),
              color: Colors.grey[300],
              boxShadow: [
                new BoxShadow(
                    color: Colors.lime,
                    blurRadius: 3.0,
                    offset: new Offset(1.0, 1.0))
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          child: Text(
                            '住所を追加する',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Oxygen'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Form(
                          key: _addedAddressTypeKey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: DropDownFormField(
                                  hintText: '検索地点の登録',
                                  value: _myAddedAddressInputType,
                                  onSaved: (value) {
                                    setState(() {
                                      _myAddedAddressInputType = value;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _myAddedAddressInputType = value;
                                      if (_myAddedAddressInputType != null &&
                                          _myAddedAddressInputType
                                              .contains('現在地を取得する')) {
                                        additionalAddressController.clear();
                                        addedBuildingNameController.clear();
                                        addedRoomNumberController.clear();
                                        _additionalAddressCurrentLocation();
                                      } else if (_myAddedAddressInputType !=
                                              null &&
                                          _myAddedAddressInputType
                                              .contains('直接入力する')) {
                                        _isAddedGPSLocation = false;
                                        addedAddressCityDropDownValues.clear();
                                        addedAddressStateDropDownValues.clear();
                                        addedBuildingNameController.clear();
                                        addedRoomNumberController.clear();
                                        _myAddedPrefecture = '';
                                        _myAddedCity = '';
                                        _getAddedAddressStates();
                                      }
                                      print(
                                          'Added Address type : ${_myAddedAddressInputType.toString()}');
                                    });
                                  },
                                  dataSource: [
                                    {
                                      "showDisplay": "現在地を取得する",
                                      "value": "現在地を取得する",
                                    },
                                    {
                                      "showDisplay": "直接入力する",
                                      "value": "直接入力する",
                                    },
                                  ],
                                  textField: 'showDisplay',
                                  valueField: 'value',
                                ),
                              ),
                              _myAddedAddressInputType.contains('現在地を取得する')
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 10),
                                        Visibility(
                                          visible: _isAddedGPSLocation,
                                          child: Container(
                                            // height: MediaQuery.of(context).size.height * 0.07,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            child: TextFormField(
                                              controller:
                                                  additionalAddressController,
                                              decoration: new InputDecoration(
                                                filled: true,
                                                fillColor: ColorConstants
                                                    .formFieldFillColor,
                                                hintText: '現在地を取得する',
                                                /*hintText: '現在地を取得する *',
                                        hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        ),*/
                                                suffixIcon: IconButton(
                                                  icon: Icon(Icons.location_on,
                                                      size: 28),
                                                  onPressed: () {
                                                    _additionalAddressCurrentLocation();
                                                  },
                                                ),
                                                hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 14),
                                                focusColor: Colors.grey[100],
                                                border: HealingMatchConstants
                                                    .textFormInputBorder,
                                                focusedBorder:
                                                    HealingMatchConstants
                                                        .textFormInputBorder,
                                                disabledBorder:
                                                    HealingMatchConstants
                                                        .textFormInputBorder,
                                                enabledBorder:
                                                    HealingMatchConstants
                                                        .textFormInputBorder,
                                              ),
                                              style: TextStyle(
                                                  color: Colors.black54),
                                              // validator: (value) => _validateEmail(value),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.85,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  // height: MediaQuery.of(context).size.height * 0.07,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.39,
                                                  child: TextFormField(
                                                    //enableInteractiveSelection: false,
                                                    // keyboardType: TextInputType.number,
                                                    autofocus: false,
                                                    controller:
                                                        addedBuildingNameController,
                                                    decoration:
                                                        new InputDecoration(
                                                      filled: true,
                                                      fillColor: ColorConstants
                                                          .formFieldFillColor,
                                                      labelText: '建物名',
                                                      /*hintText: 'ビル名 *',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                ),*/
                                                      labelStyle: TextStyle(
                                                          color:
                                                              Colors.grey[400],
                                                          fontFamily: 'Oxygen',
                                                          fontSize: 14),
                                                      focusColor:
                                                          Colors.grey[100],
                                                      border: HealingMatchConstants
                                                          .textFormInputBorder,
                                                      focusedBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      disabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                      enabledBorder:
                                                          HealingMatchConstants
                                                              .textFormInputBorder,
                                                    ),
                                                    // validator: (value) => _validateEmail(value),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Center(
                                                  child: Container(
                                                    // height: MediaQuery.of(context).size.height * 0.07,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.39,
                                                    child: TextFormField(
                                                      //enableInteractiveSelection: false,
                                                      autofocus: false,
                                                      controller:
                                                          addedRoomNumberController,
                                                      decoration:
                                                          new InputDecoration(
                                                        filled: true,
                                                        fillColor: ColorConstants
                                                            .formFieldFillColor,
                                                        labelText: '号室',
                                                        /*hintText: '都、県選 *',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),*/
                                                        labelStyle: TextStyle(
                                                            color: Colors
                                                                .grey[400],
                                                            fontFamily:
                                                                'Oxygen',
                                                            fontSize: 14),
                                                        focusColor:
                                                            Colors.grey[100],
                                                        border: HealingMatchConstants
                                                            .textFormInputBorder,
                                                        focusedBorder:
                                                            HealingMatchConstants
                                                                .textFormInputBorder,
                                                        disabledBorder:
                                                            HealingMatchConstants
                                                                .textFormInputBorder,
                                                        enabledBorder:
                                                            HealingMatchConstants
                                                                .textFormInputBorder,
                                                      ),
                                                      // validator: (value) => _validateEmail(value),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : _myAddedAddressInputType.contains('直接入力する')
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 10),
                                            Visibility(
                                              visible: _isAddedGPSLocation,
                                              child: Container(
                                                // height: MediaQuery.of(context).size.height * 0.07,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.85,
                                                child: TextFormField(
                                                  controller:
                                                      additionalAddressController,
                                                  decoration:
                                                      new InputDecoration(
                                                    filled: true,
                                                    fillColor: ColorConstants
                                                        .formFieldFillColor,
                                                    hintText: '現在地を取得する',
                                                    /*hintText: '現在地を取得する *',
                                        hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        ),*/
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                          Icons.location_on,
                                                          size: 28),
                                                      onPressed: () {
                                                        _additionalAddressCurrentLocation();
                                                      },
                                                    ),
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 14),
                                                    focusColor:
                                                        Colors.grey[100],
                                                    border: HealingMatchConstants
                                                        .textFormInputBorder,
                                                    focusedBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                    disabledBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                    enabledBorder:
                                                        HealingMatchConstants
                                                            .textFormInputBorder,
                                                  ),
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                  // validator: (value) => _validateEmail(value),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: Form(
                                                key: _addedPrefectureKey,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Center(
                                                          child:
                                                              addedAddressStateDropDownValues !=
                                                                      null
                                                                  ? Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.39,
                                                                      child: DropDownFormField(
                                                                          hintText: '府県',
                                                                          value: _myAddedPrefecture,
                                                                          onSaved: (value) {
                                                                            setState(() {
                                                                              _myAddedPrefecture = value;
                                                                            });
                                                                          },
                                                                          onChanged: (value) {
                                                                            setState(() {
                                                                              _myAddedPrefecture = value;
                                                                              print('Prefecture value : ${_myAddedPrefecture.toString()}');
                                                                              _addedAddressPrefId = addedAddressStateDropDownValues.indexOf(value) + 1;
                                                                              print('prefID : ${_addedAddressPrefId.toString()}');
                                                                              addedAddressCityDropDownValues.clear();
                                                                              _myAddedCity = '';
                                                                              _getAddedAddressCities(_addedAddressPrefId);
                                                                            });
                                                                          },
                                                                          dataSource: addedAddressStateDropDownValues,
                                                                          isList: true,
                                                                          textField: 'display',
                                                                          valueField: 'value'),
                                                                    )
                                                                  : Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.39,
                                                                      child: DropDownFormField(
                                                                          hintText: '府県',
                                                                          value: _myAddedPrefecture,
                                                                          onSaved: (value) {
                                                                            setState(() {
                                                                              _myAddedPrefecture = value;
                                                                            });
                                                                          },
                                                                          dataSource: [],
                                                                          isList: true,
                                                                          textField: 'display',
                                                                          valueField: 'value'),
                                                                    )),
                                                    ),
                                                    SizedBox(width: 3),
                                                    Expanded(
                                                      child: Form(
                                                          key: _addedCityKey,
                                                          child:
                                                              addedAddressCityDropDownValues !=
                                                                      null
                                                                  ? Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.39,
                                                                      child: DropDownFormField(
                                                                          hintText: '市',
                                                                          value: _myAddedCity,
                                                                          onSaved: (value) {
                                                                            setState(() {
                                                                              _myAddedCity = value;
                                                                            });
                                                                          },
                                                                          onChanged: (value) {
                                                                            setState(() {
                                                                              _myAddedCity = value;
                                                                              //print(_myBldGrp.toString());
                                                                            });
                                                                          },
                                                                          dataSource: addedAddressCityDropDownValues,
                                                                          isList: true,
                                                                          textField: 'display',
                                                                          valueField: 'value'),
                                                                    )
                                                                  : Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.39,
                                                                      child: DropDownFormField(
                                                                          hintText: '市',
                                                                          value: _myAddedCity,
                                                                          onSaved: (value) {
                                                                            setState(() {
                                                                              _myAddedCity = value;
                                                                            });
                                                                          },
                                                                          dataSource: [],
                                                                          isList: true,
                                                                          textField: 'display',
                                                                          valueField: 'value'),
                                                                    )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Center(
                                                      child: Container(
                                                        // height: MediaQuery.of(context).size.height * 0.07,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.39,
                                                        child: TextFormField(
                                                          //enableInteractiveSelection: false,
                                                          autofocus: false,
                                                          controller:
                                                              addedUserAreaController,
                                                          decoration:
                                                              new InputDecoration(
                                                            filled: true,
                                                            fillColor:
                                                                ColorConstants
                                                                    .formFieldFillColor,
                                                            labelText: '丁目, 番地',
                                                            /*hintText: '都、県選 *',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),*/
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontFamily:
                                                                    'Oxygen',
                                                                fontSize: 14),
                                                            focusColor: Colors
                                                                .grey[100],
                                                            border: HealingMatchConstants
                                                                .textFormInputBorder,
                                                            focusedBorder:
                                                                HealingMatchConstants
                                                                    .textFormInputBorder,
                                                            disabledBorder:
                                                                HealingMatchConstants
                                                                    .textFormInputBorder,
                                                            enabledBorder:
                                                                HealingMatchConstants
                                                                    .textFormInputBorder,
                                                          ),
                                                          // validator: (value) => _validateEmail(value),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      // height: MediaQuery.of(context).size.height * 0.07,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.39,
                                                      child: TextFormField(
                                                        //enableInteractiveSelection: false,
                                                        // keyboardType: TextInputType.number,
                                                        autofocus: false,
                                                        controller:
                                                            addedBuildingNameController,
                                                        decoration:
                                                            new InputDecoration(
                                                          filled: true,
                                                          fillColor: ColorConstants
                                                              .formFieldFillColor,
                                                          labelText: '建物名',
                                                          /*hintText: 'ビル名 *',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                ),*/
                                                          labelStyle: TextStyle(
                                                              color: Colors
                                                                  .grey[400],
                                                              fontFamily:
                                                                  'Oxygen',
                                                              fontSize: 14),
                                                          focusColor:
                                                              Colors.grey[100],
                                                          border: HealingMatchConstants
                                                              .textFormInputBorder,
                                                          focusedBorder:
                                                              HealingMatchConstants
                                                                  .textFormInputBorder,
                                                          disabledBorder:
                                                              HealingMatchConstants
                                                                  .textFormInputBorder,
                                                          enabledBorder:
                                                              HealingMatchConstants
                                                                  .textFormInputBorder,
                                                        ),
                                                        // validator: (value) => _validateEmail(value),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Center(
                                                      child: Container(
                                                        // height: MediaQuery.of(context).size.height * 0.07,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.39,
                                                        child: TextFormField(
                                                          //enableInteractiveSelection: false,
                                                          autofocus: false,
                                                          controller:
                                                              addedRoomNumberController,
                                                          decoration:
                                                              new InputDecoration(
                                                            filled: true,
                                                            fillColor:
                                                                ColorConstants
                                                                    .formFieldFillColor,
                                                            labelText: '号室',
                                                            labelStyle: TextStyle(
                                                                color: Colors
                                                                    .grey[400],
                                                                fontFamily:
                                                                    'Oxygen',
                                                                fontSize: 14),
                                                            focusColor: Colors
                                                                .grey[100],
                                                            border: HealingMatchConstants
                                                                .textFormInputBorder,
                                                            focusedBorder:
                                                                HealingMatchConstants
                                                                    .textFormInputBorder,
                                                            disabledBorder:
                                                                HealingMatchConstants
                                                                    .textFormInputBorder,
                                                            enabledBorder:
                                                                HealingMatchConstants
                                                                    .textFormInputBorder,
                                                          ),
                                                          // validator: (value) => _validateEmail(value),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: new RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              //side: BorderSide(color: Colors.black),
                            ),
                            color: Colors.lime,
                            onPressed: () {
                              //addressValues.clear();
                              _addUserAddress();
                            },
                            child: new Text(
                              '追加',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ],
              // child:
            )),
      ),
    );
  }

  // Get current address from Latitude Longitude
  _additionalAddressCurrentLocation() {
    ProgressDialogBuilder.showLocationProgressDialog(context);
    addAddressgeoLocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _addAddressPosition = position;
      });
      _getAdditionalAddressLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAdditionalAddressLatLng() async {
    try {
      List<Placemark> p = await addAddressgeoLocator.placemarkFromCoordinates(
          _addAddressPosition.latitude, _addAddressPosition.longitude);

      userGPSAddressPlaceMark = p[0];

      HealingMatchConstants.addedCurrentLatitude = _addAddressPosition.latitude;
      HealingMatchConstants.addedCurrentLongitude =
          _addAddressPosition.longitude;

      setState(() {
        _addedAddress =
            '${userGPSAddressPlaceMark.locality},${userGPSAddressPlaceMark.subAdministrativeArea},'
            '${userGPSAddressPlaceMark.administrativeArea},${userGPSAddressPlaceMark.postalCode}'
            ',${userGPSAddressPlaceMark.country}';
        if (_addedAddress != null && _addedAddress.isNotEmpty) {
          print(
              'Additional address GPS location : $_addedAddress : ${HealingMatchConstants.addedCurrentLatitude} && '
              '${HealingMatchConstants.addedCurrentLongitude}');
          additionalAddressController.value =
              TextEditingValue(text: _addedAddress);
          setState(() {
            _isAddedGPSLocation = true;
          });
          HealingMatchConstants.addedServiceUserCity =
              userGPSAddressPlaceMark.locality;
          HealingMatchConstants.addedServiceUserPrefecture =
              userGPSAddressPlaceMark.administrativeArea;
        } else {
          ProgressDialogBuilder.hideLocationProgressDialog(context);
          return null;
        }
      });
      ProgressDialogBuilder.hideLocationProgressDialog(context);
    } catch (e) {
      ProgressDialogBuilder.hideLocationProgressDialog(context);
      print(e);
    }
  }

  _getAddedAddressStates() async {
    await http.get(HealingMatchConstants.STATE_PROVIDER_URL).then((response) {
      states = StatesListResponseModel.fromJson(json.decode(response.body));
      print(states.toJson());
      for (var stateList in states.data) {
        setState(() {
          addedAddressStateDropDownValues.add(stateList.prefectureJa);
        });
      }
    });
  }

  // CityList cityResponse;
  _getAddedAddressCities(var prefId) async {
    ProgressDialogBuilder.showGetCitiesProgressDialog(context);
    await http.post(HealingMatchConstants.CITY_PROVIDER_URL,
        body: {'prefecture_id': prefId.toString()}).then((response) {
      cities = CitiesListResponseModel.fromJson(json.decode(response.body));
      print(cities.toJson());
      for (var cityList in cities.data) {
        setState(() {
          addedAddressCityDropDownValues
              .add(cityList.cityJa + cityList.specialDistrictJa);
        });
      }
      ProgressDialogBuilder.hideGetCitiesProgressDialog(context);
      print('Response City list : ${response.body}');
    });
  }

  _addUserAddress() async {
    if (_myAddedAddressInputType.isNotEmpty &&
        _myAddedAddressInputType.contains('現在地を取得する')) {
      if (addedRoomNumberController.text.isEmpty ||
          addedBuildingNameController.text.isEmpty) {
        print('Room number empty');
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: ColorConstants.snackBarColor,
          duration: Duration(seconds: 3),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('必須値を入力してください。',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontFamily: 'Oxygen')),
              ),
              InkWell(
                onTap: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                },
                child: Text('はい',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Oxygen',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ));
        return;
      } else {
        String gpsUserAddress =
            '${addedRoomNumberController.text.toString()},${addedBuildingNameController.text.toString() + ',' + _addedAddress}';
        print('GPS FINAL ADDRESS : $gpsUserAddress');
        if (addressValues.length <= 2) {
          setState(() {
            print('Entering if...');
            addressValues.add(gpsUserAddress);
            print(addressValues.length);
            //Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        UpdateServiceUserDetails()));
          });
        } else {
//メインの地点以外に3箇所まで地点登録ができます
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: ColorConstants.snackBarColor,
            duration: Duration(seconds: 3),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('メインの地点以外に3箇所まで地点登録ができます。',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontFamily: 'Oxygen')),
                ),
                InkWell(
                  onTap: () {
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                UpdateServiceUserDetails()));
                  },
                  child: Text('はい',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Oxygen',
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ));
          return;
        }
      }
    } else if (_myAddedAddressInputType.isNotEmpty &&
        _myAddedAddressInputType.contains('直接入力する')) {
      if (addedRoomNumberController.text.isEmpty ||
          addedBuildingNameController.text.isEmpty ||
          addedUserAreaController.text.isEmpty ||
          _myAddedCity.isEmpty ||
          _myAddedPrefecture.isEmpty) {
        print('Manual address empty fields');
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: ColorConstants.snackBarColor,
          duration: Duration(seconds: 3),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('必須値を入力してください。',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontFamily: 'Oxygen')),
              ),
              InkWell(
                onTap: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                },
                child: Text('はい',
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Oxygen',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ));
        return;
      } else {
        String manualAddedAddress = addedRoomNumberController.text.toString() +
            ',' +
            addedBuildingNameController.text.toString() +
            ',' +
            addedUserAreaController.text.toString() +
            ',' +
            _myAddedCity +
            ',' +
            _myAddedPrefecture;
        print('USER MANUAL ADDRESS : $manualAddedAddress');
        List<Placemark> userManualAddress =
            await addAddressgeoLocator.placemarkFromAddress(manualAddedAddress);
        userManualAddressPlaceMark = userManualAddress[0];
        Position addressPosition = userManualAddressPlaceMark.position;
        HealingMatchConstants.manualAddressCurrentLatitude =
            addressPosition.latitude;
        HealingMatchConstants.manualAddressCurrentLongitude =
            addressPosition.longitude;
        HealingMatchConstants.serviceUserCity =
            userManualAddressPlaceMark.locality;
        HealingMatchConstants.serviceUserPrefecture =
            userManualAddressPlaceMark.administrativeArea;
        HealingMatchConstants.manualUserAddress = manualAddedAddress;

        print(
            'Manual Address lat lon : ${HealingMatchConstants.manualAddressCurrentLatitude} && '
            '${HealingMatchConstants.manualAddressCurrentLongitude}');
        print('Manual Place Json : ${userManualAddressPlaceMark.toJson()}');
        print('Manual Address : ${HealingMatchConstants.manualUserAddress}');
        if (addressValues.length <= 2) {
          setState(() {
            print('Entering if...');
            addressValues.add(manualAddedAddress);
            print(addressValues.length);
            //Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        UpdateServiceUserDetails()));
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: ColorConstants.snackBarColor,
            duration: Duration(seconds: 3),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('メインの地点以外に3箇所まで地点登録ができます。',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontFamily: 'Oxygen')),
                ),
                InkWell(
                  onTap: () {
                    _scaffoldKey.currentState.hideCurrentSnackBar();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                UpdateServiceUserDetails()));
                  },
                  child: Text('はい',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Oxygen',
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ));
          return;
        }
      }
    } else {
      print('Address Type is Empty....');
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ColorConstants.snackBarColor,
        duration: Duration(seconds: 3),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text('検索地点の登録を選択してください。',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontFamily: 'Oxygen')),
            ),
            InkWell(
              onTap: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
              child: Text('はい',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Oxygen',
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ));
      return;
    }
  }
}