import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/cardToolTips/timeSpinnerToolTip.dart';
import 'package:gps_massageapp/customLibraryClasses/dropdowns/dropDownServiceUserRegisterScreen.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/therapistBookingHistoryResponseModel.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:gps_massageapp/serviceProvider/APIProviderCalls/ServiceProviderApi.dart';
import 'package:intl/intl.dart';

class ProviderReceiveBooking extends StatefulWidget {
  final BookingDetailsList bookingDetail;
  ProviderReceiveBooking(this.bookingDetail);
  @override
  _ProviderReceiveBookingState createState() => _ProviderReceiveBookingState();
}

class _ProviderReceiveBookingState extends State<ProviderReceiveBooking> {
  TextEditingController providerCommentsController = TextEditingController();
  TextEditingController cancellationReasonController = TextEditingController();
  String price;
  String addedpriceReason;
  bool proposeAdditionalCosts = false;
  bool suggestAnotherTime = false;
  bool onCancel = false;
  ScrollController scrollController = ScrollController();
  GlobalKey startKey = new GlobalKey();
  GlobalKey endKey = new GlobalKey();
  DateTime newStartTime;
  DateTime newEndTime;
  int _state = 0;

  @override
  void initState() {
    newStartTime = widget.bookingDetail.startTime;
    newEndTime = widget.bookingDetail.endTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == 0 && onCancel) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _state = 1;
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            padding:
                EdgeInsets.only(left: 4.0, top: 8.0, bottom: 8.0, right: 0.0),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context)),
        title: Text(
          'お知らせ',
          style: TextStyle(
              color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: 30, left: 10.0, right: 10.0),
          child: Column(
            children: [
              Center(
                child: DottedBorder(
                  dashPattern: [3, 3],
                  strokeWidth: 1,
                  color: Color.fromRGBO(232, 232, 232, 1),
                  strokeCap: StrokeCap.round,
                  borderType: BorderType.Circle,
                  radius: Radius.circular(5),
                  child: CircleAvatar(
                    maxRadius: 55,
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    child: SvgPicture.asset(
                        'assets/images_gps/booking_received.svg',
                        height: 45,
                        width: 45,
                        color: Color.fromRGBO(255, 157, 0, 1)),
                  ),
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              Text(
                'サービス利用者からご予約がありました',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              buildBookingCard(),
              SizedBox(
                height: 18.0,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        proposeAdditionalCosts = !proposeAdditionalCosts;
                      });
                    },
                    child: Container(
                      height: 20.0,
                      width: 20.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: proposeAdditionalCosts
                          ? Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                              ),
                            )
                          : Container(),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    '追加の費用を提案する',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 18.0,
              ),
              proposeAdditionalCosts
                  ? Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                color: Colors.white,
                                child: DropDownFormField(
                                  fillColor: Colors.white,
                                  borderColor: Colors.grey[400],
                                  contentPadding: EdgeInsets.all(1.0),
                                  titleText: null,
                                  hintText: '',
                                  onSaved: (value) {
                                    setState(() {
                                      addedpriceReason = value;
                                    });
                                  },
                                  value: addedpriceReason,
                                  onChanged: (value) {
                                    setState(() {
                                      addedpriceReason = value;
                                    });
                                  },
                                  dataSource: [
                                    {
                                      "display": "交通費",
                                      "value": "交通費",
                                    },
                                    {
                                      "display": "駐車場代",
                                      "value": "駐車場代",
                                    },
                                    {
                                      "display": "交通費＋駐車場代",
                                      "value": "交通費＋駐車場代",
                                    },
                                  ],
                                  textField: 'display',
                                  valueField: 'value',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                color: Colors.white,
                                child: DropDownFormField(
                                  fillColor: Colors.white,
                                  borderColor: Colors.grey[400],
                                  contentPadding: EdgeInsets.all(1.0),
                                  titleText: null,
                                  hintText: '',
                                  onSaved: (value) {
                                    setState(() {
                                      price = value;
                                    });
                                  },
                                  value: price,
                                  onChanged: (value) {
                                    setState(() {
                                      price = value;
                                    });
                                  },
                                  dataSource: [
                                    {
                                      "display": "¥500",
                                      "value": "500",
                                    },
                                    {
                                      "display": "¥600",
                                      "value": "600",
                                    },
                                    {
                                      "display": "¥700",
                                      "value": "700",
                                    },
                                    {
                                      "display": "¥800",
                                      "value": "800",
                                    },
                                    {
                                      "display": "¥900",
                                      "value": "900",
                                    },
                                    {
                                      "display": "¥1000",
                                      "value": "1000",
                                    },
                                    {
                                      "display": "¥1100",
                                      "value": "1100",
                                    },
                                    {
                                      "display": "¥1200",
                                      "value": "1200",
                                    },
                                    {
                                      "display": "¥1300",
                                      "value": "1300",
                                    },
                                    {
                                      "display": "¥1400",
                                      "value": "1400",
                                    },
                                    {
                                      "display": "¥1500",
                                      "value": "1500",
                                    },
                                  ],
                                  textField: 'display',
                                  valueField: 'value',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: 12.0,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        suggestAnotherTime = !suggestAnotherTime;
                      });
                    },
                    child: Container(
                      height: 20.0,
                      width: 20.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: suggestAnotherTime
                          ? Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.black,
                              ),
                            )
                          : Container(),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    '別の時間を提案する',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              suggestAnotherTime
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  /* setState(() {
                                  timePicker = true;
                                }); */
                                },
                                child: InkWell(
                                  onTap: () {
                                    showToolTip(startKey, newStartTime, context,
                                        2, true);
                                  },
                                  child: Container(
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[400]),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Row(
                                        key: startKey,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.bookingDetail.startTime
                                                        .hour <
                                                    10
                                                ? "0${newStartTime.hour}"
                                                : "${newStartTime.hour}",
                                          ),
                                          Text(
                                            widget.bookingDetail.startTime
                                                        .minute <
                                                    10
                                                ? ":0${newStartTime.minute}"
                                                : ":${newStartTime.minute}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text("  ~  "),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  showToolTip(
                                      endKey, newEndTime, context, 2, false);
                                },
                                child: Container(
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[400]),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      key: endKey,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          newEndTime.hour < 10
                                              ? "0${newEndTime.hour}"
                                              : "${newEndTime.hour}",
                                        ),
                                        Text(
                                          newEndTime.minute < 10
                                              ? ":0${newEndTime.minute}"
                                              : ":${newEndTime.minute}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        TextField(
                          controller: providerCommentsController,
                          textInputAction: TextInputAction.done,
                          expands: false,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "距離が遠い為",
                            hintStyle: HealingMatchConstants.formHintTextStyle,
                            border:
                                HealingMatchConstants.multiTextFormInputBorder,
                            focusedBorder:
                                HealingMatchConstants.multiTextFormInputBorder,
                            disabledBorder:
                                HealingMatchConstants.multiTextFormInputBorder,
                            enabledBorder:
                                HealingMatchConstants.multiTextFormInputBorder,
                          ),
                          onChanged: (value) {
                            widget.bookingDetail.therapistComments = value;
                          },
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        buildButton(),
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    )
                  : buildButton(),
              onCancel
                  ? Column(
                      children: [
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: [
                            Text(
                              '予約を受けない、または条件提示の理由',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Stack(
                          children: [
                            TextField(
                              controller: cancellationReasonController,
                              textInputAction: TextInputAction.done,
                              expands: false,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "理由を入力してください。",
                                hintStyle:
                                    HealingMatchConstants.formHintTextStyle,
                                border: HealingMatchConstants
                                    .multiTextFormInputBorder,
                                focusedBorder: HealingMatchConstants
                                    .multiTextFormInputBorder,
                                disabledBorder: HealingMatchConstants
                                    .multiTextFormInputBorder,
                                enabledBorder: HealingMatchConstants
                                    .multiTextFormInputBorder,
                              ),
                              onChanged: (value) {
                                widget.bookingDetail.cancellationReason = value;
                              },
                            ),
                            Positioned(
                              bottom: 5.0,
                              right: 5.0,
                              child: InkWell(
                                onTap: () {
                                  ProgressDialogBuilder
                                      .showCommonProgressDialog(context);

                                  ServiceProviderApi.updateStatusUpdate(
                                          widget.bookingDetail,
                                          false,
                                          false,
                                          onCancel)
                                      .then((value) {
                                    ProgressDialogBuilder
                                        .hideCommonProgressDialog(context);
                                    if (value) {
                                      NavigationRouter
                                          .switchToServiceProviderBottomBar(
                                              context);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: Colors.grey[400])),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset(
                                      'assets/images_gps/comment_send.svg',
                                      height: 21,
                                      width: 21,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Card buildBookingCard() {
    String jaName =
        DateFormat('EEEE', 'ja_JP').format(widget.bookingDetail.startTime);
    return Card(
      // margin: EdgeInsets.all(8.0),
      color: Color.fromRGBO(242, 242, 242, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    widget.bookingDetail.bookingUserId.uploadProfileImgUrl !=
                            null
                        ? CachedNetworkImage(
                            width: 18.0,
                            height: 18.0,
                            fit: BoxFit.cover,
                            imageUrl: widget.bookingDetail.bookingUserId
                                .uploadProfileImgUrl,
                            placeholder: (context, url) => SpinKitWave(
                                size: 20.0, color: ColorConstants.buttonColor),
                            errorWidget: (context, url, error) => Column(
                                  children: [
                                    SvgPicture.asset(
                                        'assets/images_gps/profile_pic_user.svg',
                                        height: 18,
                                        width: 18,
                                        color: Colors.black),
                                  ],
                                ))
                        : SvgPicture.asset(
                            'assets/images_gps/profile_pic_user.svg',
                            height: 18,
                            width: 18,
                            color: Colors.black),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      '${widget.bookingDetail.bookingUserId.userName}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${widget.bookingDetail.bookingUserId.gender})',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color.fromRGBO(181, 181, 181, 1),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.all(4),
                      child: Text(
                        widget.bookingDetail.locationType == "店舗" ? '店舗' : '出張',
                        style: TextStyle(
                          fontSize: 9.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${widget.bookingDetail.updatedAt.hour}:${widget.bookingDetail.updatedAt.minute} 時',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    NavigationRouter.switchToProviderSideUserReviewScreen(
                        context, widget.bookingDetail.userId);
                  },
                  child: Row(
                    children: [
                      Text(
                        '${widget.bookingDetail.reviewAvgData}',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(0, -3))
                            ],
                            fontSize: 14,
                            color: Colors.transparent,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5.0),
                      RatingBar.builder(
                        initialRating:
                            double.parse(widget.bookingDetail.reviewAvgData),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 24.0,
                        itemPadding: new EdgeInsets.only(bottom: 3.0),
                        itemBuilder: (context, index) => new SizedBox(
                            height: 20.0,
                            width: 18.0,
                            child: new IconButton(
                              onPressed: () {},
                              padding: new EdgeInsets.all(0.0),
                              // color: Colors.white,
                              icon: index >
                                      (double.parse(widget
                                                  .bookingDetail.reviewAvgData))
                                              .ceilToDouble() -
                                          1
                                  ? SvgPicture.asset(
                                      "assets/images_gps/star_2.svg",
                                      height: 13.0,
                                      width: 13.0,
                                    )
                                  : SvgPicture.asset(
                                      "assets/images_gps/star_colour.svg",
                                      height: 13.0,
                                      width: 13.0,
                                      //color: Colors.black,
                                    ),
                            )),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        '${widget.bookingDetail.noOfReviewsMembers}',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(0, -3))
                            ],
                            fontSize: 14,
                            color: Colors.transparent,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images_gps/calendar.svg",
                      height: 14.77,
                      width: 16.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${widget.bookingDetail.startTime.month}月${widget.bookingDetail.startTime.day}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      ' $jaName ',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color.fromRGBO(102, 102, 102, 1),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images_gps/clock.svg",
                      height: 14.77,
                      width: 16.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${widget.bookingDetail.startTime.hour}: ${widget.bookingDetail.startTime.minute} ~ ${widget.bookingDetail.endTime.hour}: ${widget.bookingDetail.endTime.minute}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' ${widget.bookingDetail.totalMinOfService}分 ',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color.fromRGBO(102, 102, 102, 1),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.all(4),
                      child: Text(
                        '${widget.bookingDetail.nameOfService}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Divider(
                  // height: 50,
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images_gps/gps.svg",
                      height: 14.77,
                      width: 16.0,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '施術をする場所',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 18.0, right: 18.0, top: 4.0, bottom: 4.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Center(
                        child: Text(
                          '${widget.bookingDetail.locationType}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${widget.bookingDetail.location}',
                      style: TextStyle(
                        color: Color.fromRGBO(102, 102, 102, 1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                widget.bookingDetail.userComments != null &&
                        widget.bookingDetail.userComments != ''
                    ? Column(
                        children: [
                          SizedBox(
                            height: 2,
                          ),
                          Divider(
                            // height: 50,
                            color: Color.fromRGBO(217, 217, 217, 1),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Center(
                            child: Text(
                              '${widget.bookingDetail.userComments}',
                              style: TextStyle(
                                color: Color.fromRGBO(102, 102, 102, 1),
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              setState(() {
                onCancel = true;
              });
            },
            //  minWidth: MediaQuery.of(context).size.width * 0.38,
            // splashColor: Colors.grey,
            color: Color.fromRGBO(217, 217, 217, 1),
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Text(
              '断る',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              ProgressDialogBuilder.showCommonProgressDialog(context);
              widget.bookingDetail.newStartTime = newStartTime;
              widget.bookingDetail.newEndTime = newEndTime;
              widget.bookingDetail.addedPrice = addedpriceReason;
              widget.bookingDetail.travelAmount = price;
              ServiceProviderApi.updateStatusUpdate(widget.bookingDetail,
                      proposeAdditionalCosts, suggestAnotherTime, onCancel)
                  .then((value) {
                ProgressDialogBuilder.hideCommonProgressDialog(context);
                if (value) {
                  NavigationRouter.switchToServiceProviderBottomBar(context);
                }
              });
            },
            //   minWidth: MediaQuery.of(context).size.width * 0.38,
            splashColor: Colors.pinkAccent[600],
            color: Color.fromRGBO(200, 217, 33, 1),
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Text(
              '受ける',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //Method called from ShowtoolTip to refresh the page after TimePicker is Selected
  refreshPage(int index, DateTime newTime, bool isStart) {
    setState(() {
      if (isStart) {
        newStartTime = newTime;
        newEndTime = DateTime(
          newStartTime.year,
          newStartTime.month,
          newStartTime.day,
          newStartTime.hour,
          newStartTime.minute + widget.bookingDetail.totalMinOfService,
          newStartTime.second,
        );
      } else {
        newEndTime = newTime;
        newStartTime = DateTime(
          newEndTime.year,
          newEndTime.month,
          newEndTime.day,
          newEndTime.hour,
          newEndTime.minute - widget.bookingDetail.totalMinOfService,
          newEndTime.second,
        );
      }
    });
  }

  void showToolTip(
      var key, DateTime time, BuildContext context, int index, bool isStart) {
    var width = MediaQuery.of(context).size.width - 10.0;
    print(width);
    ShowToolTip popup = ShowToolTip(context, refreshPage,
        time: time,
        index: index,
        isStart: isStart,
        textStyle: TextStyle(color: Colors.black),
        height: 110,
        width: MediaQuery.of(context).size.width * 0.73, //180,
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.circular(10.0));

    /// show the popup for specific widget
    popup.show(
      widgetKey: key,
    );
  }
}
