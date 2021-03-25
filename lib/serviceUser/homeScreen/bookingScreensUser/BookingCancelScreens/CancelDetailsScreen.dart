import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/alertDialogHelper/dialogHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/customRadioButtonList/roundedRadioButton.dart';
import 'package:gps_massageapp/customLibraryClasses/customToggleButton/CustomToggleButton.dart';

bool isOtherSelected = false;
final _cancelReasonController = new TextEditingController();
Map<String, dynamic> _formData = {
  'text': null,
  'category': null,
  'date': null,
  'time': null,
};
var selectedBuildingType;

class CancelDetailsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CancelDetailsScreenState();
  }
}

class _CancelDetailsScreenState extends State<CancelDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [ConfirmCancelScreen()],
      ),
    );
  }
}

class ConfirmCancelScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConfirmCancelScreenState();
  }
}

class _ConfirmCancelScreenState extends State<ConfirmCancelScreen> {
  @override
  Widget build(BuildContext context) {
    return CancelPopupScreen();
  }

  Widget CancelPopupScreen() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 150),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.87,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(20.0),
          boxShadow: [
            new BoxShadow(
                color: Colors.grey[300],
                blurRadius: 3.0,
                offset: new Offset(1.0, 1.0))
          ],
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            margin: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      maxRadius: 40,
                      backgroundColor: Colors.grey[200],
                      child: CircleAvatar(
                        maxRadius: 39,
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        child: Image.asset('assets/images_gps/calendar.png'),
                      ),
                    ),
                    Positioned(
                        top: 50,
                        left: 50,
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          maxRadius: 9.0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            maxRadius: 8.0,
                            child: Icon(Icons.clear,
                                size: 12, color: Colors.black),
                          ),
                        ))
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'キャンセルしてもよろしいでしょうか。',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'NotoSansJP'),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: TextField(
                    controller: _cancelReasonController,
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    maxLines: 5,
                    decoration: new InputDecoration(
                        filled: false,
                        fillColor: Colors.white,
                        hintText: 'キャンセルする理由を記入ください',
                        hintStyle: TextStyle(color: Colors.grey[300]),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[300], width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[300], width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[300], width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                  ),
                ),
                SizedBox(height: 5),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5, left: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width * 0.35,
                            child: CustomToggleButton(
                              elevation: 0,
                              height: 55.0,
                              width: 145.0,
                              autoWidth: false,
                              buttonColor: Colors.grey[300],
                              enableShape: true,
                              customShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.transparent)),
                              buttonLables: ["はい", "いいえ"],
                              fontSize: 16.0,
                              buttonValues: [
                                "Y",
                                "N",
                              ],
                              radioButtonValue: (value) {
                                if (value == 'Y') {
                                  DialogHelper.showUserBookingCancelDialog(
                                      context);
                                } else if (value == 'N') {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(context);
                                }
                              },
                              selectedColor: Colors.lime,
                            ),
                          ),
                          SizedBox(height: 20)
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
