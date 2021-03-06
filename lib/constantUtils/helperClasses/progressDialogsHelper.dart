import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gps_massageapp/customLibraryClasses/progressDialogs/custom_dialog.dart';

import '../constantsUtils.dart';

class ProgressDialogBuilder {
  static ProgressDialog progressDialog = ProgressDialog();

  //Register user
  static void showRegisterProgressDialog(BuildContext context) {
    progressDialog.showProgressDialog(context,
        textToBeDisplayed: '${HealingMatchConstants.registerProgressText}',
        dismissAfter: Duration(seconds: 5));
  }

//Register Provider
  static void showProviderRegisterProgressDialog(BuildContext context) {
    /* progressDialog.showProgressDialog(context,
        textToBeDisplayed: '${HealingMatchConstants.registerProgressText}',
        dismissAfter: Duration(seconds: 15)); */
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
  }

  static void hideRegisterProgressDialog(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
    /*  progressDialog.dismissProgressDialog(context); */
  }

  // Adding address
  static void showAddAddressProgressDialog(BuildContext context) {
    progressDialog.showProgressDialog(context,
        textToBeDisplayed: '住所の追加中...', dismissAfter: Duration(seconds: 3));
  }

  static void hideAddAddressProgressDialog(BuildContext context) {
    progressDialog.dismissProgressDialog(context);
  }

  // Getting location
  static void showLocationProgressDialog(BuildContext context) {
    progressDialog.showProgressDialog(context,
        textToBeDisplayed: '${HealingMatchConstants.locationProgressText}',
        dismissAfter: Duration(seconds: 5));
  }

  static void hideLocationProgressDialog(BuildContext context) {
    progressDialog.dismissProgressDialog(context);
  }

  // Getting Cities
  static void showGetCitiesProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*  progressDialog.showProgressDialog(context,
        textToBeDisplayed: '${HealingMatchConstants.getCityProgressText}',
        dismissAfter: Duration(seconds: 5)); */
  }

  static void hideGetCitiesProgressDialog(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
    /*   progressDialog.dismissProgressDialog(context); */
  }

  // Login user
  static void showLoginUserProgressDialog(BuildContext context) {
    progressDialog.showProgressDialog(context,
        textToBeDisplayed: '${HealingMatchConstants.getLoginProgressText}',
        dismissAfter: Duration(seconds: 5));
  }

  static void hideLoginUserProgressDialog(BuildContext context) {
    progressDialog.dismissProgressDialog(context);
  }

//user forgetPassword
  static void showForgetPasswordUserProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*   progressDialog.showProgressDialog(context,
        //textToBeDisplayed: '${HealingMatchConstants.getLoginProgressText}',
        dismissAfter: Duration(seconds: 5)); */
  }

  static void hideForgetPasswordUserProgressDialog(BuildContext context) {
    /* progressDialog.dismissProgressDialog(context); */
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
  }

  //user change password
  static void showChangePasswordUserProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*  progressDialog.showProgressDialog(context,
        //textToBeDisplayed: '${HealingMatchConstants.getLoginProgressText}',
        dismissAfter: Duration(seconds: 5)); */
  }

  static void hideChangePasswordUserProgressDialog(BuildContext context) {
    /*  progressDialog.dismissProgressDialog(context); */
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
  }

  //verify otp
  static void showVerifyOtpProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*    progressDialog.showProgressDialog(context,
        textToBeDisplayed: 'ユーザー認証コードの確認中。。。',
        dismissAfter: Duration(seconds: 5)); */
  }

  static void hideVerifyOtpProgressDialog(BuildContext context) {
    /*  progressDialog.dismissProgressDialog(context); */
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
  }

  // Login Provider
  static void showLoginProviderProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*  progressDialog.showProgressDialog(context,
        textToBeDisplayed: '${HealingMatchConstants.getLoginProgressText}',
        dismissAfter: Duration(seconds: 5)); */
  }

  static void hideLoginProviderProgressDialog(BuildContext context) {
    /*   progressDialog.dismissProgressDialog(context); */ Future.delayed(
        Duration(seconds: 0), () {
      Loader.hide();
    });
  }

  //For Normal Loading of Progress Dialog
  static void showCommonProgressDialog(BuildContext context) {
    /*  progressDialog.showProgressDialog(context,
        textToBeDisplayed: 'お待ちください。', dismissAfter: Duration(seconds: 5)); */
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
  }

  static void hideCommonProgressDialog(BuildContext context) {
    /*   progressDialog.dismissProgressDialog(context); */
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
  }

  // upadte user details 更新中。
  static void showUserDetailsUpdateProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /* progressDialog.showProgressDialog(context,
        textToBeDisplayed: '更新中。。', dismissAfter: Duration(seconds: 5)); */
  }

  static void hideUserDetailsUpdateProgressDialog(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
    /*   progressDialog.dismissProgressDialog(context); */
  }

  // update provider shop description details 更新中。
  static void showProviderShopDescription(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*  progressDialog.showProgressDialog(context,
        textToBeDisplayed: '更新中。。', dismissAfter: Duration(seconds: 5)); */
  }

  static void hideProviderShopDescription(BuildContext context) {
    progressDialog.dismissProgressDialog(context);
  }

//  Ratings And Review Dialog
  static void showRatingsAndReviewProgressDialog(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
    /*   progressDialog.showProgressDialog(context,
        //textToBeDisplayed: '${HealingMatchConstants.getLoginProgressText}',
        dismissAfter: Duration(seconds: 5)); */
  }

  static void hideRatingsAndReviewProgressDialog(BuildContext context) {
    progressDialog.dismissProgressDialog(context);
  }

  static void showOverlayLoader(BuildContext context) {
    Loader.show(context,
        progressIndicator: SpinKitThreeBounce(color: Colors.lime));
  }

  static void hideLoader(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      Loader.hide();
    });
  }
}
