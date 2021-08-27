import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/progressDialogsHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/providerEventCalendar/src/event.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/ProviderDetailsResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/loginResponseModel.dart'
    as providerLogin;
import 'package:gps_massageapp/models/responseModels/serviceProvider/messageServicePriceModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistUsersModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/profile/profileUpdateResponseModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/searchModels/SearchTherapistResultsModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/userDetails/GetTherapistDetails.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/userDetails/GetUserDetails.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

enum MessageType {
  Text,
  Media,
}

enum MediaType {
  Photo,
  Video,
}

/* enum BookingStatus  {
    user_order_placed: 0,
    provider_accepted_without_changes: 1,
    provider_accepted_with_changes: 2,
    user_accepted: 3,
    provider_cancel: 4,
    user_cancel: 5,
    order_confirm__with_payment: 6,
    autoCancel_by_provider: 7,
    autoCancel_by_user: 8,
    order_Completed: 9,
    admin_cancel: 10,
} */

final String ALL_MESSAGES_COLLECTION = 'MESSAGES';
final String USERS_COLLECTION = 'USERS';
final String CHATS_COLLECTION = 'CHATS';
final String MEDIA_COLLECTION = 'MEDIA';

final String CHATS_MEDIA_STORAGE_REF = 'ChatsMedia';

class HealingMatchConstants {
  static const String ON_PREMISE_USER_BASE_URL =
      // "http://103.92.19.158:9087/api"; //secondary backup IP

      "http://106.51.49.160:9087/api"; // Development data URL

  // "http://106.51.49.160:9094/api"; // Testing data URL

  // "http://103.92.19.158:9094/api"; //Temp URL

// get therapist list By ID
  static const String THERAPIST_USER_BY_ID_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/therapistUserbyId';
  static const String GET_RECOMMENDED_THERAPIST_LIST_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/homeTherapistSuggestionList';
  static const String REGISTER_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/user/registerProvider';
  static const String STATE_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/prefecture' + '/getAllPrefecture';
  static const String CITY_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/cities' + '/getCitieByPrefectureId';
  static const String ESTHETIC_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/mstMassageSubCategory/getAllMstEsthetic';
  static const String RELAXATION_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/mstMassageSubCategory/getAllMstRelaxation';
  static const String TREATMENT_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/mstMassageSubCategory/getAllMstOrteopathic';
  static const String FITNESS_PROVIDER_URL =
      ON_PREMISE_USER_BASE_URL + '/mstMassageSubCategory/getAllMstFitness';
  static const String REGISTER_PROVIDER_BANNER_UPLOAD_URL =
      ON_PREMISE_USER_BASE_URL + '/user/bannerUpload';
  static const String REGISTER_PROVIDER_GET_BANK_LIST_URL =
      ON_PREMISE_USER_BASE_URL + '/bankList/getAllBankList';
  static const String SEND_VERIFY_USER_URL =
      ON_PREMISE_USER_BASE_URL + '/user/sendVerify';
  static const String CHANGE_PASSWORD_VERIFY_USER_URL =
      ON_PREMISE_USER_BASE_URL + '/user/resetPassword';
  static const String CHANGE_PASSWORD_VERIFY_OTP_URL =
      ON_PREMISE_USER_BASE_URL + '/user/verifyOtp';
  static const String UPDATE_USER_DETAILS_URL =
      ON_PREMISE_USER_BASE_URL + '/user/userupdatebyId';
  static const String UPDATE_PROVIDER_DETAILS_URL =
      ON_PREMISE_USER_BASE_URL + '/user/therapistUpdatebyId';
  static const String UPDATE_BANNER_IMAGE_URL =
      ON_PREMISE_USER_BASE_URL + '/banner/bannerImgUpdate';
  static const String DELETE_BANNER_IMAGE_URL =
      ON_PREMISE_USER_BASE_URL + '/banner/bannerImgDelete';
  static const String STORE_DESCRIPTION_UPDATE =
      ON_PREMISE_USER_BASE_URL + '/user/therapistStoreDescUpdatebyId';

  // register service user
  static const String REGISTER_USER_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/registerUser';

  // login service user
  static const String LOGIN_USER_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/signin';

  //SNS AND APPLE LOGIN
  static const String SNS_APPLE_USER_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/signinSSO';

  //Ratings and Review
  static const String RATING_USER_URL =
      ON_PREMISE_USER_BASE_URL + '/mobileReview/createTherapistReview';

  // Provider rating List
  static const String RATING_PROVIDER_LIST_URL =
      ON_PREMISE_USER_BASE_URL + '/mobileReview/therapistReviewListById';

  // get Therapists list
  static const String THERAPIST_LIST_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/homeTherapistList';

