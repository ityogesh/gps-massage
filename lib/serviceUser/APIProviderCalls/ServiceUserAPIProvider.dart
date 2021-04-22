import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistListByTypeModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistUsersModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/UserBannerImagesModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/profile/DeleteSubAddressModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/searchModels/SearchTherapistResultsModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/userDetails/GetUserDetails.dart';
import 'package:gps_massageapp/serviceUser/BlocCalls/HomeScreenBlocCalls/therapist_type_bloc.dart';
import 'package:gps_massageapp/serviceUser/BlocCalls/HomeScreenBlocCalls/therapist_type_event.dart';
import 'package:http/http.dart' as http;

class ServiceUserAPIProvider {
  static Response response;
  static TherapistUsersModel listOfTherapistModel = new TherapistUsersModel();
  static UserBannerImagesModel _bannerModel = new UserBannerImagesModel();
  static TherapistsByTypeModel _therapistsByTypeModel =
      new TherapistsByTypeModel();
  static GetUserDetailsByIdModel userDetails = new GetUserDetailsByIdModel();
  static GetUserDetailsByIdModel _getUserDetailsByIdModel =
      new GetUserDetailsByIdModel();

  // DeleteSubAddressModel
  static DeleteSubAddressModel _deleteSubAddressModel =
      new DeleteSubAddressModel();

  static SearchTherapistResultsModel _searchTherapistResultsModel =
      new SearchTherapistResultsModel();

  // get all therapist users
  static Future<TherapistUsersModel> getAllTherapistUsers() async {
    try {
      final url = HealingMatchConstants.THERAPIST_LIST_URL;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url, headers: headers);
      final getTherapists = json.decode(response.body);
      listOfTherapistModel = TherapistUsersModel.fromJson(getTherapists);
      print('Response body : ${response.body}');
    } catch (e) {
      print(e.toString());
    }
    /*return (response.data).map((therapistUsers) {
      print('Inserting >>> $therapistUsers');
      //DBProvider.db.createTherapistUsers(therapistUsers);
    }).toList();*/
    return listOfTherapistModel;
  }

  // get limit of therapist users
  static Future<TherapistUsersModel> getAllTherapistsByLimit(
      int pageNumber, int pageSize) async {
    try {
      final url =
          '${HealingMatchConstants.ON_PREMISE_USER_BASE_URL}/user/homeTherapistList?page=$pageNumber&size=$pageSize';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.get(url, headers: headers);
      final getTherapists = json.decode(response.body);
      listOfTherapistModel = TherapistUsersModel.fromJson(getTherapists);
      print('More Response body : ${response.body}');
    } catch (e) {
      print(e.toString());
    }
    /*return (response.data).map((therapistUsers) {
      print('Inserting >>> $therapistUsers');
      //DBProvider.db.createTherapistUsers(therapistUsers);
    }).toList();*/
    return listOfTherapistModel;
  }

  // get more of therapist users
  static Future<TherapistsByTypeModel> getTherapistsByTypeLimit(
      int pageNumber, int pageSize) async {
    try {
      final url =
          '${HealingMatchConstants.ON_PREMISE_USER_BASE_URL}/user/homeTherapistListByType?page=$pageNumber&size=$pageSize';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "type": HealingMatchConstants.serviceTypeValue,
          }));
      final getTherapistByType = json.decode(response.body);
      _therapistsByTypeModel =
          TherapistsByTypeModel.fromJson(getTherapistByType);
      print('Therapist Type Response body : ${response.body}');
    } catch (e) {
      print(e.toString());
    }
    return _therapistsByTypeModel;
  }

  // get home screen user banner images
  static Future<UserBannerImagesModel> getAllBannerImages(
      BuildContext context) async {
    try {
      final url = HealingMatchConstants.BANNER_IMAGES_URL;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.get(url, headers: headers);
      final getBannerImages = json.decode(response.body);
      print('Banner Response body : ${response.body}');
      _bannerModel = UserBannerImagesModel.fromJson(getBannerImages);
    } on SocketException catch (_) {
      //handle socket Exception
      print('Socket Exception...Occurred');
    } catch (e) {
      print('Banner Exception caught : ${e.toString()}');
      BlocProvider.of<TherapistTypeBloc>(context)
          .add(RefreshEvent(HealingMatchConstants.accessToken));
      throw Exception(e);
    }
    return _bannerModel;
  }

  // get home screen user banner images
  static Future<GetUserDetailsByIdModel> getUserDetails(
      BuildContext context, String userID) async {
    try {
      final url = HealingMatchConstants.GET_USER_DETAILS;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "user_id": userID,
          }));
      final getUserDetails = json.decode(response.body);
      print('User Details Response : ${response.body}');
      _getUserDetailsByIdModel =
          GetUserDetailsByIdModel.fromJson(getUserDetails);
    } on SocketException catch (_) {
      //handle socket Exception
      print('Socket Exception...Occurred');
    } catch (e) {
      print('User Details Exception caught : ${e.toString()}');
      throw Exception(e);
    }
    return _getUserDetailsByIdModel;
  }

  // get home screen user banner images
  static Future<DeleteSubAddressModel> deleteUserSubAddress(
      BuildContext context, var addressType) async {
    try {
      final url = HealingMatchConstants.DELETE_SUB_ADDRESS_URL;
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "AddressType": addressType,
          }));
      print('Delete Sub Address Body : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getDeletedResponse = json.decode(response.body);
        _deleteSubAddressModel =
            DeleteSubAddressModel.fromJson(getDeletedResponse);
      }

      print('Status code : ${response.statusCode}');
    } catch (e) {
      print('Exception in delete !!');
    }
    return _deleteSubAddressModel;
  }

  // get search screen user therapist results
  static Future<SearchTherapistResultsModel> getTherapistSearchResults(
      BuildContext context, int pageNumber, int pageSize) async {
    try {
      final url =
          '${HealingMatchConstants.FETCH_THERAPIST_SEARCH_RESULTS}?page=$pageNumber&size=$pageSize';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "searchKeyword": HealingMatchConstants.searchKeyWordValue,
            "userAddress": HealingMatchConstants.searchUserAddress,
            "serviceType": HealingMatchConstants.serviceType,
            "serviceLocationCriteria": HealingMatchConstants.isLocationCriteria,
            "serviceTimeCriteria": HealingMatchConstants.isTimeCriteria,
            "selectedTime": HealingMatchConstants.dateTime.toIso8601String(),
            "searchDistanceRadius": HealingMatchConstants.searchDistanceRadius,
            "latitude": HealingMatchConstants.searchAddressLatitude,
            "longitude": HealingMatchConstants.searchAddressLongitude,
          }));
      print('Search results Body : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getDeletedResponse = json.decode(response.body);
        _searchTherapistResultsModel =
            SearchTherapistResultsModel.fromJson(getDeletedResponse);
      }
    } catch (e) {
      print('Exception Search API : ${e.toString()}');
    }
    return _searchTherapistResultsModel;
  }
}
