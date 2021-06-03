import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gps_massageapp/constantUtils/colorConstants.dart';
import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/constantUtils/helperClasses/InternetConnectivityHelper.dart';
import 'package:gps_massageapp/customLibraryClasses/ListViewAnimation/ListAnimationClass.dart';
import 'package:gps_massageapp/customLibraryClasses/cardToolTips/showToolTip.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/searchModels/SearchTherapistByTypeModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/searchModels/SearchTherapistResultsModel.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';
import 'package:gps_massageapp/serviceUser/APIProviderCalls/ServiceUserAPIProvider.dart';
import 'package:gps_massageapp/serviceUser/BlocCalls/searchBlocCalls/Repository/SearchResultsRepository.dart';
import 'package:gps_massageapp/serviceUser/BlocCalls/searchBlocCalls/search_bloc.dart';
import 'package:gps_massageapp/serviceUser/BlocCalls/searchBlocCalls/search_event.dart';
import 'package:gps_massageapp/serviceUser/BlocCalls/searchBlocCalls/search_state.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

Animation<double> animation_rotation;
Animation<double> animation_radius_in;
Animation<double> animation_radius_out;
AnimationController controller;
var _selectedIndex;
List<String> _options = ['料金', '距離', '評価', '施術回数'];
double radius;
double dotRadius;

class SearchResultScreen extends StatefulWidget {
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  double ratingsValue = 3.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SearchBloc(
            getSearchResultsRepository: GetSearchResultsRepositoryImpl()),
        child: Container(
          child: InitialSearchResultsScreen(),
        ),
      ),
    );
  }
}

class InitialSearchResultsScreen extends StatefulWidget {
  @override
  State createState() {
    return _InitialSearchResultsScreenState();
  }
}

