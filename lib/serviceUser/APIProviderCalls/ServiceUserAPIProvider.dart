import 'dart:convert';
import 'dart:io';

import 'package:flutter/src/widgets/framework.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/providerEventCalendar/src/event.dart';
import 'package:gps_massageapp/models/customModels/calendarEventCreateReqModel.dart';
import 'package:gps_massageapp/models/responseModels/guestUserModel/GuestUserResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/paymentModels/CustomerCreation.dart';
import 'package:gps_massageapp/models/responseModels/paymentModels/PaymentCustomerCharge.dart';
import 'package:gps_massageapp/models/responseModels/paymentModels/PaymentSuccessModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/booking/createBooking.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/booking/BookingStatus.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/booking/BookingCompletedList.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/favouriteTherapist/FavouriteList.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/favouriteTherapist/FavouriteTherapistModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/favouriteTherapist/UnFavouriteTherapistModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/RecommendTherapistModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistListByTypeModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistUsersModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/UserBannerImagesModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/profile/DeleteSubAddressModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/profile/EditUserSubAddressModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/ratings/ratingList.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/searchModels/SearchTherapistByTypeModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/searchModels/SearchTherapistResultsModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/userDetails/GetTherapistDetails.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/userDetails/GetUserDetails.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:http/http.dart' as http;

class ServiceUserAPIProvider {
  static const _scopes = const [CalendarApi.calendarScope];

  static TherapistUsersModel listOfTherapistModel = new TherapistUsersModel();
  static UserBannerImagesModel _bannerModel = new UserBannerImagesModel();
  static TherapistsByTypeModel _therapistsByTypeModel =
      new TherapistsByTypeModel();

  static TherapistByIdModel _therapisyByIdModel = new TherapistByIdModel();
  static GetUserDetailsByIdModel _getUserDetailsByIdModel =
      new GetUserDetailsByIdModel();

  static SearchTherapistResultsModel _searchTherapistResultsModel =
      new SearchTherapistResultsModel();

  static SearchTherapistByTypeModel _searchTherapistByTypeModel =
      new SearchTherapistByTypeModel();

  // DeleteSubAddressModel
  static DeleteSubAddressModel _deleteSubAddressModel =
      new DeleteSubAddressModel();

  //Edit user sub address

  static EditUserSubAddressModel _editUserSubAddressModel =
      new EditUserSubAddressModel();

  static RecommendedTherapistModel _recommendedTherapistModel =
      new RecommendedTherapistModel();

  static UserReviewListById _userReviewListById = new UserReviewListById();

  static CreateBookingModel _bookingTherapistModel = new CreateBookingModel();

  static FavouriteTherapist _favouriteTherapist = new FavouriteTherapist();

  static UnFavouriteTherapist _unFavouriteTherapist =
      new UnFavouriteTherapist();

  static FavouriteListModel _favouriteListModel = new FavouriteListModel();

  static GuestUserModel _guestUserModel = new GuestUserModel();

  // payment models
  static PaymentCustomerCreation _customerCreation =
      new PaymentCustomerCreation();
  static PaymentCustomerCharge _paymentCustomerCharge =
      new PaymentCustomerCharge();
  static PaymentSuccessModel _paymentSuccessModel = new PaymentSuccessModel();
  static BookingStatusModel _bookingStatusModel = new BookingStatusModel();
  static BookingCompletedList _bookingCompletedList =
      new BookingCompletedList();

  // get all therapist users
  static Future<TherapistUsersModel> getAllTherapistUsers(
      BuildContext context) async {
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
      ProgressDialogBuilder.hideLoader(context);
    }

