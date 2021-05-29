import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/therapistBookingHistoryResponseModel.dart';
import 'package:gps_massageapp/serviceProvider/APIProviderCalls/ServiceProviderApi.dart';
import 'package:intl/intl.dart';

class ProviderCancelScreen extends StatefulWidget {
  @override
  _ProviderCancelScreenState createState() => _ProviderCancelScreenState();
}

class _ProviderCancelScreenState extends State<ProviderCancelScreen> {
  List<BookingDetailsList> requestBookingDetailsList =
      List<BookingDetailsList>();
  int status = 0;

  @override
  void initState() {
    super.initState();
    ServiceProviderApi.getCanceledBookingDetails().then((value) {
      setState(() {
        requestBookingDetailsList.addAll(value.data.bookingDetailsList);
        status = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return status == 0
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            primary: true,
            child: Container(
              padding: EdgeInsets.all(8.0),
              //  margin: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                            height: 15,
                          ),
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: requestBookingDetailsList.length,
                      itemBuilder: (context, index) {
                        return buildBookingCard(index);
                      }),
                ],
              ),
            ),
          );
  }

  Card buildBookingCard(int index) {
    String jaName = DateFormat('EEEE', 'ja_JP')
        .format(requestBookingDetailsList[index].startTime);
    return Card(
      // margin: EdgeInsets.all(8.0),
      color: Color.fromRGBO(242, 242, 242, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${requestBookingDetailsList[index].bookingUserId.userName}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(${requestBookingDetailsList[index].bookingUserId.gender})',
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
                      requestBookingDetailsList[index].locationType == "店舗"
                          ? '店舗'
                          : '出張',
                      style: TextStyle(
                        fontSize: 9.0,
                        color: Colors.black,
                      ),
                    )),
              ],
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
                  '${requestBookingDetailsList[index].startTime.month}月${requestBookingDetailsList[index].startTime.day}',
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
                  '${requestBookingDetailsList[index].startTime.hour}: ${requestBookingDetailsList[index].startTime.minute} ~ ${requestBookingDetailsList[index].endTime.hour}: ${requestBookingDetailsList[index].endTime.minute}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' ${requestBookingDetailsList[index].totalMinOfService}分 ',
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
                    '${requestBookingDetailsList[index].nameOfService}',
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
                      '${requestBookingDetailsList[index].locationType}',
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
                  '${requestBookingDetailsList[index].location}',
                  style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                    fontSize: 17,
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
                Text(
                  '${requestBookingDetailsList[index].cancellationReason}',
                  style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                    fontSize: 17,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