  // get user
  // get Therapists list by type of massage service
  static const String THERAPIST_LIST_BY_TYPE =
      ON_PREMISE_USER_BASE_URL + '/user' + '/homeTherapistListByType';

  // get recommend therapists
  static const String RECOMMENDED_THERAPISTS_LIST =
      ON_PREMISE_USER_BASE_URL + '/user' + '/homeTherapistSuggestionList';

  // get Users list
  static const String USER_LIST_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/userList';

  // get Users list By ID
  static const String USER_LIST_ID_URL =
      ON_PREMISE_USER_BASE_URL + '/user' + '/userbyId';

  //get Therapist Details by ID
  static const String THERAPIST_DETAILS_BY_ID =
      ON_PREMISE_USER_BASE_URL + "/user" + "/therapistByIdProfit";

  //save Provider Shift Timing
  static const String THERAPIST_SHIFT_TIME_SAVE =
      ON_PREMISE_USER_BASE_URL + "/storeServicetime" + "/storeServicetimeMange";

  static const String FIREBASE_UPDATE_USERID =
      ON_PREMISE_USER_BASE_URL + "/firebase/firebaseUserIdUpdate";

  // // get Users list By ID
  // static const String THERAPIST_USER_BY_ID_URL =
  //     ON_PREMISE_USER_BASE_URL + '/user' + '/therapistUserbyId';

  //update Therapist Service Type
  static const String THERAPIST_UPDATE_SERVICE_TYPE = ON_PREMISE_USER_BASE_URL +
      '/user' +
      '/therpistUpdateAndDeleteServiceTypebyId';

  //delet Therapist Service Type
  static const String THERAPIST_DELETE_SERVICE_TYPE = ON_PREMISE_USER_BASE_URL +
      '/user' +
      '/therpistUpdateServiceTypeDeletebyId';

  static const String FAVORITE_API =
      ON_PREMISE_USER_BASE_URL + '/favourite/favouriteTherapistCreate';

  // get Users banner images from Admin
  static const String BANNER_IMAGES_URL = ON_PREMISE_USER_BASE_URL +
      '/adminBanner' +
      '/getAllAdminBannerListMobile';

  // get Users details
  static const String GET_USER_DETAILS =
      ON_PREMISE_USER_BASE_URL + '/user' + '/userbyId';

  // get therapist details
  static const String GET_THERAPIST_DETAILS =
      ON_PREMISE_USER_BASE_URL + '/user' + '/therapistUserbyId';

  // delete user sub address
  static const String DELETE_SUB_ADDRESS_URL =
      ON_PREMISE_USER_BASE_URL + '/user/deleteUserSubAddress';

  // delete user sub address
  static const String EDIT_SUB_ADDRESS_URL =
      ON_PREMISE_USER_BASE_URL + '/user/userSubAddressUpdate';

  // fetch therapist results
  static const String FETCH_THERAPIST_SEARCH_RESULTS =
      ON_PREMISE_USER_BASE_URL + '/search/searchServiceUser';

  // fetch therapist results
  static const String FETCH_SORTED_THERAPIST_SEARCH_RESULTS =
      ON_PREMISE_USER_BASE_URL + '/search/searchServiceUserByOrder';

  static const String BOOKING_THERAPIST =
      ON_PREMISE_USER_BASE_URL + '/booking/createBooking';

  // Favorite Therapist
  static const String DO_FAVOURITE_THERAPIST =
      ON_PREMISE_USER_BASE_URL + '/favourite/favouriteTherapistCreate';

  // Un Favorite Therapist
  static const String UNDO_FAVOURITE_THERAPIST =
      ON_PREMISE_USER_BASE_URL + '/favourite/unFavouriteTherapist';

  // therapist booking request
  static const String THERAPIST_BOOKING_REQUEST =
      ON_PREMISE_USER_BASE_URL + '/bookingDetails/bookingRequestStatusList';

  // therapist approved booking request
  static const String THERAPIST_BOOKING_APPROVED =
      ON_PREMISE_USER_BASE_URL + '/bookingDetails/bookingApprovalStatusList';

  // therapist confirmed booking request
  static const String THERAPIST_BOOKING_CONFIRMED = ON_PREMISE_USER_BASE_URL +
      '/bookingDetails/bookingConfirmReservationStatusList';

  // therapist cancel booking list
  static const String THERAPIST_CANCELLED_BOOKING =
      ON_PREMISE_USER_BASE_URL + '/bookingDetails/bookingCancelStatusList';

  // therapist booking status change
  static const String THERAPIST_BOOKING_STATUS_UPDATE =
      ON_PREMISE_USER_BASE_URL + '/booking/bookingRequestStatusUpdateById';