class _InitialSearchResultsScreenState
    extends State<InitialSearchResultsScreen> {
  var _pageNumber = 1;
  var _pageSize = 10;

  @override
  void initState() {
    checkInternet();
    super.initState();
    initSearchBlocCall();
  }

  initSearchBlocCall() {
    BlocProvider.of<SearchBloc>(context)
        .add(FetchSearchResultsEvent(_pageNumber, _pageSize));
  }

  checkInternet() {
    CheckInternetConnection.checkConnectivity(context);
    if (HealingMatchConstants.isInternetAvailable) {
      initSearchBlocCall();
    } else {
      print('No internet Bloc !!');
      //return HomePageError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: BlocListener<SearchBloc, SearchState>(
            listener: (context, state) {
              if (state is SearchErrorState) {
                return HomePageError();
              }
            },
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoadingState) {
                  print('Loading state');
                  return LoadInitialSearchResultPage();
                } else if (state is SearchLoaderState) {
                  print('Loader widget');
                  return LoadInitialSearchResultPage();
                } else if (state is SearchLoadedState) {
                  print('Loaded users state');
                  return SearchResult(
                      getTherapistsSearchResults:
                          state.getTherapistsSearchResults);
                } else if (state is SearchSortByDataLoadedState) {
                  print('Loaded users by type state');
                  return SearchResultByType(
                      getTherapistsSearchResults:
                          state.getTherapistsSearchResults);
                } else if (state is SearchErrorState) {
                  print('Error state : ${state.message}');
                  return HomePageError();
                } else
                  return Text(
                    "エラーが発生しました！",
                    style: TextStyle(color: Colors.white),
                  );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SearchResult extends StatefulWidget {
  List<SearchList> getTherapistsSearchResults;

  SearchResult({Key key, @required this.getTherapistsSearchResults})
      : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  double ratingsValue = 3.0;
  bool isLoading = false;
  var _pageNumber = 1;
  var _pageSize = 10;
  var therapistId;
  SearchBloc _searchBloc;
  List<SearchTherapistCertificates> certificateUpload = [];
  var certificateUploadKeys;
  Map<String, String> certificateImages = Map<String, String>();
  List<GlobalObjectKey<FormState>> formKeyList;
  BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8.0),
    color: Colors.white,
  );
  var addressOfTherapists, stateOfTherapist, cityOfTherapist;
  List<dynamic> therapistAddress = new List();
  List<dynamic> therapistState = new List();
  List<dynamic> therapistCity = new List();
  List<dynamic> distanceOfTherapist = new List();
  List<dynamic> hasShop = new List();
  var distanceRadius;
  var childrenMeasures;
  var isShop;

  @override
  void initState() {
    super.initState();
    _searchBloc = BlocProvider.of<SearchBloc>(context);
    getSearchResults(widget.getTherapistsSearchResults);
  }

  getSearchResults(List<SearchList> getTherapistsSearchResults) async {
    try {
      if (this.mounted) {
        setState(() {
          formKeyList = List.generate(widget.getTherapistsSearchResults.length,
              (index) => GlobalObjectKey<FormState>(index));
          for (int i = 0; i < getTherapistsSearchResults.length; i++) {
            if (getTherapistsSearchResults[i].user.certificationUploads !=
                null) {
              certificateUpload =
                  getTherapistsSearchResults[i].user.certificationUploads;

              for (int j = 0; j < certificateUpload.length; j++) {
                print('Certificate upload : ${certificateUpload[j].toJson()}');
                certificateUploadKeys = certificateUpload[j].toJson();
                certificateUploadKeys.remove('id');
                certificateUploadKeys.remove('userId');
                certificateUploadKeys.remove('createdAt');
                certificateUploadKeys.remove('updatedAt');
                print('Keys certificate : $certificateUploadKeys');
              }

              certificateUploadKeys.forEach((key, value) async {
                if (certificateUploadKeys[key] != null) {
                  String jKey = getQualificationJPWords(key);
                  if (jKey == "はり師" ||
                      jKey == "きゅう師" ||
                      jKey == "鍼灸師" ||
                      jKey == "あん摩マッサージ指圧師" ||
                      jKey == "柔道整復師" ||
                      jKey == "理学療法士") {
                    certificateImages["国家資格保有"] = "国家資格保有";
                  } else if (jKey == "国家資格取得予定（学生）") {
                    certificateImages["国家資格取得予定（学生）"] = "国家資格取得予定（学生）";
                  } else if (jKey == "民間資格") {
                    certificateImages["民間資格"] = "民間資格";
                  } else if (jKey == "無資格") {
                    certificateImages["無資格"] = "無資格";
                  }
                }
              });
              if (certificateImages.length == 0) {
                certificateImages["無資格"] = "無資格";
              }
              print('certificateImages data : $certificateImages');
            }
            for (int k = 0;
                k < getTherapistsSearchResults[i].user.addresses.length;
                k++) {
              if (getTherapistsSearchResults[i].user.addresses != null) {
                therapistAddress.add(
                    getTherapistsSearchResults[i].user.addresses[k].address);

                therapistState.add(getTherapistsSearchResults[i]
                    .user
                    .addresses[k]
                    .capitalAndPrefecture);

                therapistCity.add(
                    getTherapistsSearchResults[i].user.addresses[k].cityName);

                distanceOfTherapist.add(
                    getTherapistsSearchResults[i].user.addresses[k].distance);

                hasShop.add(getTherapistsSearchResults[i].user.isShop);
                isShop = hasShop;

                addressOfTherapists = therapistAddress;
                stateOfTherapist = therapistState;
                cityOfTherapist = therapistCity;
                distanceRadius = distanceOfTherapist;
                print(
                    'Position values : ${addressOfTherapists[0]} && ${therapistAddress.length}');

                print(
                    'State List values : ${stateOfTherapist[0]} && ${stateOfTherapist.length}');

                print(
                    'City List values : ${cityOfTherapist[0]} && ${cityOfTherapist.length}');

                print('Has shop values : ${isShop[0]} && ${isShop.length}');
              }
            }
            if (getTherapistsSearchResults[i].user.childrenMeasure != null &&
                getTherapistsSearchResults[i].user.childrenMeasure.isNotEmpty) {
              var childMeasureData =
                  getTherapistsSearchResults[i].user.childrenMeasure.split(',');
              final childrenMeasuresList =
                  childMeasureData.map((item) => jsonEncode(item)).toList();
              final uniquechildrenMeasuresList =
                  childrenMeasuresList.toSet().toList();
              childrenMeasures = uniquechildrenMeasuresList
                  .map((item) => jsonDecode(item))
                  .toList();
              print('Children mEASURES values : $childrenMeasures');
            } else {
              print('Children measures is empty !!');
            }
          }
        });
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  String getQualificationJPWords(String key) {
    switch (key) {
      case 'acupuncturist':
        return 'はり師';
        break;
      case 'moxibutionist':
        return 'きゅう師';
        break;
      case 'acupuncturistAndMoxibustion':
        return '鍼灸師';
        break;
      case 'anmaMassageShiatsushi':
        return 'あん摩マッサージ指圧師';
        break;
      case 'judoRehabilitationTeacher':
        return '柔道整復師';
        break;
      case 'physicalTherapist':
        return '理学療法士';
        break;
      case 'acquireNationalQualifications':
        return '国家資格取得予定（学生）';
        break;
      case 'privateQualification1':
        return '民間資格';
      case 'privateQualification2':
        return '民間資格';
      case 'privateQualification3':
        return '民間資格';
      case 'privateQualification4':
        return '民間資格';
      case 'privateQualification5':
        return '民間資格';
        break;
    }
  }

  void showToolTipForResults(
      String text, GlobalObjectKey<FormState> formKeyList) {
    ShowToolTip popup = ShowToolTip(context,
        text: text,
        textStyle: TextStyle(color: Colors.black),
        height: MediaQuery.of(context).size.height / 7,
        width: MediaQuery.of(context).size.width / 2,
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.circular(10.0));

    /// show the popup for specific widget
    popup.show(
      widgetKey: formKeyList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _selectedIndex = null;
            });
          },
        ),
        title: Text(
          '検索結果',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          widget.getTherapistsSearchResults != null &&
                  widget.getTherapistsSearchResults.isNotEmpty
              ? LazyLoadScrollView(
                  isLoading: isLoading,
                  onEndOfPage: () => _getMoreData(),
                  child: CustomScrollView(
                    //shrinkWrap: true,
                    slivers: <Widget>[
                      // Add the app bar to the CustomScrollView.
                      SliverAppBar(
                        // Provide a standard title.
                        elevation: 0.0,
                        backgroundColor: Colors.white,
                        // Allows the user to reveal the app bar if they begin scrolling
                        // back up the list of items.
                        floating: true,
                        flexibleSpace: Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, right: 25.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.082,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey[200],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            child: Center(child: SearchResultChips()),
                          ),
                        ),
                        // Display a placeholder widget to visualize the shrinking size.
                        // Make the initial height of the SliverAppBar larger than normal.
                      ),
                      // Next, create a SliverList
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: BouncingScrollPhysics(),
                              itemCount:
                                  widget.getTherapistsSearchResults.length + 1,
                              itemBuilder: (context, index) {
                                if (index ==
                                    widget.getTherapistsSearchResults.length) {
                                  return _buildProgressIndicator();
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        HealingMatchConstants.therapistId =
                                            widget
                                                .getTherapistsSearchResults[
                                                    index]
                                                .user
                                                .id;
                                        HealingMatchConstants
                                                .serviceDistanceRadius =
                                            distanceRadius[index];
                                      });
                                      print(
                                          "Distance:${HealingMatchConstants.serviceDistanceRadius}");
                                      NavigationRouter
                                          .switchToUserSearchDetailPageOne(
                                              context,
                                              HealingMatchConstants
                                                  .therapistId);
                                    },
                                    child: Container(
                                      // height: MediaQuery.of(context).size.height * 0.22,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      child: new Card(
                                        color: Colors.grey[200],
                                        semanticContainer: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      children: [
                                                        widget
                                                                    .getTherapistsSearchResults[
                                                                        index]
                                                                    .user
                                                                    .uploadProfileImgUrl !=
                                                                null
                                                            ? CachedNetworkImage(
                                                                imageUrl: widget
                                                                    .getTherapistsSearchResults[
                                                                        index]
                                                                    .user
                                                                    .uploadProfileImgUrl,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                                fadeInCurve: Curves
                                                                    .easeInSine,
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  width: 80.0,
                                                                  height: 80.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitDoubleBounce(
                                                                        color: Colors
                                                                            .lightGreenAccent),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  width: 80.0,
                                                                  height: 80.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black12),
                                                                    image: DecorationImage(
                                                                        image: new AssetImage(
                                                                            'assets/images_gps/placeholder_image.png'),
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                              )
                                                            : new Container(
                                                                width: 80.0,
                                                                height: 80.0,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black12),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: new AssetImage(
                                                                          'assets/images_gps/placeholder_image.png')),
                                                                )),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            widget.getTherapistsSearchResults[index].user.storeName !=
                                                                        null &&
                                                                    widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .storeName
                                                                        .isNotEmpty
                                                                ? Text(
                                                                    '${widget.getTherapistsSearchResults[index].user.storeName}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                : Text(
                                                                    '${widget.getTherapistsSearchResults[index].user.userName}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                print(
                                                                    'Tooltip..Search && ${widget.getTherapistsSearchResults[index].user.storeType.length}');
                                                                showToolTipForResults(
                                                                    widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .storeType,
                                                                    formKeyList[
                                                                        index]);
                                                              },
                                                              child: Container(
                                                                key:
                                                                    formKeyList[
                                                                        index],
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                            .grey[
                                                                        400],
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/images_gps/info.svg",
                                                                    height:
                                                                        15.0,
                                                                    width: 15.0,
                                                                    color: Colors
                                                                        .black,
                                                                  ), /* Icon(
                                                          Icons
                                                              .shopping_bag_rounded,
                                                          key: key,
                                                          color: Colors.black ), */
                                                                ),
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            FittedBox(
                                                              child: HealingMatchConstants
                                                                      .isUserRegistrationSkipped
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        return;
                                                                      },
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        'assets/images_gps/heart_wo_color.svg',
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                        color: Colors
                                                                            .grey[400],
                                                                      ),
                                                                    )
                                                                  : FavoriteButton(
                                                                      iconSize:
                                                                          40,
                                                                      iconColor:
                                                                          Colors
                                                                              .red,
                                                                      isFavorite: widget.getTherapistsSearchResults[index].favouriteToTherapist !=
                                                                              null &&
                                                                          widget.getTherapistsSearchResults[index].favouriteToTherapist ==
                                                                              1,
                                                                      valueChanged:
                                                                          (_isFavorite) {
                                                                        print(
                                                                            'Is Favorite : $_isFavorite');
                                                                        if (_isFavorite !=
                                                                                null &&
                                                                            _isFavorite) {
                                                                          // call favorite therapist API
                                                                          ServiceUserAPIProvider.favouriteTherapist(widget
                                                                              .getTherapistsSearchResults[index]
                                                                              .user
                                                                              .id);
                                                                        } else {
                                                                          // call un-favorite therapist API
                                                                          ServiceUserAPIProvider.unFavouriteTherapist(widget
                                                                              .getTherapistsSearchResults[index]
                                                                              .user
                                                                              .id);
                                                                        }
                                                                      }),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .businessForm
                                                                          .contains(
                                                                              '施術店舗あり 施術従業員あり') ||
                                                                      widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .businessForm
                                                                          .contains(
                                                                              '施術店舗あり 施術従業員なし（個人経営）') ||
                                                                      widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .businessForm
                                                                          .contains(
                                                                              '施術店舗なし 施術従業員なし（個人)')
                                                                  ? Visibility(
                                                                      visible:
                                                                          true,
                                                                      child: Container(
                                                                          decoration: BoxDecoration(
                                                                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                                Colors.white,
                                                                                Colors.white,
                                                                              ]),
                                                                              shape: BoxShape.rectangle,
                                                                              border: Border.all(
                                                                                color: Colors.grey[300],
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.grey[200]),
                                                                          padding: EdgeInsets.all(4),
                                                                          child: Text(
                                                                            '店舗',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color.fromRGBO(0, 0, 0, 1),
                                                                            ),
                                                                          )),
                                                                    )
                                                                  : SizedBox
                                                                      .shrink(),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Visibility(
                                                                visible: widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .businesstrip !=
                                                                    0,
                                                                child: Container(
                                                                    padding: EdgeInsets.all(4),
                                                                    decoration: BoxDecoration(
                                                                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                          Colors
                                                                              .white,
                                                                          Colors
                                                                              .white,
                                                                        ]),
                                                                        shape: BoxShape.rectangle,
                                                                        border: Border.all(
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.grey[200]),
                                                                    child: Text(
                                                                      '出張',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            1),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Visibility(
                                                                visible: widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .coronameasure !=
                                                                    0,
                                                                child: Container(
                                                                    padding: EdgeInsets.all(4),
                                                                    decoration: BoxDecoration(
                                                                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                          Colors
                                                                              .white,
                                                                          Colors
                                                                              .white,
                                                                        ]),
                                                                        shape: BoxShape.rectangle,
                                                                        border: Border.all(
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.grey[200]),
                                                                    child: Text(
                                                                      'コロナ対策実施',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            1),
                                                                      ),
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        widget
                                                                    .getTherapistsSearchResults[
                                                                        index]
                                                                    .user
                                                                    .genderOfService !=
                                                                null
                                                            ? FittedBox(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    widget.getTherapistsSearchResults[index].user.genderOfService !=
                                                                            null
                                                                        ? Container(
                                                                            /*padding: widget.getTherapistsSearchResults[index].user.genderOfService !=
                                                                              null && widget.getTherapistsSearchResults[index].user.genderOfService.isNotEmpty
                                                                          ? EdgeInsets.all(
                                                                              4)
                                                                          : SizedBox.shrink(),*/
                                                                            decoration: BoxDecoration(
                                                                                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                                  Colors.white,
                                                                                  Colors.white,
                                                                                ]),
                                                                                shape: BoxShape.rectangle,
                                                                                border: Border.all(
                                                                                  color: Colors.grey[300],
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(5.0),
                                                                                color: Colors.grey[200]),
                                                                            child: Text(
                                                                              '${widget.getTherapistsSearchResults[index].user.genderOfService}',
                                                                              style: TextStyle(
                                                                                color: Color.fromRGBO(0, 0, 0, 1),
                                                                              ),
                                                                            ))
                                                                        : SizedBox.shrink(),
                                                                  ],
                                                                ),
                                                              )
                                                            : SizedBox.shrink(),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        childrenMeasures != null
                                                            ? Container(
                                                                height: 38.0,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    130.0, //200.0,
                                                                child: ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            BouncingScrollPhysics(),
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            childrenMeasures
                                                                                .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          String
                                                                              key =
                                                                              childrenMeasures[index];
                                                                          return WidgetAnimator(
                                                                            Wrap(
                                                                              children: [
                                                                                Container(
                                                                                  padding: EdgeInsets.all(5),
                                                                                  decoration: boxDecoration,
                                                                                  child: Text(
                                                                                    key,
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }),
                                                              )
                                                            : SizedBox.shrink(),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            widget.getTherapistsSearchResults[index]
                                                                        .ratingAvg !=
                                                                    null
                                                                ? Text(
                                                                    "  (${double.parse(widget.getTherapistsSearchResults[index].ratingAvg).toString()})",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromRGBO(
                                                                          153,
                                                                          153,
                                                                          153,
                                                                          1),
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    "(0.0)",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromRGBO(
                                                                          153,
                                                                          153,
                                                                          153,
                                                                          1),
                                                                      /* decoration: TextDecoration
                                                        .underline,*/
                                                                    ),
                                                                  ),
                                                            widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .ratingAvg !=
                                                                    null
                                                                ? RatingBar
                                                                    .builder(
                                                                    initialRating: double.parse(widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .ratingAvg),
                                                                    minRating:
                                                                        0.25,
                                                                    ignoreGestures:
                                                                        true,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemCount:
                                                                        5,
                                                                    itemSize:
                                                                        25,
                                                                    itemPadding:
                                                                        EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                4.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 5,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              255,
                                                                              217,
                                                                              0,
                                                                              1),
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {},
                                                                  )
                                                                : RatingBar
                                                                    .builder(
                                                                    initialRating:
                                                                        0.0,
                                                                    minRating:
                                                                        0.25,
                                                                    ignoreGestures:
                                                                        true,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemCount:
                                                                        5,
                                                                    itemSize:
                                                                        25,
                                                                    itemPadding:
                                                                        EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                4.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 5,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              255,
                                                                              217,
                                                                              0,
                                                                              1),
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {},
                                                                  ),
                                                            widget.getTherapistsSearchResults[index].noOfReviewsMembers !=
                                                                        null &&
                                                                    widget.getTherapistsSearchResults[index]
                                                                            .noOfReviewsMembers !=
                                                                        0
                                                                ? Text(
                                                                    '(${widget.getTherapistsSearchResults[index].noOfReviewsMembers})',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            153,
                                                                            153,
                                                                            153,
                                                                            1),
                                                                        fontFamily:
                                                                            ColorConstants.fontFamily),
                                                                  )
                                                                : Text(
                                                                    '(0)',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            153,
                                                                            153,
                                                                            153,
                                                                            1),
                                                                        fontFamily:
                                                                            ColorConstants.fontFamily),
                                                                  ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        certificateImages
                                                                    .length !=
                                                                0
                                                            ? Container(
                                                                height: 38.0,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    130.0, //200.0,
                                                                child: ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            BouncingScrollPhysics(),
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            certificateImages
                                                                                .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          String
                                                                              key =
                                                                              certificateImages.keys.elementAt(index);
                                                                          return WidgetAnimator(
                                                                            Wrap(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: index == 0 ? const EdgeInsets.only(left: 0.0, top: 4.0, right: 4.0, bottom: 4.0) : const EdgeInsets.all(4.0),
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.all(5),
                                                                                    decoration: boxDecoration,
                                                                                    child: Text(
                                                                                      key,
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }),
                                                              )
                                                            : SizedBox.shrink(),
                                                        widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .lowestPrice !=
                                                                    null &&
                                                                widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .lowestPrice !=
                                                                    0
                                                            ? Row(
                                                                children: [
                                                                  Text(
                                                                    '¥${widget.getTherapistsSearchResults[index].lowestPrice}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  Text(
                                                                    '/${widget.getTherapistsSearchResults[index].leastPriceMin}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Colors.grey[
                                                                            400],
                                                                        fontSize:
                                                                            14),
                                                                  )
                                                                ],
                                                              )
                                                            : SizedBox.shrink()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/images_gps/location.svg',
                                                      height: 20,
                                                      width: 15),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  addressOfTherapists != null &&
                                                          isShop[index] !=
                                                              null &&
                                                          isShop[index] == true
                                                      ? Flexible(
                                                          child: Container(
                                                            child: Text(
                                                              '${addressOfTherapists[index]}',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        )
                                                      : //Container(),
                                                      cityOfTherapist != null &&
                                                              stateOfTherapist !=
                                                                  null
                                                          ? Flexible(
                                                              child: Container(
                                                                child: Text(
                                                                  '${cityOfTherapist[index] + ',' + '${stateOfTherapist[index]}'}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                  Spacer(),
                                                  distanceRadius != null &&
                                                          distanceRadius != 0
                                                      ? Text(
                                                          '${distanceRadius[index]}ｋｍ圏内',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey),
                                                        )
                                                      : Text(
                                                          '0.0ｋｍ圏内',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }),
                        )
                      ]))
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                              border: Border.all(
                                  color: Color.fromRGBO(217, 217, 217, 1)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '検索結果の情報',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'NotoSansJP',
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: new Container(
                                          width: 80.0,
                                          height: 80.0,
                                          decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black12),
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new AssetImage(
                                                    'assets/images_gps/appIcon.png')),
                                          )),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '検索条件に合うセラピスト・店舗はありませんでした。',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'NotoSansJP',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0.0,
                      right: 20,
                      left: 20,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.082,
                        width: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey[200],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                        child: Center(child: SearchResultChips()),
                      ),
                    )
                  ],
                ),
    );
  }

  _getMoreData() async {
    try {
      if (!isLoading) {
        if (this.mounted) {
          setState(() {
            isLoading = true;
            _pageNumber++;
            print('Page number : $_pageNumber Page Size : $_pageSize');
            var providerListApiProvider =
                ServiceUserAPIProvider.getTherapistSearchResults(
                    context, _pageNumber, _pageSize);
            providerListApiProvider.then((value) {
              if (value.data.searchList.isEmpty) {
                setState(() {
                  isLoading = false;
                });
              } else {
                isLoading = false;
                widget.getTherapistsSearchResults.addAll(value.data.searchList);
                getSearchResults(widget.getTherapistsSearchResults);
              }
            }).catchError((error) {
              if (error != null) {
                setState(() {
                  isLoading = false;
                });
              }
            });
          });
        }
      }
      //print('Therapist users data Size : ${therapistUsers.length}');
    } catch (error) {
      print('Exception more data' + error.toString());
      if (error != null) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildProgressIndicator() {
    return new Center(
      child: new Opacity(
        opacity: isLoading ? 1.0 : 0.0,
        child: new SpinKitPulse(color: Colors.lime),
      ),
    );
  }
}

// Search results by type
class SearchResultByType extends StatefulWidget {
  List<SearchTherapistTypeList> getTherapistsSearchResults;

  SearchResultByType({Key key, @required this.getTherapistsSearchResults})
      : super(key: key);

  @override
  _SearchResultByTypeState createState() => _SearchResultByTypeState();
}

class _SearchResultByTypeState extends State<SearchResultByType> {
  double ratingsValue = 3.0;
  bool isLoading = false;
  var _pageNumber = 1;
  var _pageSize = 10;
  var therapistId;
  SearchBloc _searchBloc;
  List<CertificationSearchTypeUploads> certificateUpload = [];
  var certificateUploadKeys;
  Map<String, String> certificateImages = Map<String, String>();
  List<GlobalObjectKey<FormState>> formKeyList;
  BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8.0),
    color: Colors.white,
  );
  var addressOfTherapists, stateOfTherapist, cityOfTherapist;
  List<dynamic> therapistAddress = new List();
  List<dynamic> therapistState = new List();
  List<dynamic> therapistCity = new List();
  List<dynamic> distanceOfTherapist = new List();
  List<dynamic> hasShop = new List();
  var distanceRadius;
  var childrenMeasures;
  var isShop;

  @override
  void initState() {
    super.initState();
    _searchBloc = BlocProvider.of<SearchBloc>(context);
    getSearchResultsByType(widget.getTherapistsSearchResults);
  }

  getSearchResultsByType(
      List<SearchTherapistTypeList> getTherapistsSearchResults) async {
    try {
      if (this.mounted) {
        setState(() {
          formKeyList = List.generate(widget.getTherapistsSearchResults.length,
              (index) => GlobalObjectKey<FormState>(index));
          for (int i = 0; i < getTherapistsSearchResults.length; i++) {
            if (getTherapistsSearchResults[i].user.certificationUploads !=
                null) {
              certificateUpload =
                  getTherapistsSearchResults[i].user.certificationUploads;

              for (int j = 0; j < certificateUpload.length; j++) {
                print('Certificate upload : ${certificateUpload[j].toJson()}');
                certificateUploadKeys = certificateUpload[j].toJson();
                certificateUploadKeys.remove('id');
                certificateUploadKeys.remove('userId');
                certificateUploadKeys.remove('createdAt');
                certificateUploadKeys.remove('updatedAt');
                print('Keys certificate : $certificateUploadKeys');
              }

              certificateUploadKeys.forEach((key, value) async {
                if (certificateUploadKeys[key] != null) {
                  String jKey = getQualificationJPWords(key);
                  if (jKey == "はり師" ||
                      jKey == "きゅう師" ||
                      jKey == "鍼灸師" ||
                      jKey == "あん摩マッサージ指圧師" ||
                      jKey == "柔道整復師" ||
                      jKey == "理学療法士") {
                    certificateImages["国家資格保有"] = "国家資格保有";
                  } else if (jKey == "国家資格取得予定（学生）") {
                    certificateImages["国家資格取得予定（学生）"] = "国家資格取得予定（学生）";
                  } else if (jKey == "民間資格") {
                    certificateImages["民間資格"] = "民間資格";
                  } else if (jKey == "無資格") {
                    certificateImages["無資格"] = "無資格";
                  }
                }
              });
              if (certificateImages.length == 0) {
                certificateImages["無資格"] = "無資格";
              }
              print('certificateImages data : $certificateImages');
            }
            for (int k = 0;
                k < getTherapistsSearchResults[i].user.addresses.length;
                k++) {
              if (getTherapistsSearchResults[i].user.addresses != null) {
                therapistAddress.add(
                    getTherapistsSearchResults[i].user.addresses[k].address);

                therapistState.add(getTherapistsSearchResults[i]
                    .user
                    .addresses[k]
                    .capitalAndPrefecture);

                therapistCity.add(
                    getTherapistsSearchResults[i].user.addresses[k].cityName);

                distanceOfTherapist.add(
                    getTherapistsSearchResults[i].user.addresses[k].distance);

                hasShop.add(getTherapistsSearchResults[i].user.isShop);
                isShop = hasShop;

                addressOfTherapists = therapistAddress;
                stateOfTherapist = therapistState;
                cityOfTherapist = therapistCity;
                distanceRadius = distanceOfTherapist;
                print(
                    'Position values : ${addressOfTherapists[0]} && ${therapistAddress.length}');

                print(
                    'State List values : ${stateOfTherapist[0]} && ${stateOfTherapist.length}');

                print(
                    'City List values : ${cityOfTherapist[0]} && ${cityOfTherapist.length}');

                print('Has shop values : ${isShop[0]} && ${isShop.length}');
              }
            }
            if (getTherapistsSearchResults[i].user.childrenMeasure != null &&
                getTherapistsSearchResults[i].user.childrenMeasure.isNotEmpty) {
              var childMeasureData =
                  getTherapistsSearchResults[i].user.childrenMeasure.split(',');
              final childrenMeasuresList =
                  childMeasureData.map((item) => jsonEncode(item)).toList();
              final uniquechildrenMeasuresList =
                  childrenMeasuresList.toSet().toList();
              childrenMeasures = uniquechildrenMeasuresList
                  .map((item) => jsonDecode(item))
                  .toList();
              print('Children mEASURES values : $childrenMeasures');
            } else {
              print('Children measures is empty !!');
            }
          }
        });
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }

  String getQualificationJPWords(String key) {
    switch (key) {
      case 'acupuncturist':
        return 'はり師';
        break;
      case 'moxibutionist':
        return 'きゅう師';
        break;
      case 'acupuncturistAndMoxibustion':
        return '鍼灸師';
        break;
      case 'anmaMassageShiatsushi':
        return 'あん摩マッサージ指圧師';
        break;
      case 'judoRehabilitationTeacher':
        return '柔道整復師';
        break;
      case 'physicalTherapist':
        return '理学療法士';
        break;
      case 'acquireNationalQualifications':
        return '国家資格取得予定（学生）';
        break;
      case 'privateQualification1':
        return '民間資格';
      case 'privateQualification2':
        return '民間資格';
      case 'privateQualification3':
        return '民間資格';
      case 'privateQualification4':
        return '民間資格';
      case 'privateQualification5':
        return '民間資格';
        break;
    }
  }

  void showToolTipForResults(
      String text, GlobalObjectKey<FormState> formKeyList) {
    ShowToolTip popup = ShowToolTip(context,
        text: text,
        textStyle: TextStyle(color: Colors.black),
        height: MediaQuery.of(context).size.height / 7,
        width: MediaQuery.of(context).size.width / 2,
        backgroundColor: Colors.white,
        padding: EdgeInsets.all(8.0),
        borderRadius: BorderRadius.circular(10.0));

    /// show the popup for specific widget
    popup.show(
      widgetKey: formKeyList,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _selectedIndex = null;
            });
          },
        ),
        title: Text(
          '検索結果',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
          widget.getTherapistsSearchResults != null &&
                  widget.getTherapistsSearchResults.isNotEmpty
              ? LazyLoadScrollView(
                  isLoading: isLoading,
                  onEndOfPage: () => _getMoreTypeData(),
                  child: CustomScrollView(
                    //shrinkWrap: true,
                    slivers: <Widget>[
                      // Add the app bar to the CustomScrollView.
                      SliverAppBar(
                        // Provide a standard title.
                        elevation: 0.0,
                        backgroundColor: Colors.white,
                        // Allows the user to reveal the app bar if they begin scrolling
                        // back up the list of items.
                        floating: true,
                        flexibleSpace: Padding(
                          padding:
                              const EdgeInsets.only(left: 25.0, right: 25.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.082,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey[200],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            child: Center(child: SearchResultChips()),
                          ),
                        ),
                        // Display a placeholder widget to visualize the shrinking size.
                        // Make the initial height of the SliverAppBar larger than normal.
                      ),
                      // Next, create a SliverList
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: BouncingScrollPhysics(),
                              itemCount:
                                  widget.getTherapistsSearchResults.length + 1,
                              itemBuilder: (context, index) {
                                if (index ==
                                    widget.getTherapistsSearchResults.length) {
                                  return _buildProgressIndicator();
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      HealingMatchConstants.therapistId = widget
                                          .getTherapistsSearchResults[index]
                                          .user
                                          .id;
                                      HealingMatchConstants
                                              .serviceDistanceRadius =
                                          distanceRadius[index];
                                      print(
                                          "Distance:${HealingMatchConstants.serviceDistanceRadius}");
                                      NavigationRouter
                                          .switchToUserSearchDetailPageOne(
                                              context,
                                              HealingMatchConstants
                                                  .therapistId);
                                    },
                                    child: Container(
                                      // height: MediaQuery.of(context).size.height * 0.22,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      child: new Card(
                                        color: Colors.grey[200],
                                        semanticContainer: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Column(
                                                      children: [
                                                        widget
                                                                    .getTherapistsSearchResults[
                                                                        index]
                                                                    .user
                                                                    .uploadProfileImgUrl !=
                                                                null
                                                            ? CachedNetworkImage(
                                                                imageUrl: widget
                                                                    .getTherapistsSearchResults[
                                                                        index]
                                                                    .user
                                                                    .uploadProfileImgUrl,
                                                                filterQuality:
                                                                    FilterQuality
                                                                        .high,
                                                                fadeInCurve: Curves
                                                                    .easeInSine,
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  width: 80.0,
                                                                  height: 80.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitDoubleBounce(
                                                                        color: Colors
                                                                            .lightGreenAccent),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  width: 80.0,
                                                                  height: 80.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black12),
                                                                    image: DecorationImage(
                                                                        image: new AssetImage(
                                                                            'assets/images_gps/placeholder_image.png'),
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                              )
                                                            : new Container(
                                                                width: 80.0,
                                                                height: 80.0,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black12),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: new AssetImage(
                                                                          'assets/images_gps/placeholder_image.png')),
                                                                )),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            widget.getTherapistsSearchResults[index].user.storeName !=
                                                                        null &&
                                                                    widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .storeName
                                                                        .isNotEmpty
                                                                ? Text(
                                                                    '${widget.getTherapistsSearchResults[index].user.storeName}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )
                                                                : Text(
                                                                    '${widget.getTherapistsSearchResults[index].user.userName}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                print(
                                                                    'Tooltip..Search && ${widget.getTherapistsSearchResults[index].user.storeType.length}');
                                                                showToolTipForResults(
                                                                    widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .storeType,
                                                                    formKeyList[
                                                                        index]);
                                                              },
                                                              child: Container(
                                                                key:
                                                                    formKeyList[
                                                                        index],
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                            .grey[
                                                                        400],
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/images_gps/info.svg",
                                                                    height:
                                                                        15.0,
                                                                    width: 15.0,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            FittedBox(
                                                              child: HealingMatchConstants
                                                                      .isUserRegistrationSkipped
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        return;
                                                                      },
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        'assets/images_gps/heart_wo_color.svg',
                                                                        width:
                                                                            25,
                                                                        height:
                                                                            25,
                                                                        color: Colors
                                                                            .grey[400],
                                                                      ),
                                                                    )
                                                                  : FavoriteButton(
                                                                      iconSize:
                                                                          40,
                                                                      iconColor:
                                                                          Colors
                                                                              .red,
                                                                      isFavorite: widget.getTherapistsSearchResults[index].favouriteToTherapist !=
                                                                              null &&
                                                                          widget.getTherapistsSearchResults[index].favouriteToTherapist ==
                                                                              1,
                                                                      valueChanged:
                                                                          (_isFavorite) {
                                                                        print(
                                                                            'Is Favorite : $_isFavorite');

                                                                        if (_isFavorite !=
                                                                                null &&
                                                                            _isFavorite) {
                                                                          // call favorite therapist API
                                                                          ServiceUserAPIProvider.favouriteTherapist(widget
                                                                              .getTherapistsSearchResults[index]
                                                                              .user
                                                                              .id);
                                                                        } else {
                                                                          // call un-favorite therapist API
                                                                          ServiceUserAPIProvider.unFavouriteTherapist(widget
                                                                              .getTherapistsSearchResults[index]
                                                                              .user
                                                                              .id);
                                                                        }
                                                                      }),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .businessForm
                                                                          .contains(
                                                                              '施術店舗あり 施術従業員あり') ||
                                                                      widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .businessForm
                                                                          .contains(
                                                                              '施術店舗あり 施術従業員なし（個人経営）') ||
                                                                      widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .businessForm
                                                                          .contains(
                                                                              '施術店舗なし 施術従業員なし（個人)')
                                                                  ? Visibility(
                                                                      visible:
                                                                          true,
                                                                      child: Container(
                                                                          decoration: BoxDecoration(
                                                                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                                Colors.white,
                                                                                Colors.white,
                                                                              ]),
                                                                              shape: BoxShape.rectangle,
                                                                              border: Border.all(
                                                                                color: Colors.grey[300],
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.grey[200]),
                                                                          padding: EdgeInsets.all(4),
                                                                          child: Text(
                                                                            '店舗',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color.fromRGBO(0, 0, 0, 1),
                                                                            ),
                                                                          )),
                                                                    )
                                                                  : SizedBox
                                                                      .shrink(),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Visibility(
                                                                visible: widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .businesstrip !=
                                                                    0,
                                                                child: Container(
                                                                    padding: EdgeInsets.all(4),
                                                                    decoration: BoxDecoration(
                                                                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                          Colors
                                                                              .white,
                                                                          Colors
                                                                              .white,
                                                                        ]),
                                                                        shape: BoxShape.rectangle,
                                                                        border: Border.all(
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.grey[200]),
                                                                    child: Text(
                                                                      '出張',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            1),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Visibility(
                                                                visible: widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .user
                                                                        .coronameasure !=
                                                                    0,
                                                                child: Container(
                                                                    padding: EdgeInsets.all(4),
                                                                    decoration: BoxDecoration(
                                                                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                          Colors
                                                                              .white,
                                                                          Colors
                                                                              .white,
                                                                        ]),
                                                                        shape: BoxShape.rectangle,
                                                                        border: Border.all(
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.grey[200]),
                                                                    child: Text(
                                                                      'コロナ対策実施',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            1),
                                                                      ),
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        FittedBox(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              widget
                                                                          .getTherapistsSearchResults[
                                                                              index]
                                                                          .user
                                                                          .genderOfService !=
                                                                      null
                                                                  ? Container(
                                                                      padding: widget.getTherapistsSearchResults[index].user.genderOfService !=
                                                                              null
                                                                          ? EdgeInsets.all(
                                                                              4)
                                                                          : EdgeInsets.all(
                                                                              0),
                                                                      decoration: BoxDecoration(
                                                                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                            Colors.white,
                                                                            Colors.white,
                                                                          ]),
                                                                          shape: BoxShape.rectangle,
                                                                          border: Border.all(
                                                                            color:
                                                                                Colors.grey[300],
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                          color: Colors.grey[200]),
                                                                      child: Text(
                                                                        '${widget.getTherapistsSearchResults[index].user.genderOfService}',
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              1),
                                                                        ),
                                                                      ))
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        childrenMeasures != null
                                                            ? Container(
                                                                height: 38.0,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    130.0, //200.0,
                                                                child: ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            BouncingScrollPhysics(),
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            childrenMeasures
                                                                                .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          String
                                                                              key =
                                                                              childrenMeasures[index];
                                                                          return WidgetAnimator(
                                                                            Wrap(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: index == 0 ? const EdgeInsets.only(left: 0.0, top: 4.0, right: 4.0, bottom: 4.0) : const EdgeInsets.all(4.0),
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.all(5),
                                                                                    decoration: boxDecoration,
                                                                                    child: Text(
                                                                                      key,
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }),
                                                              )
                                                            : Container(),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            widget.getTherapistsSearchResults[index]
                                                                        .ratingAvg !=
                                                                    null
                                                                ? Text(
                                                                    "  (${double.parse(widget.getTherapistsSearchResults[index].ratingAvg).toString()})",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromRGBO(
                                                                          153,
                                                                          153,
                                                                          153,
                                                                          1),
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    "(0.0)",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromRGBO(
                                                                          153,
                                                                          153,
                                                                          153,
                                                                          1),
                                                                      /* decoration: TextDecoration
                                                        .underline,*/
                                                                    ),
                                                                  ),
                                                            widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .ratingAvg !=
                                                                    null
                                                                ? RatingBar
                                                                    .builder(
                                                                    initialRating: double.parse(widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .ratingAvg),
                                                                    minRating:
                                                                        0.25,
                                                                    ignoreGestures:
                                                                        true,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemCount:
                                                                        5,
                                                                    itemSize:
                                                                        25,
                                                                    itemPadding:
                                                                        EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                4.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 5,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              255,
                                                                              217,
                                                                              0,
                                                                              1),
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {},
                                                                  )
                                                                : RatingBar
                                                                    .builder(
                                                                    initialRating:
                                                                        0.0,
                                                                    minRating:
                                                                        0.25,
                                                                    ignoreGestures:
                                                                        true,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemCount:
                                                                        5,
                                                                    itemSize:
                                                                        25,
                                                                    itemPadding:
                                                                        EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                4.0),
                                                                    itemBuilder:
                                                                        (context,
                                                                                _) =>
                                                                            Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 5,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              255,
                                                                              217,
                                                                              0,
                                                                              1),
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (rating) {},
                                                                  ),
                                                            widget.getTherapistsSearchResults[index].noOfReviewsMembers !=
                                                                        null &&
                                                                    widget.getTherapistsSearchResults[index]
                                                                            .noOfReviewsMembers !=
                                                                        0
                                                                ? Text(
                                                                    '(${widget.getTherapistsSearchResults[index].noOfReviewsMembers})',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            153,
                                                                            153,
                                                                            153,
                                                                            1),
                                                                        fontFamily:
                                                                            ColorConstants.fontFamily),
                                                                  )
                                                                : Text(
                                                                    '(0)',
                                                                    style: TextStyle(
                                                                        color: Color.fromRGBO(
                                                                            153,
                                                                            153,
                                                                            153,
                                                                            1),
                                                                        fontFamily:
                                                                            ColorConstants.fontFamily),
                                                                  ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        certificateImages
                                                                    .length !=
                                                                0
                                                            ? Container(
                                                                height: 38.0,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    130.0, //200.0,
                                                                child: ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            BouncingScrollPhysics(),
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            certificateImages
                                                                                .length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          String
                                                                              key =
                                                                              certificateImages.keys.elementAt(index);
                                                                          return WidgetAnimator(
                                                                            Wrap(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: index == 0 ? const EdgeInsets.only(left: 0.0, top: 4.0, right: 4.0, bottom: 4.0) : const EdgeInsets.all(4.0),
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.all(5),
                                                                                    decoration: boxDecoration,
                                                                                    child: Text(
                                                                                      key,
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }),
                                                              )
                                                            : SizedBox.shrink(),
                                                        widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .lowestPrice !=
                                                                    null &&
                                                                widget
                                                                        .getTherapistsSearchResults[
                                                                            index]
                                                                        .lowestPrice !=
                                                                    0
                                                            ? Row(
                                                                children: [
                                                                  Text(
                                                                    '¥${widget.getTherapistsSearchResults[index].lowestPrice}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                  Text(
                                                                    '/${widget.getTherapistsSearchResults[index].leastPriceMin}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Colors.grey[
                                                                            400],
                                                                        fontSize:
                                                                            14),
                                                                  )
                                                                ],
                                                              )
                                                            : SizedBox.shrink()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/images_gps/location.svg',
                                                      height: 20,
                                                      width: 15),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  addressOfTherapists != null &&
                                                          isShop[index] !=
                                                              null &&
                                                          isShop[index] == true
                                                      ? Flexible(
                                                          child: Container(
                                                            child: Text(
                                                              '${addressOfTherapists[index]}',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        )
                                                      : //Container(),
                                                      cityOfTherapist != null &&
                                                              stateOfTherapist !=
                                                                  null
                                                          ? Flexible(
                                                              child: Container(
                                                                child: Text(
                                                                  '${cityOfTherapist[index] + ',' + '${stateOfTherapist[index]}'}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                  Spacer(),
                                                  distanceRadius != null &&
                                                          distanceRadius != 0
                                                      ? Text(
                                                          '${distanceRadius[index]}ｋｍ圏内',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey),
                                                        )
                                                      : Text(
                                                          '0.0ｋｍ圏内',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }),
                        )
                      ]))
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                              border: Border.all(
                                  color: Color.fromRGBO(217, 217, 217, 1)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '検索結果の情報',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'NotoSansJP',
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: new Container(
                                          width: 80.0,
                                          height: 80.0,
                                          decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black12),
                                            shape: BoxShape.circle,
                                            image: new DecorationImage(
                                                fit: BoxFit.fill,
                                                image: new AssetImage(
                                                    'assets/images_gps/appIcon.png')),
                                          )),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '検索条件に合うセラピスト・店舗はありませんでした。',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'NotoSansJP',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0.0,
                      right: 20,
                      left: 20,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.082,
                        width: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey[200],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                        child: Center(child: SearchResultChips()),
                      ),
                    )
                  ],
                ),
    );
  }

  _getMoreTypeData() async {
    try {
      if (!isLoading) {
        if (this.mounted) {
          setState(() {
            isLoading = true;
            _pageNumber++;
            print('Page number : $_pageNumber Page Size : $_pageSize');
            var providerListApiProvider =
                ServiceUserAPIProvider.getTherapistSearchResultsByType(
                    context, _pageNumber, _pageSize);
            providerListApiProvider.then((value) {
              if (value.data.searchList.isEmpty) {
                setState(() {
                  isLoading = false;
                });
              } else {
                isLoading = false;
                widget.getTherapistsSearchResults.addAll(value.data.searchList);
                getSearchResultsByType(widget.getTherapistsSearchResults);
              }
            }).catchError((error) {
              if (error != null) {
                setState(() {
                  isLoading = false;
                });
              }
            });
          });
        }
      }
      //print('Therapist users data Size : ${therapistUsers.length}');
    } catch (error) {
      print('Exception more data' + error.toString());
      if (error != null) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new SpinKitPulse(color: Colors.lime),
        ),
      ),
    );
  }
}

