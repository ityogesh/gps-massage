import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gps_massageapp/customLibraryClasses/customRadioButtonList/roundedRadioButton.dart';
import 'package:gps_massageapp/customLibraryClasses/customToggleButton/CustomToggleButton.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:gps_massageapp/serviceUser/APIProviderCalls/ServiceUserAPIProvider.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/userDetails/GetTherapistDetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/alertDialogHelper/dialogHelper.dart';

bool isOtherSelected = false;
final _cancelReasonController = new TextEditingController();
Map<String, dynamic> _formData = {
  'text': null,
  'category': null,
  'date': null,
  'time': null,
};
var selectedBuildingType;
bool isCancelSelected = false;
GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class BookingApproveThirdScreen extends StatefulWidget {
  final int therapistId;
  BookingApproveThirdScreen(this.therapistId);
  @override
  State createState() {
    return _BookingApproveThirdScreenState();
  }
}

class _BookingApproveThirdScreenState extends State<BookingApproveThirdScreen> {
  TherapistByIdModel therapistDetails;
  int status = 0;

  @override
  void initState() {
    super.initState();
    getProviderInfo();
  }

  getProviderInfo() async {
    try {
      ProgressDialogBuilder.showOverlayLoader(context);
      therapistDetails = await ServiceUserAPIProvider.getTherapistDetails(
          context, widget.therapistId);
      HealingMatchConstants.therapistProfileDetails = therapistDetails;
      //append all Service Types for General View

      setState(() {
        status = 1;
      });
    } catch (e) {
      ProgressDialogBuilder.hideLoader(context);
      print('Therapist details fetch Exception : ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            NavigationRouter.switchToServiceUserBottomBar(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: new Text(
          'お知らせ',
          style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'NotoSansJP',
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: status == 0
          ? SpinKitThreeBounce(color: Colors.lime)
          : ApprovalSecondScreen(),
    );
  }
}

class ApprovalSecondScreen extends StatefulWidget {
  @override
  State createState() {
    return _ApprovalSecondScreenState();
  }
}

class _ApprovalSecondScreenState extends State<ApprovalSecondScreen> {
  bool isPriceAdded = false;
  bool isDateChanged = false;
  @override
  Widget build(BuildContext context) {
    DateTime startTime = HealingMatchConstants
        .therapistProfileDetails.bookingDataResponse[0].startTime
        .toLocal();
    DateTime endTime = HealingMatchConstants
        .therapistProfileDetails.bookingDataResponse[0].endTime
        .toLocal();
    String date = DateFormat('MM月d').format(startTime);
    String sTime = DateFormat('kk:mm').format(startTime);
    String eTime = DateFormat('kk:mm').format(endTime);
    String jaName = DateFormat('EEEE', 'ja_JP').format(startTime);
    String nSTime;
    String nEndTime;
    if (HealingMatchConstants
            .therapistProfileDetails.bookingDataResponse[0].newStartTime !=
        null) {
      isDateChanged = true;
      nSTime = DateFormat('kk:mm').format(DateTime.parse(HealingMatchConstants
              .therapistProfileDetails.bookingDataResponse[0].newStartTime)
          .toLocal());
      nEndTime = DateFormat('kk:mm').format(DateTime.parse(HealingMatchConstants
              .therapistProfileDetails.bookingDataResponse[0].newEndTime)
          .toLocal());
    }
    if (HealingMatchConstants
            .therapistProfileDetails.bookingDataResponse[0].travelAmount !=
        0) {
      isPriceAdded = true;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DottedBorder(
                    dashPattern: [2, 2],
                    strokeWidth: 1,
                    color: Color.fromRGBO(232, 232, 232, 1),
                    strokeCap: StrokeCap.round,
                    borderType: BorderType.Circle,
                    radius: Radius.circular(5),
                    child: CircleAvatar(
                      maxRadius: 55,
                      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                      child: SvgPicture.asset('assets/images_gps/calendar.svg',
                          height: 45, width: 45, color: Colors.lime),
                    )),
                SizedBox(height: 10),
                Text(
                  'セラピストからリクエストがありました。',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontFamily: 'NotoSansJP'),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(242, 242, 242, 1),
                            Color.fromRGBO(242, 242, 242, 1)
                          ]),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.grey[100],
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      color: Colors.grey[100]),
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: 275,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Expanded(
                        child: new Row(
                          children: [
                            HealingMatchConstants.therapistProfileDetails.data
                                        .uploadProfileImgUrl !=
                                    null
                                ? CachedNetworkImage(
                                    imageUrl: HealingMatchConstants
                                        .therapistProfileDetails
                                        .data
                                        .uploadProfileImgUrl,
                                    filterQuality: FilterQuality.high,
                                    fadeInCurve: Curves.easeInSine,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: 65.0,
                                      height: 65.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        SpinKitDoubleBounce(
                                            color: Colors.lightGreenAccent),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 56.0,
                                      height: 56.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: Colors.black12),
                                        image: DecorationImage(
                                            image: new AssetImage(
                                                'assets/images_gps/placeholder_image.png'),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    child: Image.asset(
                                      'assets/images_gps/placeholder_image.png',
                                      height: 65,
                                      color: Colors.black,
                                      fit: BoxFit.cover,
                                    ),
                                    radius: 35,
                                    backgroundColor: Colors.white,
                                  ),
                            /*  SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),*/
                            HealingMatchConstants.therapistProfileDetails.data
                                        .storeName.isNotEmpty &&
                                    HealingMatchConstants
                                            .therapistProfileDetails
                                            .data
                                            .storeName !=
                                        null
                                ? Text(
                                    '${HealingMatchConstants.therapistProfileDetails.data.storeName}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSansJP'),
                                  )
                                : Text(
                                    '${HealingMatchConstants.therapistProfileDetails.data.userName}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NotoSansJP'),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            Image.asset('assets/images_gps/calendar.png',
                                height: 25, width: 25),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              '$date',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSansJP'),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            Text(
                              '$jaName',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                  fontFamily: 'NotoSansJP'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            SvgPicture.asset('assets/images_gps/clock.svg',
                                height: 25, width: 25),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            new Text(
                              '$sTime～$eTime',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'NotoSansJP'),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            new Text(
                              '${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].totalMinOfService}分',
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontFamily: 'NotoSansJP'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            SvgPicture.asset('assets/images_gps/cost.svg',
                                height: 25, width: 25),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Chip(
                              label: Text(
                                  '${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].nameOfService}'),
                              backgroundColor: Colors.white,
                            ),
                            Text(
                              "¥${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].priceOfService}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.01),
                            /* Text(
                              '(交通費込み-1,000)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontFamily: 'NotoSansJP'),
                            ),*/
                          ],
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Divider(),
                            )),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: InkWell(
                                onTap: () {
                                  NavigationRouter
                                      .switchToServiceUserChatScreen(context);
                                },
                                child: CircleAvatar(
                                    maxRadius: 20,
                                    backgroundColor:
                                        Color.fromRGBO(255, 255, 255, 1),
                                    child: SvgPicture.asset(
                                        'assets/images_gps/chat.svg',
                                        height: 30,
                                        width: 30)),
                              ),
                            ),
                          ]),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            SvgPicture.asset('assets/images_gps/gps.svg',
                                height: 25, width: 25),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              '施術を受ける場所',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSansJP'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color.fromRGBO(255, 255, 255, 1),
                                          Color.fromRGBO(255, 255, 255, 1)
                                        ]),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      color: Colors.grey[300],
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Colors.grey[200]),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    '${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].locationType}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'NotoSansJP'),
                                  ),
                                )),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Flexible(
                              child: Text(
                                '${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].location}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontFamily: 'NotoSansJP'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Text(
              'リクエストの詳細',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 7),
          Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(242, 242, 242, 1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.sp,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "提案時間",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.black),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                            Text(
                              "サービス料金",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "交通費",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "合計",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                          ]),
                      Column(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "$sTime ~ $eTime  ",
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: !isDateChanged
                                          ? Color.fromRGBO(242, 242, 242, 1)
                                          : Color.fromRGBO(153, 153, 153, 1),
                                      decoration: TextDecoration.lineThrough),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 10.0,
                                  color: !isDateChanged
                                      ? Color.fromRGBO(242, 242, 242, 1)
                                      : Color.fromRGBO(153, 153, 153, 1),
                                ),
                              ],
                            ),
                            SizedBox(height: 14),
                            Text(
                              "",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                            SizedBox(height: 14),
                            Row(
                              children: [
                                Text(
                                  "¥0",
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: !isPriceAdded
                                          ? Color.fromRGBO(242, 242, 242, 1)
                                          : Color.fromRGBO(153, 153, 153, 1),
                                      decoration: TextDecoration.lineThrough),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 10.0,
                                  color: !isPriceAdded
                                      ? Color.fromRGBO(242, 242, 242, 1)
                                      : Color.fromRGBO(153, 153, 153, 1),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  "¥${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].priceOfService}  ",
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: !isPriceAdded
                                          ? Color.fromRGBO(242, 242, 242, 1)
                                          : Color.fromRGBO(153, 153, 153, 1),
                                      decoration: TextDecoration.lineThrough),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 10.0,
                                  color: !isPriceAdded
                                      ? Color.fromRGBO(242, 242, 242, 1)
                                      : Color.fromRGBO(153, 153, 153, 1),
                                ),
                              ],
                            ),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isDateChanged
                                  ? "$nSTime ~ $nEndTime"
                                  : "$sTime ~ $eTime",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "¥${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].priceOfService}",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "¥${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].travelAmount}",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "¥${HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].priceOfService + HealingMatchConstants.therapistProfileDetails.bookingDataResponse[0].travelAmount}",
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.black),
                            ),
                          ]),
                    ],
                  ),
                  Positioned(
                    bottom: 20.0,
                    height: 10.0,
                    width: MediaQuery.of(context).size.width,
                    child: new Divider(
                      color: Color.fromRGBO(102, 102, 102, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ButtonTheme(
                  minWidth: MediaQuery.of(context).size.width * 0.35,
                  child: CustomToggleButton(
                    elevation: 0,
                    height: 55.0,
                    width: MediaQuery.of(context).size.width * 0.40,
                    autoWidth: false,
                    buttonColor: Color.fromRGBO(217, 217, 217, 1),
                    enableShape: true,
                    customShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.transparent)),
                    buttonLables: ["キャンセルする", "支払に進む"],
                    fontSize: 16.0,
                    buttonValues: [
                      "Y",
                      "N",
                    ],
                    radioButtonValue: (value) {
                      if (value == 'Y') {
                        setState(() {
                          isCancelSelected = true;
                        });
                      } else {
                        setState(() {
                          isCancelSelected = !isCancelSelected;
                        });
                        HealingMatchConstants.initiatePayment(context);
                      }
                      print('Radio value : $isCancelSelected');
                    },
                    selectedColor: Color.fromRGBO(200, 217, 33, 1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Visibility(
              visible: isCancelSelected,
              child: massageBuildTypeDisplayContent())
        ],
      ),
    );
  }

  Widget massageBuildTypeDisplayContent() {
    bool newChoosenVal = false;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(
            'キャンセルする理由を選択してください',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 16,
                fontFamily: 'NotoSansJP'),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: BuildingCategories.initial()
                .categories
                .map((BuildingCategory category) {
              final bool selected =
                  _formData['category']?.name == category.name;
              return ListTile(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: new Text('${category.name}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'NotoSansJP')),
                    ),
                  ],
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CustomRadioButton(
                      color: Colors.black,
                      selected: selected,
                      onChange: (newVal) {
                        newChoosenVal = newVal;
                        _handleCategoryChange(newChoosenVal, category);
                        if (category.name.contains('その他')) {
                          print(
                              'SELECTED VALUE IF ON CHANGE : ${category.name}');

                          setState(() {
                            isOtherSelected = true;
                          });
                        } else {
                          _handleCategoryChange(true, category);
                          print(
                              'SELECTED VALUE ELSE ON CHANGE : ${category.name}');
                          setState(() {
                            isOtherSelected = false;
                          });
                        }
                      }),
                ),
                onTap: () {
                  _handleCategoryChange(true, category);
                  if (category.name.contains('その他')) {
                    print('SELECTED VALUE IF ON TAP : ${category.name}');
                    setState(() {
                      isOtherSelected = true;
                    });
                  } else {
                    _handleCategoryChange(true, category);
                    print('SELECTED VALUE ELSE ON TAP : ${category.name}');
                    setState(() {
                      isOtherSelected = false;
                    });
                  }
                },
              );
            }).toList(),
          ),
          Visibility(
            visible: isOtherSelected,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                width: MediaQuery.of(context).size.width * 0.85,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: TextField(
                        controller: _cancelReasonController,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        decoration: new InputDecoration(
                            filled: false,
                            fillColor: Colors.white,
                            hintText: 'キャシセルする理由を記入ください',
                            hintStyle: TextStyle(color: Colors.grey[300]),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey[300], width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey[300], width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey[300], width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                      ),
                    ),
                    /*  Positioned(
                      top: 95,
                      left: 300,
                      right: 10,
                      bottom: 5,
                      child: CircleAvatar(
                        maxRadius: 30.0,
                        backgroundColor: Colors.grey[300],
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: 20.0,
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.lime),
                            iconSize: 25.0,
                            onPressed: () {},
                          ),
                        ),
                      ),
                    )*/
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 45,
            child: RaisedButton(
              child: Text(
                'キャンセルする',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              color: Colors.red,
              onPressed: () {
                cancelBooking();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  cancelBooking() {
    String otherCategory = _cancelReasonController.text;
    String cancelReason =
        selectedBuildingType == "その他" ? otherCategory : selectedBuildingType;
    if (cancelReason == null || cancelReason == '') {
      ProgressDialogBuilder.hideLoader(context);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: ColorConstants.snackBarColor,
        duration: Duration(seconds: 3),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text('キャンセルの理由を選択してください。',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontFamily: 'NotoSansJP')),
            ),
            InkWell(
              onTap: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
              child: Text('はい',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'NotoSansJP',
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ));
      return null;
    }
    try {
      var cancelBooking = ServiceUserAPIProvider.updateBookingCompeted(
          HealingMatchConstants
              .therapistProfileDetails.bookingDataResponse[0].id,
          selectedBuildingType);
      DialogHelper.showUserBookingCancelDialog(context);
    } catch (e) {
      print('cancelException : ${e.toString()}');
    }
  }

  void _handleCategoryChange(bool newVal, BuildingCategory category) {
    setState(() {
      if (newVal) {
        _formData['category'] = category;
        selectedBuildingType = category.name;
        print('Chosen value : $newVal : name : $selectedBuildingType');
      } else {
        _formData['category'] = null;
      }
    });
  }
}

class BuildingCategory {
  final String name;

  BuildingCategory({this.name});
}

class BuildingCategories {
  final List<BuildingCategory> categories;

  BuildingCategories(this.categories);

  factory BuildingCategories.initial() {
    return BuildingCategories(
      <BuildingCategory>[
        BuildingCategory(name: '都合が悪くなったため'),
        BuildingCategory(name: '提案のあった追加料金が高かったため'),
        BuildingCategory(name: '提案のあった時間は都合が悪いため'),
        BuildingCategory(name: 'その他'),
      ],
    );
  }
}
