import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/providerEventCalendar/src/event.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/shiftTimeUpdateResponse.dart'
    as shiftTimeUpdate;
import 'package:gps_massageapp/models/responseModels/serviceProvider/therapistBookingHistoryResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/userReviewandRatingsResponseModel.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:http/http.dart' as http;
import 'package:gps_massageapp/models/responseModels/serviceProvider/providerReviewandRatingsViewResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/userReviewCreateResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/ProviderDetailsResponseModel.dart';
import "package:googleapis_auth/auth_io.dart";
import "package:googleapis/calendar/v3.dart";
import 'dart:developer';

class ServiceProviderApi {
  static const _scopes = const [CalendarApi.calendarScope];

  static Future<ProviderReviewandRatingsViewResponseModel>
      getTherapistReviewById(int pageNumber, int pageSize) async {
    try {
      final url = HealingMatchConstants.ON_PREMISE_USER_BASE_URL +
          '/mobileReview/therapistReviewListById?page=$pageNumber&size=$pageSize';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": HealingMatchConstants.userId,
          }));
      //  print('Therapist repo token : $accessToken : Tid  : $therapistId');
      if (response.statusCode == 200) {
        var therapistData = json.decode(response.body);
        ProviderReviewandRatingsViewResponseModel therapistUsers =
            ProviderReviewandRatingsViewResponseModel.fromJson(therapistData);
        print('Types list:  $therapistData');
        return therapistUsers;
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  static Future<UserReviewandRatingsViewResponseModel> getUserReviewById(
      int pageNumber, int pageSize) async {
    try {
      final url = HealingMatchConstants.ON_PREMISE_USER_BASE_URL +
          '/mobileReview/userReviewListById?page=$pageNumber&size=$pageSize';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "userId": HealingMatchConstants.serviceUserId, //'20',
          }));
      print(
          'Therapist repo token :${HealingMatchConstants.accessToken} : UserId  : ${HealingMatchConstants.serviceUserId}');
      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        UserReviewandRatingsViewResponseModel usersReview =
            UserReviewandRatingsViewResponseModel.fromJson(userData);
        print('Types list:  $userData');
        return usersReview;
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  static Future<UserReviewCreateResponseModel> giveUserReview(
      double rating, String review) async {
    try {
      final url = HealingMatchConstants.ON_PREMISE_USER_BASE_URL +
          '/mobileReview/createUserReview';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "userId": '20', //HealingMatchConstants.serviceUserId,
            "ratingsCount": rating,
            "reviewComment": review,
          }));
      print('$response');
      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        UserReviewCreateResponseModel usersReview =
            UserReviewCreateResponseModel.fromJson(userData);
        print('Types list:  $userData');
        return usersReview;
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  static Future<List<FlutterWeekViewEvent>> getCalEvents() async {
    List<FlutterWeekViewEvent> flutterEvents = List<FlutterWeekViewEvent>();
    List<FlutterWeekViewEvent> unavailableCalendarEvents =
        List<FlutterWeekViewEvent>();
    var accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "cc971fe468280c2bb3c63dbdaffd886a5a781acd",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChN1yuJiB8W4pp\ngMWBnglEBahi5BEo8i1BG3Lz7ANg1wrKK9VB2btT0KHXBQk3eT6qXiv4Mp0ScTWJ\n3xEaR2VKPzb07PPIUr4b9DL7XMfHEYg3Hyfr+oz7De1mwgbmuzEZD66MxFfbL54V\nkHUOgvbtq5QbafaOMBrzsA7GUu2GRSo50KZB1NEL4ffiUx40KmeoP6ZwlFGLlkCN\n+cu4KoVaouPbXNC52lSH+ma4ePlaCXbbDpkdDjvtvEXm8UMLp2+xJEvVsjLy7hAa\nk4R12uVuNhg1IQakAecIWFYIrKwFvbzBsP/yEWcTvds3vHOrJtLzFIppVm26ChBe\nLGC1ngc9AgMBAAECggEACdn09SRZzFeYrelDSHAkj05MM5zNqqOf3dBkViD4NOD3\nJRMIIVHBh3Xiid3iKgxj5qvCApTvMbsOwznJFQLDXwXdYRqgq/9YZCNoQSFyiMja\nusmR2jLxjf7UILkfDFbogWhKqYnu93MhtR4idQxONAhN0N4JBbfNUdJSmM5k+tUi\ns9IwrlsH+ngSBe8gKjO2EmwmVGJBWse4rbCcGStzA/0Li2IQ7Ez0q0Wy1rkcFfIq\nwTqOLt12m5BtZ/k0qzTCWnZ5yNB7Y5sSpqFFidUjD7pmiakJk8H+luwv+fwVPlRa\nvAHCgsj9iIb3BoVNGIQoCLIFl/UfXG0cV3FI2sg/4QKBgQDgVCsflWk9H0fVzS56\nJp3kD766F08aY/cbkgzCFmKY2YfGDr06gBlD/Gqmhi8PwHjYhdAbt8hfKegwfBxg\n/mSemzV6uQaKaqEtEKiToL2zb2T6H4y5kVOv4frU4nrrAnPbLaD6iTEWmB+9WjrI\nLjZQortcm5Iqyb+0PVbH/AQcYQKBgQC3+iQgqeni7zQw0Ro3AmsEK6SHYONM6y0z\n0fUS2eMkxwj1uTchmshesZrVocqm4CMORU6i5GR/7e+rNrnuDybAEVNGExS0XmaJ\nNmHDzqmYaQ+mdmM1SlJl8pXDnocT+dZqCIAswIg05gT3l3TxCHxS5EPfrIMmgVod\ns/asnfq4XQKBgATCBEAhPSAsv6tLNMcmdobVxqfPwr++iwksqdScAO9Y/cY3nc/V\n07NbcS+i/PCKloWRIP7VgQxzqRcOKtPr0VqD1DiMIBVjeZOpHMo0yJE7tZqQfL2a\n1XmPg3BsdUryvF5Ts2xc6IugIlwzw7dnM4O2T98A9bKuoMBD5MlNERFBAoGAbBhS\npcZvn2CAP7Z8Opn3Gsoxr0EkDAuZ0XqpDdxrcy5me0nJtLrmw4yCtsaK9SV4M2hR\nXa/nxKqeSPCsqczJLcyAKwoG/jsA79m983g3eU8xXNLuU19JrpCrofZA02HVsxMv\njBvLa5lCjd61XPFpaqKnpoILxNH3isA0TRO9PhkCgYEAq0nGMl0LtTPACOAHW8GS\nlBtntpcoxJShS99DHqe9UGxkp49ytpWDVXL71fL9aGGXumjg2esSVSkFRRWajcj3\n+DVXf0HJ+AA2U21GAIjtZ4wuOqJBK/aiCSEvE/pnDGnpUG72ouH9v0gKOxapm4UJ\nh9+CT/1T5O6d2bywzHMgI4Q=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "sample-service-account-1@calendarapi-291906.iam.gserviceaccount.com",
      "client_id": "110731698305796155207",
      "type": "service_account"
    });
    final httpClient =
        await clientViaServiceAccount(accountCredentials, _scopes);
    var calendar = CalendarApi(httpClient);
    var calEvents = calendar.events.list(
      "aswin007arun@gmail.com",
      q: "SP15",
      /*  timeMax: lastMonth.toUtc(), timeMin: firstMonth.toUtc() */
    );
    Events events = await calEvents;
    List<Event> unavailableEvents = List<Event>();
    events.items.forEach((event) {
      // {events.items.forEach((event) => print("EVENT ${event.summary}"))});
      if (event.description == "unavailable") {
        unavailableEvents.add(event);
      } else {
        flutterEvents.add(
          FlutterWeekViewEvent(
            events: event,
            start: event.start.dateTime.toLocal(),
            end: event.end.dateTime.toLocal(),
          ),
        );
      }
    });
    unavailableEvents
        .sort((a, b) => a.start.dateTime.compareTo(b.start.dateTime));
    for (var unavailableEvent in unavailableEvents) {
      if (unavailableCalendarEvents.length == 0) {
        unavailableCalendarEvents.add(
          FlutterWeekViewEvent(
            events: unavailableEvent,
            start: unavailableEvent.start.dateTime.toLocal(),
            end: unavailableEvent.end.dateTime.toLocal(),
          ),
        );
      } else if (unavailableCalendarEvents[unavailableCalendarEvents.length - 1]
              .end ==
          unavailableEvent.start.dateTime.toLocal()) {
        unavailableCalendarEvents[unavailableCalendarEvents.length - 1].end =
            unavailableEvent.end.dateTime.toLocal();
      } else {
        unavailableCalendarEvents.add(
          FlutterWeekViewEvent(
            events: unavailableEvent,
            start: unavailableEvent.start.dateTime.toLocal(),
            end: unavailableEvent.end.dateTime.toLocal(),
          ),
        );
      }
    }
    if (unavailableCalendarEvents.length != 0) {
      flutterEvents.addAll(unavailableCalendarEvents);
    }
    HealingMatchConstants.events.clear();
    HealingMatchConstants.events.addAll(flutterEvents);
    httpClient.close();
    return HealingMatchConstants.events;
  }

  //mark unavailable from xo calendar
  static Future<Event> createEvent(
      DateTime eventTime, BuildContext context) async {
    var accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "cc971fe468280c2bb3c63dbdaffd886a5a781acd",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChN1yuJiB8W4pp\ngMWBnglEBahi5BEo8i1BG3Lz7ANg1wrKK9VB2btT0KHXBQk3eT6qXiv4Mp0ScTWJ\n3xEaR2VKPzb07PPIUr4b9DL7XMfHEYg3Hyfr+oz7De1mwgbmuzEZD66MxFfbL54V\nkHUOgvbtq5QbafaOMBrzsA7GUu2GRSo50KZB1NEL4ffiUx40KmeoP6ZwlFGLlkCN\n+cu4KoVaouPbXNC52lSH+ma4ePlaCXbbDpkdDjvtvEXm8UMLp2+xJEvVsjLy7hAa\nk4R12uVuNhg1IQakAecIWFYIrKwFvbzBsP/yEWcTvds3vHOrJtLzFIppVm26ChBe\nLGC1ngc9AgMBAAECggEACdn09SRZzFeYrelDSHAkj05MM5zNqqOf3dBkViD4NOD3\nJRMIIVHBh3Xiid3iKgxj5qvCApTvMbsOwznJFQLDXwXdYRqgq/9YZCNoQSFyiMja\nusmR2jLxjf7UILkfDFbogWhKqYnu93MhtR4idQxONAhN0N4JBbfNUdJSmM5k+tUi\ns9IwrlsH+ngSBe8gKjO2EmwmVGJBWse4rbCcGStzA/0Li2IQ7Ez0q0Wy1rkcFfIq\nwTqOLt12m5BtZ/k0qzTCWnZ5yNB7Y5sSpqFFidUjD7pmiakJk8H+luwv+fwVPlRa\nvAHCgsj9iIb3BoVNGIQoCLIFl/UfXG0cV3FI2sg/4QKBgQDgVCsflWk9H0fVzS56\nJp3kD766F08aY/cbkgzCFmKY2YfGDr06gBlD/Gqmhi8PwHjYhdAbt8hfKegwfBxg\n/mSemzV6uQaKaqEtEKiToL2zb2T6H4y5kVOv4frU4nrrAnPbLaD6iTEWmB+9WjrI\nLjZQortcm5Iqyb+0PVbH/AQcYQKBgQC3+iQgqeni7zQw0Ro3AmsEK6SHYONM6y0z\n0fUS2eMkxwj1uTchmshesZrVocqm4CMORU6i5GR/7e+rNrnuDybAEVNGExS0XmaJ\nNmHDzqmYaQ+mdmM1SlJl8pXDnocT+dZqCIAswIg05gT3l3TxCHxS5EPfrIMmgVod\ns/asnfq4XQKBgATCBEAhPSAsv6tLNMcmdobVxqfPwr++iwksqdScAO9Y/cY3nc/V\n07NbcS+i/PCKloWRIP7VgQxzqRcOKtPr0VqD1DiMIBVjeZOpHMo0yJE7tZqQfL2a\n1XmPg3BsdUryvF5Ts2xc6IugIlwzw7dnM4O2T98A9bKuoMBD5MlNERFBAoGAbBhS\npcZvn2CAP7Z8Opn3Gsoxr0EkDAuZ0XqpDdxrcy5me0nJtLrmw4yCtsaK9SV4M2hR\nXa/nxKqeSPCsqczJLcyAKwoG/jsA79m983g3eU8xXNLuU19JrpCrofZA02HVsxMv\njBvLa5lCjd61XPFpaqKnpoILxNH3isA0TRO9PhkCgYEAq0nGMl0LtTPACOAHW8GS\nlBtntpcoxJShS99DHqe9UGxkp49ytpWDVXL71fL9aGGXumjg2esSVSkFRRWajcj3\n+DVXf0HJ+AA2U21GAIjtZ4wuOqJBK/aiCSEvE/pnDGnpUG72ouH9v0gKOxapm4UJ\nh9+CT/1T5O6d2bywzHMgI4Q=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "sample-service-account-1@calendarapi-291906.iam.gserviceaccount.com",
      "client_id": "110731698305796155207",
      "type": "service_account"
    });
    final httpClient =
        await clientViaServiceAccount(accountCredentials, _scopes);

    var calendar = CalendarApi(httpClient);
    String calendarId = "aswin007arun@gmail.com";
    Event event = Event(); // Create object of event

    event.summary = "SP15";
    event.description = "unavailable";
    event.location = "店舗,Thindal, Erode - 12";
    event.status = "confirmed";

    DateTime startTime = DateTime(eventTime.year, eventTime.month,
        eventTime.day, eventTime.hour, eventTime.minute, eventTime.second);

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+05:30";
    event.start = start;

    DateTime endTime = startTime.add(Duration(minutes: 15));

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT+05:30";
    end.dateTime = endTime;
    event.end = end;

    try {
      Event addedEvent = await calendar.events.insert(event, calendarId);
      return addedEvent;
      /*  calendar.events.insert(event, calendarId).then((value) {
        print("ADDEDDD_________________${value.status}");
        return value;
        // ProgressDialogBuilder.hideCommonProgressDialog(context);
      }); */
    } catch (e) {
      log('Error creating event $e');
    }
  }

  static removeEvent(String eventID, BuildContext context) async {
    var accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "cc971fe468280c2bb3c63dbdaffd886a5a781acd",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChN1yuJiB8W4pp\ngMWBnglEBahi5BEo8i1BG3Lz7ANg1wrKK9VB2btT0KHXBQk3eT6qXiv4Mp0ScTWJ\n3xEaR2VKPzb07PPIUr4b9DL7XMfHEYg3Hyfr+oz7De1mwgbmuzEZD66MxFfbL54V\nkHUOgvbtq5QbafaOMBrzsA7GUu2GRSo50KZB1NEL4ffiUx40KmeoP6ZwlFGLlkCN\n+cu4KoVaouPbXNC52lSH+ma4ePlaCXbbDpkdDjvtvEXm8UMLp2+xJEvVsjLy7hAa\nk4R12uVuNhg1IQakAecIWFYIrKwFvbzBsP/yEWcTvds3vHOrJtLzFIppVm26ChBe\nLGC1ngc9AgMBAAECggEACdn09SRZzFeYrelDSHAkj05MM5zNqqOf3dBkViD4NOD3\nJRMIIVHBh3Xiid3iKgxj5qvCApTvMbsOwznJFQLDXwXdYRqgq/9YZCNoQSFyiMja\nusmR2jLxjf7UILkfDFbogWhKqYnu93MhtR4idQxONAhN0N4JBbfNUdJSmM5k+tUi\ns9IwrlsH+ngSBe8gKjO2EmwmVGJBWse4rbCcGStzA/0Li2IQ7Ez0q0Wy1rkcFfIq\nwTqOLt12m5BtZ/k0qzTCWnZ5yNB7Y5sSpqFFidUjD7pmiakJk8H+luwv+fwVPlRa\nvAHCgsj9iIb3BoVNGIQoCLIFl/UfXG0cV3FI2sg/4QKBgQDgVCsflWk9H0fVzS56\nJp3kD766F08aY/cbkgzCFmKY2YfGDr06gBlD/Gqmhi8PwHjYhdAbt8hfKegwfBxg\n/mSemzV6uQaKaqEtEKiToL2zb2T6H4y5kVOv4frU4nrrAnPbLaD6iTEWmB+9WjrI\nLjZQortcm5Iqyb+0PVbH/AQcYQKBgQC3+iQgqeni7zQw0Ro3AmsEK6SHYONM6y0z\n0fUS2eMkxwj1uTchmshesZrVocqm4CMORU6i5GR/7e+rNrnuDybAEVNGExS0XmaJ\nNmHDzqmYaQ+mdmM1SlJl8pXDnocT+dZqCIAswIg05gT3l3TxCHxS5EPfrIMmgVod\ns/asnfq4XQKBgATCBEAhPSAsv6tLNMcmdobVxqfPwr++iwksqdScAO9Y/cY3nc/V\n07NbcS+i/PCKloWRIP7VgQxzqRcOKtPr0VqD1DiMIBVjeZOpHMo0yJE7tZqQfL2a\n1XmPg3BsdUryvF5Ts2xc6IugIlwzw7dnM4O2T98A9bKuoMBD5MlNERFBAoGAbBhS\npcZvn2CAP7Z8Opn3Gsoxr0EkDAuZ0XqpDdxrcy5me0nJtLrmw4yCtsaK9SV4M2hR\nXa/nxKqeSPCsqczJLcyAKwoG/jsA79m983g3eU8xXNLuU19JrpCrofZA02HVsxMv\njBvLa5lCjd61XPFpaqKnpoILxNH3isA0TRO9PhkCgYEAq0nGMl0LtTPACOAHW8GS\nlBtntpcoxJShS99DHqe9UGxkp49ytpWDVXL71fL9aGGXumjg2esSVSkFRRWajcj3\n+DVXf0HJ+AA2U21GAIjtZ4wuOqJBK/aiCSEvE/pnDGnpUG72ouH9v0gKOxapm4UJ\nh9+CT/1T5O6d2bywzHMgI4Q=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "sample-service-account-1@calendarapi-291906.iam.gserviceaccount.com",
      "client_id": "110731698305796155207",
      "type": "service_account"
    });
    final httpClient =
        await clientViaServiceAccount(accountCredentials, _scopes);

    var calendar = CalendarApi(httpClient);
    String calendarId = "aswin007arun@gmail.com";

    try {
      calendar.events.delete(calendarId, eventID).then((value) {
        ProgressDialogBuilder.hideCommonProgressDialog(context);

        print("Removed______");
      });
    } catch (e) {
      log('Error creating event $e');
    }
  }

  static Future<ProviderDetailsResponseModel> getProfitandRatingApi() async {
    //ProviderDetailsResponseModel therapistDetails;

    try {
      final url = HealingMatchConstants.THERAPIST_DETAILS_BY_ID;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapist_id": HealingMatchConstants.userId,
          }));
      if (response.statusCode == 200) {
        var therapistData = json.decode(response.body);
        ProviderDetailsResponseModel therapistDetails =
            ProviderDetailsResponseModel.fromJson(therapistData);
        print('a');
        HealingMatchConstants.therapistDetails =
            therapistDetails.data.storeServiceTimes;
        HealingMatchConstants.storeServiceTime =
            json.encode(therapistDetails.data.storeServiceTimes);
        return therapistDetails;
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  static saveShiftServiceTime(
      List<StoreServiceTime> storeServiceTime, BuildContext context) async {
    try {
      final url = HealingMatchConstants.THERAPIST_SHIFT_TIME_SAVE;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      print(json.encode(storeServiceTime[0]));
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            //"storeServiceTime": json.encode(storeServiceTime)
            "monday": "[" + json.encode(storeServiceTime[0]) + "]",
            "tuesday": "[" + json.encode(storeServiceTime[1]) + "]",
            "wednesday": "[" + json.encode(storeServiceTime[2]) + "]",
            "thursday": "[" + json.encode(storeServiceTime[3]) + "]",
            "friday": "[" + json.encode(storeServiceTime[4]) + "]",
            "saturday": "[" + json.encode(storeServiceTime[5]) + "]",
            "sunday": "[" + json.encode(storeServiceTime[6]) + "]",
          }));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        shiftTimeUpdate.ShiftTimeUpdateResponse shiftTimeUpdateResponse =
            shiftTimeUpdate.ShiftTimeUpdateResponse.fromJson(data);
        HealingMatchConstants.therapistDetails.clear();
        ProgressDialogBuilder.hideCommonProgressDialog(context);
        /*  Navigator.pop(context);
        Navigator.pop(context); */
        NavigationRouter.switchToServiceProviderBottomBar(context);
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  static Future<bool> saveFirebaseUserID(
      String firebaseID, BuildContext context) async {
    try {
      final url = HealingMatchConstants.FIREBASE_UPDATE_USERID;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "id": HealingMatchConstants.userId,
            "isTherapist": 1,
            "firebaseUDID": firebaseID
          }));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
      return false;
    }
  }

  static Future<TherapistBookingHistoryResponseModel>
      getBookingRequests() async {
    TherapistBookingHistoryResponseModel therapistBookingHistoryResponseModel;
    try {
      final url = HealingMatchConstants.THERAPIST_BOOKING_REQUEST;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": 18, //HealingMatchConstants.userId,
          }));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        therapistBookingHistoryResponseModel =
            TherapistBookingHistoryResponseModel.fromJson(data);
        return therapistBookingHistoryResponseModel;
      } else {
        return therapistBookingHistoryResponseModel;
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
      return therapistBookingHistoryResponseModel;
    }
  }

  static Future<TherapistBookingHistoryResponseModel>
      getBookingApprovedDetails() async {
    TherapistBookingHistoryResponseModel therapistBookingHistoryResponseModel;
    try {
      final url = HealingMatchConstants.THERAPIST_BOOKING_APPROVED;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": 18, //HealingMatchConstants.userId,
          }));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        therapistBookingHistoryResponseModel =
            TherapistBookingHistoryResponseModel.fromJson(data);
        return therapistBookingHistoryResponseModel;
      } else {
        return therapistBookingHistoryResponseModel;
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
      return therapistBookingHistoryResponseModel;
    }
  }

  static Future<TherapistBookingHistoryResponseModel>
      getConfirmedBookingDetails(int pageNumber, int pageSize) async {
    TherapistBookingHistoryResponseModel therapistBookingHistoryResponseModel;
    try {
      final url = HealingMatchConstants.THERAPIST_BOOKING_CONFIRMED +
          "?page=$pageNumber&size=$pageSize";
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": 18, //HealingMatchConstants.userId,
          }));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        therapistBookingHistoryResponseModel =
            TherapistBookingHistoryResponseModel.fromJson(data);
        return therapistBookingHistoryResponseModel;
      } else {
        return therapistBookingHistoryResponseModel;
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
      return therapistBookingHistoryResponseModel;
    }
  }

  static Future<TherapistBookingHistoryResponseModel> getCanceledBookingDetails(
      int pageNumber, int pageSize) async {
    TherapistBookingHistoryResponseModel therapistBookingHistoryResponseModel;
    try {
      final url = HealingMatchConstants.THERAPIST_CANCELLED_BOOKING +
          "?page=$pageNumber&size=$pageSize";
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": 18, //HealingMatchConstants.userId,
          }));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        therapistBookingHistoryResponseModel =
            TherapistBookingHistoryResponseModel.fromJson(data);
        return therapistBookingHistoryResponseModel;
      } else {
        return therapistBookingHistoryResponseModel;
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
      return therapistBookingHistoryResponseModel;
    }
  }

  static Future<bool> updateStatusUpdate(BookingDetailsList bookingDetail,
      bool isAddedPrice, bool isTimeChange, bool isCancel) async {
    try {
      final url = HealingMatchConstants.THERAPIST_BOOKING_STATUS_UPDATE;
      Map<String, dynamic> body;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      if (isCancel) {
        body = {
          "bookingId": bookingDetail.id.toString(),
          "cancellationReason": bookingDetail.cancellationReason,
          "bookingStatus": "4",
        };
      } else if (isAddedPrice && isTimeChange) {
        body = {
          "bookingId": bookingDetail.id.toString(),
          "bookingStatus": "2",
          "newStartTime": bookingDetail.newStartTime.toString(),
          "newEndTime": bookingDetail.newEndTime.toString(),
          "addedPrice": bookingDetail.addedPrice,
          "travelAmount": bookingDetail.travelAmount.toString(),
          "therapistComments": bookingDetail.therapistComments,
        };
      } else if (isAddedPrice) {
        body = {
          "bookingId": bookingDetail.id.toString(),
          "bookingStatus": "2",
          "addedPrice": bookingDetail.addedPrice,
          "travelAmount": bookingDetail.travelAmount.toString(),
          "therapistComments": bookingDetail.therapistComments,
        };
      } else if (isAddedPrice) {
        body = {
          "bookingId": bookingDetail.id.toString(),
          "bookingStatus": "2",
          "newStartTime": bookingDetail.newStartTime.toString(),
          "newEndTime": bookingDetail.newEndTime.toString(),
          "therapistComments": bookingDetail.therapistComments,
        };
      } else {
        body = {
          "bookingId": bookingDetail.id.toString(),
          "bookingStatus": "1",
          "therapistComments": bookingDetail.therapistComments != null
              ? bookingDetail.therapistComments
              : '',
        };
      }

      final response =
          await http.post(url, headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
      return true;
    }
  }
}