  // therapist weekly booking detail request
  static const String THERAPIST_WEEKLY_BOOKING =
      ON_PREMISE_USER_BASE_URL + '/bookingDetails/weeklyBookingStatusList';

  // handle guest user
  static const String HANDLE_GUEST_USER =
      ON_PREMISE_USER_BASE_URL + '/user/guestUser';

  // customer create
  static const String CREATE_CUSTOMER_FOR_PAYMENT_URL =
      ON_PREMISE_USER_BASE_URL + '/user/customerCreation';

  // handle paymentCharge
  static const String CHARGE_CUSTOMER_URL =
      ON_PREMISE_USER_BASE_URL + '/user/paymentChargeShare';

  // handle paymentConfirm
  static const String PAYMENT_SUCCESS_CALL_URL =
      ON_PREMISE_USER_BASE_URL + '/user/paymentConfirm';

  // handle guest user
  static const String STRIPE_ONBOARD_REGISTER_URL =
      ON_PREMISE_USER_BASE_URL + '/user/paymentOutAccounts';

  // get therapist details
  static const String GET_THERAPIST_DETAILS_URL =
      ON_PREMISE_USER_BASE_URL + '/user/therapistById';

  // add user address
  static const String USER_ADD_ADDRESS =
      ON_PREMISE_USER_BASE_URL + '/user/userCreateAddress';

  // USER fcm History
  static const String USER_FIREBASE_NOTIFICATION_HISTORY =
      ON_PREMISE_USER_BASE_URL +
          '/firebaseNotification/firebaseNotificationUserList';

  // provider fcm History
  static const String PROVIDER_FIREBASE_NOTIFICATION_HISTORY =
      ON_PREMISE_USER_BASE_URL +
          '/firebaseNotification/firebaseNotificationTherapistList';

  // provider fcm History
  static const String UPDATE_FIREBASE_NOTIFICATION_READSTATUS =
      ON_PREMISE_USER_BASE_URL +
          '/firebaseNotification/firebaseNotificationReadApi';

  // lINE id TOKEN url

  //VERIFY_LINE_ID_TOKEN_URL
  static const String VERIFY_LINE_ID_TOKEN_URL =
      'https://api.line.me/oauth2/v2.1/verify';

  //booking Status Api
  static const String BOOKING_STATUS_LIST =
      ON_PREMISE_USER_BASE_URL + '/booking/bookingStatusList';
  static const String UPCOMING_BOOKING_STATUS_LIST =
      ON_PREMISE_USER_BASE_URL + '/bookingDetails/userUpComingBookingStatus';

  //booking Completed List
  static const String BOOKING_COMPLETED_LIST =
      ON_PREMISE_USER_BASE_URL + '/booking/bookingCompleteStatusList';

  // provider fcm History
  static const String LOGOUT_API =
      ON_PREMISE_USER_BASE_URL + '/user/logoutUser';

  //Common string
  static bool isInternetAvailable = false;
  static String registerProgressText = '登録中...';
  static String locationProgressText = '現在地を取得中...';
  static String getCityProgressText = '府県の市のデータを取得中。。。';
  static String getLoginProgressText = 'ログイン中。。。';
  static bool isUserRegistrationSkipped = false;
  static bool isUserRegistered = false;
  static bool isUserVerified = false;
  static bool isUserForgetVerified = false;
  static bool isUserLoggedIn = false;
  static bool isBottomBarVisible = true;
  static String currentDate;
  static var isUserOnline = false;
  static var snsLoginFlag = 0;
  static String calendarTimeZone = "GMT+09:00"; //"GMT+05:30";

  static var CLIENT_PUBLISHABLE_KEY_STRIPE =
      'pk_test_51HwMwNBL9ibeFzEEMHOV6az31lNurmBP3cvNPqaBQASqm4LrQhfJL5NHJ8fApM8twA1oxflxWUoatPKcef7ScZHS00WzhyrZFk';

  static var CLIENT_SECRET_KEY_STRIPE =
      'sk_test_51HyDhJHsOI5BijsXDYBipQR7TnSU0HmgygzOHQlgENKw6krlttBN6cM2N0vNBVbm9r3kEZe3pMvgW1o5D4dG5HMV00glIPUuVm';

  static String currentDay;

  static String currentMonth;

  static String sampleText =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Sed eu consequat mauris, non rutrum felis. Nam facilisis felis vel sapien convallis volutpat. '
      'Nullam maximus aliquam ante eu aliquam. Vestibulum ante ipsum primis in faucibus orci...';

  //UserForget Password
  static const String userPasswordPhn = "電話番号 ";
  static var userPhnNum = '';
  static var userForgetPassBtn = '送信';
  static const String userPasswordTxt1 = "パスワードを再設定するための認証コードを送信します。";
  static const String userPasswordTxt2 = "ご登録の電話番号を入力の上「送信」ボタンを";
  static const String userPasswordTxt3 = "クリックしてください。";

