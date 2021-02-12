import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gps_massageapp/routing/navigationRouter.dart';

class NearByProviderAndShop extends StatefulWidget {
  @override
  _NearByProviderAndShopState createState() => _NearByProviderAndShopState();
}

class _NearByProviderAndShopState extends State<NearByProviderAndShop> {
  double ratingsValue = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            NavigationRouter.switchToServiceUserBottomBar(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          '近くのセラピスト＆お店',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Container(
                        // height: MediaQuery.of(context).size.height * 0.22,
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: new Card(
                          elevation: 0.0,
                          color: Colors.grey[100],
                          semanticContainer: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        child: SvgPicture.asset(
                                          'assets/images_gps/gpsLogo.svg',
                                          height: 35,
                                          color: Colors.blue,
                                        ),
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                      ),
                                      FittedBox(
                                        child: Text(
                                          '1.5km園内',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '店舗名',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45),
                                        FittedBox(
                                          child: FavoriteButton(
                                              iconSize: 40,
                                              iconColor: Colors.red,
                                              valueChanged: (_isFavorite) {
                                                print(
                                                    'Is Favorite : $_isFavorite');
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.transparent,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              padding: EdgeInsets.all(4),
                                              child: Text('店舗')),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.transparent,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              child: Text('出張')),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.transparent,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12))),
                                              child: Text('コロナ対策実施')),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          ratingsValue.toString(),
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        RatingBar.builder(
                                          initialRating: 3,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 25,
                                          itemPadding: EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            size: 5,
                                            color: Colors.black,
                                          ),
                                          onRatingUpdate: (rating) {
                                            // print(rating);
                                            setState(() {
                                              ratingsValue = rating;
                                            });
                                            print(ratingsValue);
                                          },
                                        ),
                                        Text('(1518)'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12))),
                                            child: Text('国家資格保有')),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15),
                                        Text(
                                          '¥4,500',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 19),
                                        ),
                                        Text(
                                          '/60分',
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
          Positioned(
            top: 0.0,
            right: 20,
            left: 20,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.068,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              child: Center(child: MassageTypeChips()),
            ),
          )
        ],
      ),
    );
  }
}

class MassageTypeChips extends StatefulWidget {
  @override
  _MassageTypeChipsState createState() => _MassageTypeChipsState();
}

class _MassageTypeChipsState extends State<MassageTypeChips> {
  List<String> _options = ['エステ', '整骨・整体）', 'リラクゼーション', 'フィットネス'];
  int _selectedIndex;

  Widget _buildChips() {
    List<Widget> chips = new List();

    for (int i = 0; i < _options.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,
        label: Text(_options[i], style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white70,
        selectedColor: Colors.lime,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
              print('Chip value : ${_options[_selectedIndex].toString()}');
            }
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 8), child: choiceChip));
    }

    return ListView(
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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.04,
                child: _buildChips(),
              ),
            ],
          )),
    );
  }
}