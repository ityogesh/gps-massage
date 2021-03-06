import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gps_massageapp/customLibraryClasses/customToggleButton/CustomToggleButton.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';

class BookingApproveFirstScreen extends StatefulWidget {
  @override
  State createState() {
    return _BookingApproveFirstScreenState();
  }
}

class _BookingApproveFirstScreenState extends State<BookingApproveFirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ApprovalFirstScreen(),
    );
  }
}

class ApprovalFirstScreen extends StatefulWidget {
  @override
  State createState() {
    return _ApprovalFirstScreenState();
  }
}

class _ApprovalFirstScreenState extends State<ApprovalFirstScreen> {
  @override
  Widget build(BuildContext context) {
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
                    dashPattern: [3, 3],
                    strokeWidth: 1,
                    color: Color.fromRGBO(232, 232, 232, 1),
                    strokeCap: StrokeCap.round,
                    borderType: BorderType.Circle,
                    radius: Radius.circular(5),
                    child: CircleAvatar(
                      maxRadius: 55,
                      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                      child: SvgPicture.asset('assets/images_gps/calendar.svg',
                          height: 45,
                          width: 45,
                          color: Color.fromRGBO(200, 217, 33, 1)),
                    )),
                SizedBox(height: 10),
                Text(
                  'セラピストからリクエストがありました。',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontFamily: 'NotoSansJP'),
                ),
                SizedBox(height: 15),
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
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),
                      Expanded(
                        child: new Row(
                          children: [
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            new Container(
                                width: 25.0,
                                height: 25.0,
                                decoration: new BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]),
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: new AssetImage(
                                        'assets/images_gps/profile.png'),
                                  ),
                                )),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              'お名前',
                              style: TextStyle(
                                  fontSize: 16,
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
                              '10月17',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NotoSansJP'),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.03),
                            Text(
                              '月曜日出張',
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
                              '09:  00～10:  00',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'NotoSansJP'),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            new Text(
                              '60分',
                              style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontFamily: 'NotoSansJP'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
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
                              label: Text('足つぼ'),
                              backgroundColor: Colors.white,
                            ),
                            Text(
                              "\t\t¥4,500",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.01),
                            Text(
                              '(交通費込み-1,000)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontFamily: 'NotoSansJP'),
                            ),
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
                              child: CircleAvatar(
                                  maxRadius: 20,
                                  backgroundColor:
                                      Color.fromRGBO(255, 255, 255, 1),
                                  child: SvgPicture.asset(
                                      'assets/images_gps/chat.svg',
                                      height: 30,
                                      width: 30)),
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
                                    '店舗',
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
                                '埼玉県浦和区高砂4丁目4',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontFamily: 'NotoSansJP'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(right: 11, left: 11),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width * 0.35,
                        child: CustomToggleButton(
                          elevation: 0,
                          height: 55.0,
                          width: MediaQuery.of(context).size.width * 0.42,
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
                            } else if (value == 'N') {
                              /* Navigator.of(context, rootNavigator: true)
                                .pop(context);*/
                            }
                          },
                          selectedColor: Color.fromRGBO(255, 0, 0, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