  //Register Service User Screen Constants
  static String serviceUserById = '';
  static String serviceUserName = '';
  static String serviceUserDOB = '';
  static String serviceUserGender = '';
  static String serviceUserOccupation = '';
  static String serviceUserAge;
  static String serviceUserPhoneNumber;
  static String serviceUserEmailAddress = '';
  static String serviceUserAddressType = '';
  static String serviceUserMassagePlace = '';
  static String serviceUserAddress = '';

  static String searchKeyWordValue;
  static int searchType;
  static var searchAddressLatitude;
  static var searchAddressLongitude;

  static String serviceUserPrefecture = '';
  static String serviceUserPrefectureId = '';
  static String serviceUserCity = '';
  static String serviceUserBuildingName = '';
  static String serviceUserArea = '';
  static int serviceUserRoomNumber = 0; //gpsAddress
  static String userAddress = '';
  static double currentLatitude = 0.0;
  static double currentLongitude = 0.0;
  static List<SearchList> searchList = new List<SearchList>();

  // User Register otp
  static String serviceUserOtpTxt = 'に届いた「認証コード」を入力し、\n「確認」ボタンをクリックしてください。';
  static String serviceUserOtpBtn = '確認';
  static String serviceResendOtpTxt = '認証コードを再送する';

  // Provider Register otp
  static String serviceProviderOtpTxt = 'に届いた「認証コード」を入力し、\n「確認」ボタンをクリックしてください。';
  static String serviceProviderOtpBtn = '確認';
  static String serviceProviderResendOtpTxt = '認証コードを再送する';

  // login to OTP
  static bool isLoginRoute = false;
  static String fbUserid;

  //Register Service Provider Screen Constants
  static PickedFile profileImage;
  static String serviceProviderUserName = '';
  static String serviceProviderStoreName = '';
  static String serviceProviderDOB = '';
  static String serviceProviderAge = '';
  static String serviceProviderGender = '';
  static String serviceProviderPhoneNumber = '';
  static String serviceProviderStorePhoneNumber = '';
  static String serviceProviderEmailAddress = '';
  static String serviceProviderPrefecture = '';
  static int serviceProviderPrefectureID;
  static String serviceProviderCity = '';
  static int serviceProviderCityID;
  static String serviceProviderBuildingName = '';
  static String serviceProviderArea = '';
  static String serviceProviderRoomNumber = '';
  static String serviceProviderAddress = '';
  static double serviceProviderCurrentLatitude = 0.0;
  static double serviceProviderCurrentLongitude = 0.0;
  static String serviceProviderPassword = '';
  static String serviceProviderConfirmPassword = '';
  static String serviceProviderBusinessForm = '';
  static String serviceProviderNumberOfEmpl = '';
  static List<String> serviceProviderStoreType = List<String>();
  static String serviceProviderBusinessTripService = '';
  static String serviceProviderCoronaMeasure = '';
  static String serviceProviderGenderService = '';
  static List<String> serviceProviderChildrenMeasure = List<String>();
  static List<ServicePriceModel> estheticServicePriceModel =
      List<ServicePriceModel>();
  static List<ServicePriceModel> relaxationServicePriceModel =
      List<ServicePriceModel>();
  static List<ServicePriceModel> treatmentServicePriceModel =
      List<ServicePriceModel>();
  static List<ServicePriceModel> fitnessServicePriceModel =
      List<ServicePriceModel>();
  static List<String> selectedEstheticDropdownValues = List<String>();
  static List<String> selectedRelaxationDropdownValues = List<String>();
  static List<String> selectedTreatmentDropdownValues = List<String>();
  static List<String> selectedFitnessDropdownValues = List<String>();
  static List<String> otherEstheticDropDownValues = List<String>();
  static List<String> otherTreatmentDropDownValues = List<String>();
  static List<String> otherRelaxationDropDownValues = List<String>();
  static List<String> otherFitnessDropDownValues = List<String>();
  static List<Asset> bannerImages = List<Asset>();
  List<File> files = List<File>();
  static int providerRegisterStatus;
  static String idVerify = '';
  static List<String> bankNameDropDownList = List<String>();
  static String bankName = '';
  static String otherBankName = '';
  static String branchNumber = '';
  static String accountNumber = '';
  static String accountType = '';
  static String branchCode = '';
  static String bankCode = '';
  static String bankAccountHolderType = '';
  static String accountHolderName = '';
  static String qualification = '';
  static PickedFile idProfileImage;
  static List<String> privateQualification = List<String>();
  static Map<String, String> certificateImages = Map<String, String>();

  static var therapistRatingID;