    return listOfTherapistModel;
  }

  // get limit of therapist users
  static Future<TherapistUsersModel> getAllTherapistsByLimit(
      BuildContext context, int pageNumber, int pageSize) async {
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
      ProgressDialogBuilder.hideLoader(context);
    }

    return listOfTherapistModel;
  }

  // get more of therapist users
  static Future<TherapistsByTypeModel> getTherapistsByTypeLimit(
      BuildContext context, int pageNumber, int pageSize) async {
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
      ProgressDialogBuilder.hideLoader(context);
    }
    return _therapistsByTypeModel;
  }

  //get Favourite List
  static Future<FavouriteListModel> getFavouriteList(
      int pageNumber, int pageSize) async {
    try {
      final url = HealingMatchConstants.ON_PREMISE_USER_BASE_URL +
          '/favourite/favouriteTherapistList?page=$pageNumber&size=$pageSize';
      // ?page=$pageNumber&size=$pageSize

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': HealingMatchConstants.accessToken
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('response : ${response.body}');
        var getFavouriteResponse = json.decode(response.body);
        _favouriteListModel = FavouriteListModel.fromJson(getFavouriteResponse);
        print(
            'getFavouriteResponse : ${_favouriteListModel.data.favouriteUserList.length}');
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print(e.toString());
      // ProgressDialogBuilder.hideLoader(context);
    }
    return _favouriteListModel;
  }

  //Booking Completed List
  static Future<BookingCompletedList> getBookingCompletedList(
      int pageNumber, int pageSize) async {
    try {
      final url = HealingMatchConstants.ON_PREMISE_USER_BASE_URL +
          '/booking/bookingCompleteStatusList?page=$pageNumber&size=$pageSize';
      // ?page=$pageNumber&size=$pageSize

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': HealingMatchConstants.accessToken
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('response : ${response.body}');
        var getBookingResponse = json.decode(response.body);
        _bookingCompletedList =
            BookingCompletedList.fromJson(getBookingResponse);
        print(
            'getFavouriteResponse : ${_bookingCompletedList.data.bookingDetailsList.length}');
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print(e.toString());
      // ProgressDialogBuilder.hideLoader(context);
    }
    return _bookingCompletedList;
  }

  //GET BOOKING STATUS API
  static Future<BookingStatusModel> getBookingStatus() async {
    try {
      final url = HealingMatchConstants.BOOKING_STATUS_LIST;

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': HealingMatchConstants.accessToken
      };
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        print('response : ${response.body}');
        var getBookingStatusResponse = json.decode(response.body);
        _bookingStatusModel =
            BookingStatusModel.fromJson(getBookingStatusResponse);
        print(
            'getBookingStatusResponse : ${_bookingStatusModel.data.bookingDetailsList.length}');
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print(e.toString());
      // ProgressDialogBuilder.hideLoader(context);
    }
    return _bookingStatusModel;
  }

  // get all therapist ratings
  static Future<UserReviewListById> getAllTherapistsRatings(
      BuildContext context) async {
    ProgressDialogBuilder.showOverlayLoader(context);
    try {
      final url = HealingMatchConstants.RATING_PROVIDER_LIST_URL;
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "therapistId": "${HealingMatchConstants.therapistRatingID}",
          }));
      print(response.body);
      if (response.statusCode == 200) {
        _userReviewListById =
            UserReviewListById.fromJson(json.decode(response.body));
      }
      ProgressDialogBuilder.hideLoader(context);
      print('Status code : ${response.statusCode}');
    } catch (e) {
      ProgressDialogBuilder.hideLoader(context);
      print('Ratings and review exception : ${e.toString()}');
    }

    return _userReviewListById;
  }

  // get limit of therapist ratings
  static Future<UserReviewListById> getAllTherapistsRatingsByLimit(
      BuildContext context, int pageNumber, int pageSize) async {
    try {
      final url =
          '${HealingMatchConstants.ON_PREMISE_USER_BASE_URL}/mobileReview/therapistReviewListById?page=$pageNumber&size=$pageSize';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "therapistId": "${HealingMatchConstants.therapistRatingID}",
          }));
      print(response.body);
      if (response.statusCode == 200) {
        _userReviewListById =
            UserReviewListById.fromJson(json.decode(response.body));
      }

      print('Status code : ${response.statusCode}');
    } catch (e) {
      print('Ratings and review exception : ${e.toString()}');
    }

    return _userReviewListById;
  }

  // get home screen user banner images
  static Future<UserBannerImagesModel> getAllBannerImages(
      BuildContext context) async {
    try {
      final url = HealingMatchConstants.BANNER_IMAGES_URL;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': HealingMatchConstants.accessToken
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
      ProgressDialogBuilder.hideLoader(context);
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
      ProgressDialogBuilder.hideLoader(context);
    } catch (e) {
      print('User Details Exception caught : ${e.toString()}');
      ProgressDialogBuilder.hideLoader(context);
    }
    return _getUserDetailsByIdModel;
  }

  // get therapist details by ID
  static Future<TherapistByIdModel> getTherapistDetails(
      BuildContext context, var userID) async {
    try {
      final url = HealingMatchConstants.GET_THERAPIST_DETAILS;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": userID,
            "userId": 233,
          }));
      final getTherapistDetails = json.decode(response.body);
      print('Therapist Details Response : ${response.body}');
      TherapistByIdModel _therapisyByIdModel =
          TherapistByIdModel.fromJson(getTherapistDetails);
      ProgressDialogBuilder.hideLoader(context);
      return _therapisyByIdModel;
    } on SocketException catch (_) {
      //handle socket Exception
      print('Socket Exception...Occurred');
      ProgressDialogBuilder.hideLoader(context);
    } catch (e) {
      print('Therapist Details Exception caught : ${e.toString()}');
      ProgressDialogBuilder.hideLoader(context);
    }
  }

  // get home screen user banner images
  static Future<DeleteSubAddressModel> deleteUserSubAddress(
      BuildContext context, var addressID) async {
    try {
      final url = HealingMatchConstants.DELETE_SUB_ADDRESS_URL;
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "id": addressID,
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
      ProgressDialogBuilder.hideLoader(context);
      print('Exception in delete !!');
    }
    return _deleteSubAddressModel;
  }

  // get home screen user banner images
  static Future<EditUserSubAddressModel> editUserSubAddress(
      BuildContext context,
      var addressID,
      String subAddress,
      var latitude,
      var longitude) async {
    try {
      final url = HealingMatchConstants.EDIT_SUB_ADDRESS_URL;
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "id": addressID,
            "address": subAddress,
            "lat": latitude,
            "lon": longitude
          }));
      print('Edit Sub Address Body : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getEditedAddressResponse = json.decode(response.body);
        _editUserSubAddressModel =
            EditUserSubAddressModel.fromJson(getEditedAddressResponse);
      }

      print('Status code : ${response.statusCode}');
    } catch (e) {
      ProgressDialogBuilder.hideLoader(context);
      print('Exception in delete !!');
    }
    return _editUserSubAddressModel;
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
            "keyword": HealingMatchConstants.searchKeyWordValue,
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

  // get search screen user therapist results
  static Future<SearchTherapistByTypeModel> getTherapistSearchResultsByType(
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
            "type": HealingMatchConstants.searchServiceType,
          }));
      print('Search results Body : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getDeletedResponse = json.decode(response.body);
        _searchTherapistByTypeModel =
            SearchTherapistByTypeModel.fromJson(getDeletedResponse);
      }
    } catch (e) {
      print('Exception Search API : ${e.toString()}');
    }
    return _searchTherapistByTypeModel;
  }

  // get recommended therapist results
  static Future<RecommendedTherapistModel> getRecommendedTherapists(
      BuildContext context, int pageNumber, int pageSize) async {
    try {
      final url =
          '${HealingMatchConstants.RECOMMENDED_THERAPISTS_LIST}?page=$pageNumber&size=$pageSize';
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "x-access-token": HealingMatchConstants.accessToken
      });
      print('Search results Body : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getRecommendedTherapistResponse = json.decode(response.body);
        _recommendedTherapistModel =
            RecommendedTherapistModel.fromJson(getRecommendedTherapistResponse);
      }
    } catch (e) {
      print('Exception Search API : ${e.toString()}');
    }
    return _recommendedTherapistModel;
  }

  //Create Booking
  static Future<CreateBookingModel> createBooking(
      BuildContext context,
      int therapistId,
      String startTime,
      String endTime,
      int paymentStatus,
      int subCategoryId,
      int categoryId,
      String nameOfService,
      int totalMinOfService,
      var priceOfService,
      int bookingStatus,
      String locationType,
      String location,
      var totalCost,
      int userReviewStatus,
      int therapistReviewStatus,
      String userCommands,
      String eventId) async {
    try {
      final url = '${HealingMatchConstants.BOOKING_THERAPIST}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "therapistId": therapistId,
            "startTime": startTime,
            "endTime": endTime,
            "paymentStatus": paymentStatus,
            "subCategoryId": subCategoryId,
            "categoryId": categoryId,
            "nameOfService": nameOfService,
            "totalMinOfService": totalMinOfService,
            "priceOfService": priceOfService,
            "bookingStatus": bookingStatus,
            "locationType": locationType,
            "location": location,
            "totalCost": totalCost,
            "userReviewStatus": userReviewStatus,
            "userCommands": userCommands,
            "travelAmount": 0,
            "eventId": eventId,
          }));

      print('booking results Body : ${response.body}');
      if (response.statusCode == 200) {
        final bookingResponse = json.decode(response.body);
        _bookingTherapistModel = CreateBookingModel.fromJson(bookingResponse);
      }
    } catch (e) {
      print('Exception Search API : ${e.toString()}');
    }
    return _bookingTherapistModel;
  }

  // favourite therapist
  static Future<FavouriteTherapist> favouriteTherapist(var therapistID) async {
    try {
      final url = '${HealingMatchConstants.DO_FAVOURITE_THERAPIST}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "therapistId": therapistID,
          }));
      print('FavouriteTherapist Body : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getResponse = json.decode(response.body);
        _favouriteTherapist = FavouriteTherapist.fromJson(getResponse);
      } else {
        print('Favourite API Request failed !!');
      }
    } catch (e) {
      print('Exception FavouriteTherapist API : ${e.toString()}');
    }
    return _favouriteTherapist;
  }

  // un-favourite therapist
  static Future<bool> unFavouriteTherapist(var therapistID) async {
    try {
      final url = '${HealingMatchConstants.UNDO_FAVOURITE_THERAPIST}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "therapistId": therapistID,
          }));
      print('UnFavourite therapist response : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getResponse = json.decode(response.body);
        // _unFavouriteTherapist = UnFavouriteTherapist.fromJson(getResponse);
        return true;
      } else {
        print('Un Favourite API Request failed !!');
      }
    } catch (e) {
      print('Exception UnFavouriteTherapist API : ${e.toString()}');
    }
    return false;
  }

  // guest user api call
  static Future<GuestUserModel> handleGuestUser(var isTherapistValue) async {
    try {
      final url = '${HealingMatchConstants.HANDLE_GUEST_USER}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": HealingMatchConstants.accessToken
          },
          body: json.encode({
            "fcmToken": HealingMatchConstants.userDeviceToken,
            "isTherapist": isTherapistValue,
            "lat": HealingMatchConstants.currentLatitude,
            "lon": HealingMatchConstants.currentLongitude,
          }));
      print('GuestUser response : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getResponse = json.decode(response.body);
        _guestUserModel = GuestUserModel.fromJson(getResponse);
      } else {
        print('GuestUser API Request failed !!');
      }
    } catch (e) {
      print('Exception GuestUser API : ${e.toString()}');
    }
    return _guestUserModel;
  }

  // createCustomerForPayment
  static Future<PaymentCustomerCreation> createCustomerForPayment(
      BuildContext context, var userID) async {
    try {
      final url = '${HealingMatchConstants.CREATE_CUSTOMER_FOR_PAYMENT_URL}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": '${HealingMatchConstants.accessToken}'
          },
          body: json.encode({
            "userId": userID,
          }));
      print('createCustomerForPayment response : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getResponse = json.decode(response.body);
        _customerCreation = PaymentCustomerCreation.fromJson(getResponse);
      } else {
        NavigationRouter.switchToPaymentFailedScreen(context);
        print('createCustomerForPayment API Request failed !!');
      }
    } catch (e) {
      NavigationRouter.switchToPaymentFailedScreen(context);
      print('createCustomerForPayment GuestUser API : ${e.toString()}');
    }
    return _customerCreation;
  }

  // chargePaymentForCustomer
  static Future<PaymentCustomerCharge> chargePaymentForCustomer(
      BuildContext context, var userID, var cardID, var amount) async {
    try {
      final url = '${HealingMatchConstants.CHARGE_CUSTOMER_URL}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": '${HealingMatchConstants.accessToken}'
          },
          body: json.encode({
            "userId": userID,
            "amount": amount,
            "cardId": cardID,
            "bookingId": HealingMatchConstants.bookingId,
          }));
      print('chargePaymentForCustomer response : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getResponse = json.decode(response.body);
        _paymentCustomerCharge = PaymentCustomerCharge.fromJson(getResponse);
      } else {
        NavigationRouter.switchToPaymentFailedScreen(context);
        print('chargePaymentForCustomer API Request failed !!');
      }
    } catch (e) {
      NavigationRouter.switchToPaymentFailedScreen(context);
      print('Exception chargePaymentForCustomer API : ${e.toString()}');
    }
    return _paymentCustomerCharge;
  }

  // paymentSuccess
  static Future<PaymentSuccessModel> paymentSuccess(
      BuildContext context, var paymentID, var cardID) async {
    try {
      final url = '${HealingMatchConstants.PAYMENT_SUCCESS_CALL_URL}';
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "x-access-token": '${HealingMatchConstants.accessToken}'
          },
          body: json.encode({
            "paymentId": paymentID,
            "cardId": cardID,
          }));
      print('paymentSuccess response : ${response.body}');
      print('statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        final getResponse = json.decode(response.body);
        _paymentSuccessModel = PaymentSuccessModel.fromJson(getResponse);
      } else {
        print('paymentSuccess API Request failed !!');
        NavigationRouter.switchToPaymentFailedScreen(context);
      }
    } catch (e) {
      NavigationRouter.switchToPaymentFailedScreen(context);
      print('Exception paymentSuccess API : ${e.toString()}');
    }
    return _paymentSuccessModel;
  }

  // Get calendar events

  static Future<List<FlutterWeekViewEvent>> getCalEvents() async {
    List<FlutterWeekViewEvent> flutterEvents = List<FlutterWeekViewEvent>();
    var accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "ea91c6540fdc102720f699c56f692d25d4aefeec",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC916/Vmhw+wpgw\nYjtvKWWnoVFJqz4sXXu5DRWaB9dSxWhIebQv0n+UdTRz8MT3ipOMz8Z4u9ziw2/J\n6tLJTU82iCk7afMEjSGypAK7osXZW5JvLkAohtamTPYSSKc7oeRfNLLCBZFHoVqQ\nvoQLnBTZbk8HSAwUBu4LFTGdSj226R7VoPeFFcdybA7tKNdM4nk/GTdnJUabTWXQ\nISRgD4ZK2SxJDlWqCkyZ1+6x/d6DEYvZX9QgGczMu8rkReNBpN+AOwZjUQ1sByhA\nhzlQXS+UX7KvJW4kfUCTvRDOr952M5J4aAvGpQzy9B3Hhm91fMsPSrdPtklDceJj\n62JfhVztAgMBAAECggEAGPleXtXCwHjeB4NsuS9zeY1twai+6Zw0sf/oJxa/+1oP\n4XTtQNtKwE944oW6i6wVxBDzVZ+1K7m1I5V6PFQoxw47il7iQueEFtmfqGp95521\n0l19wDcY1tDKEFaxdVVTUzj+CSstVQSDgwYlHdffIEl0KQuP1zSgLSIRIFWLb9vZ\ntpKl0VFrbB6W9NRIzcupHIFdhzvTbZPv/Kd0fHh49zL6oAxfFq8kzRci/jhld/Wz\n1oWlvOne1NSMiZWbltr/iI+YsNMcQdEudWPsw1Wvbnj8YEn9bdFUVb5IS0bc7XP9\n3G6TwHpJMZutSvtlqSIJF7PfvwZJQXeTr+G3EMcGywKBgQD3rUBd9o2ad7W8aKZv\nvErKr1TX9C1rZpadnabGPo5CGSx/tUzwUTpf6FxtTqgvjMhUw8HWGM0iJpf2B7Gc\nef+1w5mMaPz9WV9XeC2//0S9f0QGkPiXDEC9raud6uJQ41hYW6yJp7nrahZ9dFog\nnL0w5HEJ/eSWYwlijtOi+AUZiwKBgQDEOOQR3Bz9rUlrlMJf5s7LlO80TUq12s6U\nRqBmiUiwGBSioQ7gUdedlWjL1Ukh6KMLCvFgwbIEYDsZnL/Uzbb/Qkp3yGuEmyRm\na15iMWJ6TYNGxEw7+6nw7LsVwV528/DRyZQVyJHLPAYG3Zytfi2nRRXSeAS7qIQF\nNyweaG8CZwKBgHAdCr/99Udw3OE2dfCqSSjKiRtgOpcdTxx12qJuerLM9mmwxe0a\nt9PmOMB6FIPBtIU6P6oMe/7zfWIvRWTRjMDYk88NT0fXhuLvUbZRdOpai451XTHy\np/O0g7TuOBfpcXo9tTJyrCQ2V4veeVW93Z4eKlUdirXQitUEViS1JInVAoGAXkb3\nTZ10UG3x2L6gpXM/6JCmXXrFapq2podIiftr8S+guoKnox+veQdQUp8nhCNCMwwO\n7W4jGfcibivh/1zXj81J+kNRZWUlGBB+SK9xoVGcwWOPPUKtZBRZzxoZSQ3rpuAz\nRkQXyI4OVz4jCTiWtsd6tKT1oTRWOitIB1QmAgECgYEAw8Q6oLV4Iq4oKTYJpmha\nvPb4BH+df8lvv9hCGviFBk48ZsY4ImRDb//KlknDmiTgGlW+kLWOFY8+a8NhAMB+\nb/AdpUK2tuYg09RM66bneCBU6wCaSBvUMxZHt469tWboam1i74BCQpDdIDd0A1uL\nb7GwDGIB8mLkOwQXOvKRqBY=\n-----END PRIVATE KEY-----\n",
      "client_email": "healing-match@appspot.gserviceaccount.com",
      "client_id": "109325874687014297008",
      "type": "service_account"
    });
    final httpClient =
        await clientViaServiceAccount(accountCredentials, _scopes);
    var calendar = CalendarApi(httpClient);
    DateTime lastMonth = DateTime(2020, 09, 1);
    DateTime firstMonth = DateTime(2020, 09, 30);
    var calEvents = calendar.events.list(
      "sugyo.sumihiko@gmail.com",
      q: "SU${HealingMatchConstants.serviceUserID}",
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
    HealingMatchConstants.userEvents.clear();
    HealingMatchConstants.userEvents.addAll(flutterEvents);
    httpClient.close();
    return HealingMatchConstants.userEvents;
  }

  static Future<bool> saveFirebaseUserID(
      String firebaseID, BuildContext context, int id) async {
    try {
      final url = HealingMatchConstants.FIREBASE_UPDATE_USERID;
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '${HealingMatchConstants.accessToken}'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode(
              {"id": id, "isTherapist": 0, "firebaseUDID": firebaseID}));
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

  //create calendar event for booking
  static Future<Event> createCalendarEvent(
      CalendarEventCreateReqModel calendarModel) async {
    var accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": "ea91c6540fdc102720f699c56f692d25d4aefeec",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC916/Vmhw+wpgw\nYjtvKWWnoVFJqz4sXXu5DRWaB9dSxWhIebQv0n+UdTRz8MT3ipOMz8Z4u9ziw2/J\n6tLJTU82iCk7afMEjSGypAK7osXZW5JvLkAohtamTPYSSKc7oeRfNLLCBZFHoVqQ\nvoQLnBTZbk8HSAwUBu4LFTGdSj226R7VoPeFFcdybA7tKNdM4nk/GTdnJUabTWXQ\nISRgD4ZK2SxJDlWqCkyZ1+6x/d6DEYvZX9QgGczMu8rkReNBpN+AOwZjUQ1sByhA\nhzlQXS+UX7KvJW4kfUCTvRDOr952M5J4aAvGpQzy9B3Hhm91fMsPSrdPtklDceJj\n62JfhVztAgMBAAECggEAGPleXtXCwHjeB4NsuS9zeY1twai+6Zw0sf/oJxa/+1oP\n4XTtQNtKwE944oW6i6wVxBDzVZ+1K7m1I5V6PFQoxw47il7iQueEFtmfqGp95521\n0l19wDcY1tDKEFaxdVVTUzj+CSstVQSDgwYlHdffIEl0KQuP1zSgLSIRIFWLb9vZ\ntpKl0VFrbB6W9NRIzcupHIFdhzvTbZPv/Kd0fHh49zL6oAxfFq8kzRci/jhld/Wz\n1oWlvOne1NSMiZWbltr/iI+YsNMcQdEudWPsw1Wvbnj8YEn9bdFUVb5IS0bc7XP9\n3G6TwHpJMZutSvtlqSIJF7PfvwZJQXeTr+G3EMcGywKBgQD3rUBd9o2ad7W8aKZv\nvErKr1TX9C1rZpadnabGPo5CGSx/tUzwUTpf6FxtTqgvjMhUw8HWGM0iJpf2B7Gc\nef+1w5mMaPz9WV9XeC2//0S9f0QGkPiXDEC9raud6uJQ41hYW6yJp7nrahZ9dFog\nnL0w5HEJ/eSWYwlijtOi+AUZiwKBgQDEOOQR3Bz9rUlrlMJf5s7LlO80TUq12s6U\nRqBmiUiwGBSioQ7gUdedlWjL1Ukh6KMLCvFgwbIEYDsZnL/Uzbb/Qkp3yGuEmyRm\na15iMWJ6TYNGxEw7+6nw7LsVwV528/DRyZQVyJHLPAYG3Zytfi2nRRXSeAS7qIQF\nNyweaG8CZwKBgHAdCr/99Udw3OE2dfCqSSjKiRtgOpcdTxx12qJuerLM9mmwxe0a\nt9PmOMB6FIPBtIU6P6oMe/7zfWIvRWTRjMDYk88NT0fXhuLvUbZRdOpai451XTHy\np/O0g7TuOBfpcXo9tTJyrCQ2V4veeVW93Z4eKlUdirXQitUEViS1JInVAoGAXkb3\nTZ10UG3x2L6gpXM/6JCmXXrFapq2podIiftr8S+guoKnox+veQdQUp8nhCNCMwwO\n7W4jGfcibivh/1zXj81J+kNRZWUlGBB+SK9xoVGcwWOPPUKtZBRZzxoZSQ3rpuAz\nRkQXyI4OVz4jCTiWtsd6tKT1oTRWOitIB1QmAgECgYEAw8Q6oLV4Iq4oKTYJpmha\nvPb4BH+df8lvv9hCGviFBk48ZsY4ImRDb//KlknDmiTgGlW+kLWOFY8+a8NhAMB+\nb/AdpUK2tuYg09RM66bneCBU6wCaSBvUMxZHt469tWboam1i74BCQpDdIDd0A1uL\nb7GwDGIB8mLkOwQXOvKRqBY=\n-----END PRIVATE KEY-----\n",
      "client_email": "healing-match@appspot.gserviceaccount.com",
      "client_id": "109325874687014297008",
      "type": "service_account"
    });
    final httpClient =
        await clientViaServiceAccount(accountCredentials, _scopes);

    var calendar = CalendarApi(httpClient);
    String calendarId = "sugyo.sumihiko@gmail.com";
    Event event = Event(); // Create object of event

    event.summary =
        "SP${calendarModel.therapistId},${calendarModel.therapistName},SU${calendarModel.userId},${calendarModel.userName}";
    event.description =
        "${calendarModel.nameOfService},¥${calendarModel.priceOfService}";
    event.location =
        "${calendarModel.eventLocationType},${calendarModel.eventLocation}";
    event.status = "tentative";

    EventDateTime start = new EventDateTime();
    start.dateTime = calendarModel.startTime;
    start.timeZone = "GMT+05:30";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT+05:30";
    end.dateTime = calendarModel.endTime;
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
      print('Error creating event $e');
    }
  }
}