class SearchResultChips extends StatefulWidget {
  @override
  _SearchResultChipsState createState() => _SearchResultChipsState();
}

class _SearchResultChipsState extends State<SearchResultChips> {
  var _pageNumber = 1;
  var _pageSize = 10;

  Widget _buildChips() {
    List<Widget> chips = new List();
    for (int i = 0; i < _options.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,
        label: Text(_options[i],
            style: TextStyle(
              color: _selectedIndex == i
                  ? Color.fromRGBO(251, 251, 251, 1)
                  : Color.fromRGBO(0, 0, 0, 1),
            )),
        backgroundColor: Colors.white70,
        selectedColor: Colors.lime,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
              print('Chip value : ${_options[_selectedIndex].toString()}');
              if (selected && i == 0) {
                HealingMatchConstants.searchServiceType = 1;
              } else if (selected && i == 1) {
                HealingMatchConstants.searchServiceType = 2;
              } else if (selected && i == 2) {
                HealingMatchConstants.searchServiceType = 3;
              } else if (selected && i == 3) {
                HealingMatchConstants.searchServiceType = 4;
              } else {
                print(
                    'Chip value else loop : ${_options[_selectedIndex].toString()}');
              }
            }
          });
          // Sort data BLOC FetchSearchResultsEvent by Type
          BlocProvider.of<SearchBloc>(context).add(CallSearchByTypeEvent(
              _pageNumber, _pageSize, HealingMatchConstants.searchServiceType));

          print(
              'Search Type value : ${HealingMatchConstants.searchServiceType}');
        },
      );

      chips.add(
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 2), child: choiceChip),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      // This next line does the trick.

      scrollDirection: Axis.horizontal,

      children: chips,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.04,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*  Text(
                      'ソ－ト',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontFamily: 'NotoSansJP'),
                    ),*/
                    _buildChips(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class HomePageError extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageErrorState();
  }
}