  //userDefinedScreens
  static const String UserSelectFirtTxt = 'どちらで利用しますか？';
  static const String UserSelectLastTxt = 'セラピストで登録の場合はサービス利用者\nとしてもログイン可能です。';

  //LoginServiceProvider
  static const String loginText = 'セラピストのログイン';
  static const String loginPhoneNumber = '電話番号 ';
  static const String loginPassword = 'パスワード ';
  static const String loginForgetPassword = 'パスワードを忘れた方はこちら';
  static const String loginButton = 'ログイン';
  static const String loginNewRegistrationText = '新規の方はこちら';
  static const String loginServiceUser = 'サービス利用者のログイン';

  //LoginServiceUser
  static const String loginUserText = 'サービス利用者のログイン';
  static const String loginUserSkipText = 'スキップ';
  static const String loginUserPhoneNumber = '電話番号 ';
  static const String loginUserPassword = 'パスワード ';
  static const String loginUserForgetPassword = 'パスワードを忘れた方はこちら';
  static const String loginUserButton = 'ログイン';
  static const String loginUserNewRegistrationText = '新規の方はこちら';
  static const String loginServiceProvider = 'セラピストのログイン';

  //RegistrationServiceProvider
  static const String registrationFirstText = 'セラピスト情報の入力';
  static const String registrationSecondText = 'は必須項目です';
  static const String registrationScndText = 'は必須項目です';
  static const String registrationFacePhtoText =
      '利用者に安心していただく為にもなるべく顔の\n 映った写真を使用しましょう。';
  static const String registrationBuisnessForm = '事業形態';
  static const String registrationBuisnessTrip = '出張でのサービス対応可否';
  static const String registrationStoretype = '提供サービスのジャンル';
  static const String registrationCoronaTxt = 'コロナ対策実施有無';
  static const String registrationChildrenTxt = '子供向け施策有無';
  static const String registrationJapanAssociationTxt =
      'マスクの着用、アルコール消毒の徹底、体温管理等日本\n リラクゼーション協会の定める項目を遵守している\n 場合のみチェックください';
  static const String registrationName = 'お名前';
  static const String registrationStoreTxt = '店舗として登録の場合は代表者の氏名を入力してください';
  static const String registrationStoreName = '店舗名';
  static const String registrationDob = '生年月日';
  static const String registrationAge = '年齢';
  static const String registrationGender = '性別';
  static const String registrationPhnNum = '電話番号';
  static const String registrationStorePhnNum = '店舗の電話番号';
  static const String registrationMailAdress = 'メールアドレス';
  static const String registrationPassword = 'パスワード';
  static const String registrationPasswordInstructionText =
      "半角英数8～16文字以内で、大文字、小文字、\n数字特殊文字を2種類以上使用";
  static const String registrationConfirmPassword = 'パスワード(確認用)';
  static const String registrationStorePhnText = '店舗として登録の場合は代表者の携帯番号を入力してください';
  static const String registrationIndividualText =
      '個人で登録の方は、住所の詳細情報が利用者に\n 開示されることはありません';
  static const String registrationPlaceAddress = '住所の登録';
  static const String registrationBuildingName = '建物名';
  static const String registrationRoomNo = '部屋番号';
  static const String registrationPointTxt =
      '登録地点周辺のサービス利用者に優先的に\n 検索されるようになります。';
  static const String registrationNextBtn = '次へ';

  static const String registrationIdentityVerification = '本人確認証を選択してください';
  static const String registrationIdentityUpload = '本人確認証のアップロード';
  static const String registrationAdd = '保有資格の種類を選択し、\n証明書をアップロードしてください。';
  static const String registrationQualificationDropdown = '保有資格の種類を選択してください。';
  static const String registrationQualificationUpload = 'ファイルをアップロードする';
  static const String registrationChooseServiceNavBtn = '提供サービスと料金設定';
  static const String registrationMultiPhotoUpload = '掲載写真のアップロード';
  static const String registrationBankDetails = '売り上げ振込先銀行口座';
  static const String registrationBankName = '銀行名';
  static const String registrationBankBranchCode = '支店名';
  static const String registrationBankBranchNumber = '支店番号';
  static const String registrationBankNumber = '銀行番号';
  static const String registrationBankAccountNumber = '口座番号';
  static const String registrationHolderName = '銀行口座名義';
  static const String registrationBankAccountType = '口座種類';
  static const String registrationBankAccountHolderType = '口座名義人の業種';
  static const String registrationCompleteBtn = '登録完了';
  static const String registrationAlreadyActTxt = 'すでにアカウントをお持ちの方';
  static const String registrationBankOtherDropdownFiled = "その他";

