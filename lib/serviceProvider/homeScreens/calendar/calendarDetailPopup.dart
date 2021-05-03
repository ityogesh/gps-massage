import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:googleapis/calendar/v3.dart' as Calendar;

class ProviderCalendarDetailPopup {
  static void showBookingDetail(BuildContext context, Calendar.Event event,
      DateTime start, DateTime end) {
    Calendar.Event googleApiEvent = event;
    var split = googleApiEvent.summary.split(',');
    /* int idx = s.indexOf(":");
    List parts = [s.substring(0, idx).trim(), s.substring(idx + 1).trim()]; */
    int desIndex = googleApiEvent.description.indexOf(',');
    var desSplit = [
      googleApiEvent.description.substring(0, desIndex).trim(),
      googleApiEvent.description.substring(desIndex + 1).trim()
    ];
    int locIndex = googleApiEvent.location.indexOf(',');
    var locSplit = [
      googleApiEvent.location.substring(0, desIndex).trim(),
      googleApiEvent.location.substring(desIndex + 1).trim()
    ];
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)), //this right here
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(242, 242, 242, 1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          HealingMatchConstants.isProvider
                              ? split[3]
                              : split[1],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        googleApiEvent.status == 'tentative'
                            ? Row(
                                children: [
                                  SvgPicture.asset(
                                    "assets/images_gps/processing.svg",
                                    height: 20.0,
                                    width: 20.0,
                                  ),
                                  Text("承認待ち",
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 193, 7, 1),
                                      ))
                                ],
                              )
                            : Row(
                                children: [
                                  Text("承認済み",
                                      style: TextStyle(color: Colors.black))
                                ],
                              )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/images_gps/calendar.svg",
                          height: 14.77,
                          width: 15.0,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          '${start.day}月${start.month}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' 月曜日 ',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromRGBO(102, 102, 102, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                          '${start.hour}:${start.minute} ~ ${end.hour}: ${end.minute}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' 60分 ',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromRGBO(102, 102, 102, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/images_gps/clock.svg",
                          height: 14.77,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              ' ${desSplit[0]} ',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          ' ${desSplit[1]}',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Divider(
                      color: Color.fromRGBO(102, 102, 102, 1),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/images_gps/location.svg",
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
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${locSplit[0]} ',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          '${locSplit[1]} ',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromRGBO(102, 102, 102, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: ColorConstants.buttonColor,
                        child: Text(
                          "OK",
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