class _HomePageErrorState extends State<HomePageError> {
  var _pageNumber = 1;
  var _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: InkWell(
              splashColor: Colors.deepOrangeAccent,
              highlightColor: Colors.limeAccent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Color.fromRGBO(255, 255, 255, 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      AntDesign.disconnect,
                      color: Colors.deepOrangeAccent,
                      size: 50,
                    ),
                    Text('インターネット接続を確認してください。',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Open Sans',
                            color: Colors.black)),
                    InkWell(
                      splashColor: Colors.deepOrangeAccent,
                      highlightColor: Colors.limeAccent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(MaterialIcons.refresh),
                            onPressed: () {
                              /* BlocProvider.of<TherapistTypeBloc>(context).add(
                                  RefreshEvent(
                                      HealingMatchConstants.accessToken,
                                      _pageNumber,
                                      _pageSize,
                                      context));*/
                            },
                          ),
                          Text(
                            'もう一度試してください。',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Open Sans',
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

// Loader HomePage
class LoadInitialSearchResultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoadInitialSearchResultPageState();
  }
}

class _LoadInitialSearchResultPageState
    extends State<LoadInitialSearchResultPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          SizedBox(height: 20),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(children: [
                  Shimmer(
                    duration: Duration(milliseconds: 300),
                    //Default value
                    interval: Duration(milliseconds: 300),
                    //Default value: Duration(seconds: 0)
                    color: Colors.grey[300],
                    //Default value
                    enabled: true,
                    //Default value
                    direction: ShimmerDirection.fromLeftToRight(),
                    child: CarouselSlider(
                      items: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: new BoxDecoration(
                                    border:
                                        Border.all(color: Colors.transparent),
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.none,
                                        image: new AssetImage(
                                            'assets/images_gps/logo.png')),
                                  )),
                              Text(
                                'Healing match',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        )
                      ],
                      options: CarouselOptions(
                          autoPlay: false,
                          autoPlayCurve: Curves.easeInOutCubic,
                          enlargeCenterPage: false,
                          viewportFraction: 0.9,
                          aspectRatio: 2.0),
                    ),
                  ),
                ]),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer(
              duration: Duration(milliseconds: 300),
              //Default value
              interval: Duration(milliseconds: 300),
              //Default value: Duration(seconds: 0)
              color: Colors.grey[400],
              //Default value
              enabled: true,
              //Default value
              direction: ShimmerDirection.fromLTRB(),
              child: Container(
                color: Colors.grey[200],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Shimmer(
            duration: Duration(milliseconds: 300),
            //Default value
            interval: Duration(milliseconds: 300),
            //Default value: Duration(seconds: 0)
            color: Colors.grey[300],
            //Default value
            enabled: true,
            //Default value
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Card(elevation: 5),
            ),
          ),
          Shimmer(
            duration: Duration(milliseconds: 300),
            //Default value
            interval: Duration(milliseconds: 300),
            //Default value: Duration(seconds: 0)
            color: Colors.grey[400],
            //Default value
            enabled: true,
            //Default value
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
              color: Colors.grey[200],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.22,
              width: MediaQuery.of(context).size.width * 0.95,
              child: Shimmer(
                duration: Duration(milliseconds: 300),
                //Default value
                interval: Duration(milliseconds: 300),
                //Default value: Duration(seconds: 0)
                color: Colors.grey[300],
                //Default value
                enabled: true,
                //Default value
                direction: ShimmerDirection.fromLTRB(),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return WidgetAnimator(
                        new Card(
                          color: Colors.grey[200],
                          semanticContainer: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.70,
                              width: MediaQuery.of(context).size.width * 0.78,
                              child: Shimmer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    new Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: new BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(
                                              color: Colors.grey[200]),
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                              fit: BoxFit.none,
                                              image: new AssetImage(
                                                  'assets/images_gps/logo.png')),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Shimmer(
            duration: Duration(milliseconds: 300),
            //Default value
            interval: Duration(milliseconds: 300),
            //Default value: Duration(seconds: 0)
            color: Colors.grey[400],
            //Default value
            enabled: true,
            //Default value
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
              color: Colors.grey[200],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.22,
              width: MediaQuery.of(context).size.width * 0.95,
              child: Shimmer(
                duration: Duration(milliseconds: 300),
                //Default value
                interval: Duration(milliseconds: 300),
                //Default value: Duration(seconds: 0)
                color: Colors.grey[300],
                //Default value
                enabled: true,
                //Default value
                direction: ShimmerDirection.fromLTRB(),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return WidgetAnimator(
                        new Card(
                          color: Colors.grey[200],
                          semanticContainer: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.70,
                              width: MediaQuery.of(context).size.width * 0.78,
                              child: Shimmer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    new Container(
                                        width: 80.0,
                                        height: 80.0,
                                        decoration: new BoxDecoration(
                                          color: Colors.grey[200],
                                          border: Border.all(
                                              color: Colors.grey[200]),
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                              fit: BoxFit.none,
                                              image: new AssetImage(
                                                  'assets/images_gps/logo.png')),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Shimmer(
            duration: Duration(milliseconds: 300),
            //Default value
            interval: Duration(milliseconds: 300),
            //Default value: Duration(seconds: 0)
            color: Colors.grey[400],
            //Default value
            enabled: true,
            //Default value
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
              color: Colors.grey[200],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    '',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