  //ChooseServiceScreen
  static const String chooseServiceFirstText = "提供するサービスを選択し料金を設定してください。";
  static const String chooseServiceEstheticDropDown = "エステ";
  static const String chooseServiceRelaxationDropDown = "リラクゼーション";
  static const String chooseServiceTreatmentDropDown = "整骨・整体";
  static const String chooseServiceFitnessDropDown = "フィットネス";
  static const String chooseServiceOtherDropdownFiled = "その他";
  static const String chooseServiceAddTextFormField = "入力してください";
  static const String chooseServiceAddtoDropdownButton = "追加";

  //Forget Password
  static const String forgetPasswordPhn = "電話番号 ";
  static var userPhoneNumber = '';
  static const String forgetPasswordTxt =
      "パスワードを再設定するための認証コードを送信します。\n ご登録の電話番号を入力の上「送信」ボタンを\n クリックしてください。";

//bookingCancelStatus
  static var bookingCancelStatus = 0;

  //Change Password
  static const String changePasswordNewpass = "新しいパスワード ";
  static const String changePasswordTxt =
      "に届いた「認証コード」と\n 新しいパスワードを入力し、「パスワードを\n 再設定する」ボタンをクリックしてください。";
  static const String changePasswordConfirmpass = "パスワード（確認用）";
  static const String changePasswordBtn = 'パスワードを再設定する';
  static const String changeResendOtp = '認証コードを再送する';
  static var providerPhnNum = '';

  //Edit Profile
  static const String profileUpdateBtn = '更新';

  //Provider Edit Screen

  static const String editProfileBuisnessForm = '事業形態';
  static const String editProfileName = 'お名前';
  static const String editProfileStoreName = '店舗名';
  static const String editProfileDob = '生年月日';
  static const String editProfilePhnNum = '電話番号';
  static const String editProfileStorePhnNum = '店舗の電話番号';
  static const String editProfileMailAdress = 'メールアドレス';
  static const String editProfileBuildingName = '建物名';
  static const String editProfileRoomNo = '部屋番号';
  static const String editProfileGender = '性別';

  //Provider Home
  static providerLogin.Data userData;
  static bool isProvider = false;
  static bool isActive = true;
  static bool isProviderHomePage;
  static bool isLoggedin = false;

  static String accessToken;
  static String providerName;
  static int numberOfEmployeeRegistered;

  static int serviceUserId;
  static int userId;
  static List<FlutterWeekViewEvent> events =
      List<FlutterWeekViewEvent>(); //allEvents
  static List<FlutterWeekViewEvent> calEvents = List<FlutterWeekViewEvent>();
  static List<StoreServiceTime> therapistDetails = List<StoreServiceTime>();
  static Map<int, int> unavailableProviderIds = Map<int, int>();
  static String storeServiceTime = '';

  //Firebase Chat
  static String fbUserId;

  //Booking ID
  static int bookingId;

  //User Calendar
  static TherapistByIdModel therapistProfileDetails;
  static void Function(DateTime) callBack;
  static DateTime selectedDateTime;
  static int selectedMin = 0;
  static List<FlutterWeekViewEvent> userEvents = List<FlutterWeekViewEvent>();

  // User Booking Confirmation
  static int confTherapistId;
  static String confBooking = '';
  static String confShopName = '';
  static String confUserName = '';
  static var confServiceType = '';
  static String confRatingAvg = '';
  static String confAddress = '';
  static String confServiceName = '';
  static String confServiceAddressType = '';
  static String confServiceAddress = '';
  static String locality = '';
  static int confNoOfReviewsMembers;
  static int confserviceCId;
  static int confserviceSubId;
  static var confNoOfServiceDuration;
  static var confServiceCost;
  static var confCertificationUpload;
  static bool confBuisnessTrip;
  static bool confShop;
  static bool confCoronaMeasures;
  static DateTime confSelectedDateTime;
  static DateTime confEndDateTime;

  //User Token
  static String uAccessToken = '';

  // LINE Login Channel ID && Credentials
  static const String clientLineChannelID = '1655556164';
  static const String demoLineChannelID = '1620019587';

  static String lineUserID;

  static String lineAccessToken;
  static String lineUsername;
  static String lineUserProfileURL;

  static String lineUserProfileDetails;

  static String lineUserEmail;

  //Apple Login ID & Credentials
  static const String appleIDRedirectUrl =
      "https://healing-match.firebaseapp.com/__/auth/handler";
  static String appleUserName;
  static String appleEmailId;
  static String appleTokenId;

  // Profile Edit screen user
  static Uint8List userEditProfile;
  static String userEditToken = '';

  static var userEditUserId;
  static String userAddressId;
  static var userDeviceToken = '';

  static String userEditUserName = '';
  static String userEditPhoneNumber = '';
  static String userEditEmailAddress = '';
  static String userEditDob = '';
  static String userEditUserAge = '';
  static String userEditUserGender = '';
  static String userEditUserOccupation = '';
  static String userEditUserAddress = '';
  static String userEditBuildName = '';
  static String userEditRoomNo = '';
  static String userEditCity = '';
  static String userEditPrefecture = '';
  static String userEditPlaceForMassage = '';
  static String userEditPlaceForMassageOther = '';
  static String userEditArea = '';
  static String userEditAddress = '';
  static double mEditCurrentLatitude = 0.0;
  static double mEditCurrentLongitude = 0.0;
  static double addedCurrentLatitude = 0.0;
  static double addedCurrentLongitude = 0.0;
  static double manualAddressCurrentLatitude = 0.0;
  static double manualAddressCurrentLongitude = 0.0;
  static String addedServiceUserPrefecture = '';
  static String addedServiceUserCity = '';
  static String manualUserAddress = '';
  static String searchUserAddress = '';
  static String searchUserAddressType = '';
  static bool isLocationCriteria = true;
  static bool isTimeCriteria = true;
  static int serviceType = 0;
  static bool showAddress = true;
  static int addressTypeValues = 0;
  static DateTime dateTime = DateTime.now().add(Duration(minutes: 45));
  static List<UserAddresses> userAddressesList = new List<UserAddresses>();
  static var searchDistanceRadius;
  static String userProfileImage;
  static String serviceUserID;
  static var intServiceUserID;
  static List<AddedSubAddresses> editUserSubAddressList =
      new List<AddedSubAddresses>();
  static String serviceUserBookingAmount;

  //User booking Screen
  static dynamic bookingAddressId;
  static dynamic userRegAddressId;
  static List<String> addressDropDownValues = List<String>();

  //Therapist Detail Screen
  static String therapistDStoreName = '';
  static var therapistDProfileImage;
  static String therapistDStoreType = '';
  static String therapistDBusinessForm = '';
  static int therapistDNumberOfEmp = 0;
  static String therapistDStoreDescription = '';
  static String therapistDProofOfIdentityType = '';

  // User Home screen
  static int serviceTypeValue = 0;
  static double serviceDistanceRadius;
  static List<String> userBannerImages = [];
  static int therapistId = 0;
  static List<TherapistUsersModel> getRecommendedTherapists = [];

  //User details
  static String userRegisteredAddressDetail = '';
  static String userRoomNo = '';
  static String userCity = '';
  static String userPrefecture = '';
  static String userPlaceForMassage = '';
  static String userPlaceForMassageOther = '';
  static String userArea = '';
  static String userBuildName = '';
  static List<UserAddresses> userAddressDetailsList = new List<UserAddresses>();

  // User Profile screen
  //Uint8List profile image;
  static Uint8List profileImageInBytes;
  static Uint8List therapistProfileImageInBytes;

  //User Search screen
  static String searchKeywordHint = 'キーワードでさがす';
  static String searchAreaTxt = 'さがすエリアを選んでください';
  static String searchGpsIconTxt = '現在地';
  static String searchHomeIconTxt = '自宅';
  static String searchOfficeIconTxt = 'オフィス';
  static String searchOtherIconTxt = 'その他';
  static String searchPHomeIconTxt = '実家';
  static String searchServiceSelTxt = '受けたい施術を選んでください';
  static String searchEsteticTxt = 'エステ';
  static String searchOsthepaticTxt = '整骨・整体';
  static String searchRelaxationTxt = 'リラクゼーション';
  static String searchFitnessTxt = 'フィットネス';
  static String searchTravelTxt = '施術の場所を選んでください';
  static String searchDateTxt = 'さがす条件を選んでください';
  static int searchServiceType = 0;

  //payment
  static int bookingIdPay;
  static int therapistIdPay;
  static int priceOfServicePay;

  static String adminMessage;
  static int notificationId;

  static String calEventId;

  //Booking confirm screen
  //出張での施術は距離、場所によって別途交通費等がかかる場合があります。
  static String additionalDistanceCost = '出張での施術は距離、場所によって別途交通費等がかかる場合があります。\n'
      '交通費等が発生する場合は予約完了前にセラピストから別途メッセージがあります。';

  //Booking cancel screen
  //出張での施術は距離、場所によって別途交通費等がかかる場合があります。
  static String cancellationFeeCost = '予約確定（支払い完了）した案件で、施術時間から'
      '逆算して48時間以内でのキャンセルはキャンセル料が発生します。（詳細は利用規約をご参照ください。）';

  static String selectedBookingPlace = '';

  // Chat Module
  static String socketConnectURL = '';
  static String socketEmitURL = '';

  // Cancel screens
  static String therapistResponseText =
      '期限内にセラピストに、よる予約の承認がされなかった為、予約はキャンセルされました';
  static String cancelTimerText = '期限内に支払いが完了しなかった為、予約がキャンセルされました。';
  static bool isBookingDone = false;

  //booking HomePage

  //FontStyle
  static const headersText = TextStyle(
    fontSize: 18.0,
    color: Colors.black,
  );

  static TextStyle formTextStyle = TextStyle(
      color: ColorConstants.formTextColor,
      fontFamily: 'NotoSansJP',
      fontSize: 14);

  static TextStyle formLabelTextStyle = TextStyle(
    fontSize: 14.0,
    fontFamily: 'NotoSansJP',
    color: ColorConstants.formHintTextColor,
  );

  static TextStyle formHintTextStyle = TextStyle(
      color: ColorConstants.formHintTextColor,
      fontFamily: 'NotoSansJP',
      fontSize: 14);

  static TextStyle formHintTextStyleStar =
      TextStyle(color: Colors.red, fontFamily: 'NotoSansJP', fontSize: 14);

  static var textFormInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(
      color: ColorConstants.formFieldBorderColor,
    ),
  );

  static TextStyle multiTextHintTextStyle =
      TextStyle(color: ColorConstants.multiTextHintTextColor, fontSize: 14);

  static var multiTextFormInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15.0),
    borderSide: BorderSide(
        color: Colors.grey[400] // ColorConstants.formFieldBorderColor,
        ),
  );

  static var otherFiledTextFormInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(
      color: ColorConstants.formFieldFillColor,
    ),
  );

  static var datePickerTextFormInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(
      color: ColorConstants.formFieldFillColor,
    ),
  );

  static void initiatePayment(BuildContext context) async {
    String _paymentMethodId;
    String _errorMessage = "";
    final _stripePayment = FlutterStripePayment();
    try {
      _stripePayment.setStripeSettings(
          "${HealingMatchConstants.CLIENT_PUBLISHABLE_KEY_STRIPE}");

      _stripePayment.onCancel = () {
        print("the payment form was cancelled");
      };
      _stripePayment.addPaymentMethod().then((paymentResponse) {
        if (paymentResponse.status == PaymentResponseStatus.succeeded) {
          _paymentMethodId = paymentResponse.paymentMethodId;
          debugPrint('Payment Response : ${paymentResponse.paymentMethodId}');
          ProgressDialogBuilder.showOverlayLoader(context);
          Future.delayed(Duration(seconds: 2), () {
            createCustomer(_paymentMethodId, context);
          });
        } else {
          _errorMessage = paymentResponse.errorMessage;
          debugPrint('Error message while payment : $_errorMessage');
          NavigationRouter.switchToPaymentFailedScreen(context);
        }
      }).catchError((error) {
        debugPrint('Payment Error : $error');

        NavigationRouter.switchToPaymentFailedScreen(context);
      });
    } catch (e) {
      NavigationRouter.switchToPaymentFailedScreen(context);
      print('Payment initiate exception : ${e.toString()}');
    }
  }

  static void createCustomer(var paymentID, BuildContext context) async {
    ProgressDialogBuilder.hideLoader(context);
    NavigationRouter.switchToPaymentProcessingScreen(context, paymentID);
  }

  static List<Curve> curveList = [
    Curves.bounceIn,
    Curves.bounceInOut,
    Curves.bounceOut,
    Curves.decelerate,
    Curves.ease,
    Curves.easeIn,
    Curves.easeInBack,
    Curves.easeInCirc,
    Curves.easeInCubic,
    Curves.easeInExpo,
    Curves.easeInOut,
    Curves.easeInOutBack,
    Curves.easeInOutCirc,
    Curves.easeInOutCubic,
    Curves.easeInOutExpo,
    Curves.easeInOutQuad,
    Curves.easeInOutQuart,
    Curves.easeInOutQuint,
    Curves.easeInOutSine,
    Curves.easeInQuad,
    Curves.easeInQuart,
    Curves.easeInQuint,
    Curves.easeInSine,
    Curves.easeInToLinear,
    Curves.easeOut,
    Curves.easeOutBack,
    Curves.easeOutCubic,
    Curves.easeOutExpo,
    Curves.easeOutQuad,
    Curves.easeOutQuart,
    Curves.easeOutQuint,
    Curves.easeOutSine,
    Curves.elasticIn,
    Curves.elasticInOut,
    Curves.elasticOut,
    Curves.fastLinearToSlowEaseIn,
    Curves.fastOutSlowIn,
    Curves.linear,
    Curves.linearToEaseOut,
    Curves.slowMiddle
  ];

  // get stripe redirect url
  static String stripeRedirectURL;

  // get user stripe verified or not value
  static bool isStripeVerified = false;

  static var stripeErrorMessage;
}
