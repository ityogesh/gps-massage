import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intl/intl.dart';

/// Created by Marcin Szałek
///Define a text mapper to transform the text displayed by the picker
typedef String TextMapper(String numberText);

///NumberPicker is a widget designed to pick a number between #minValue and #maxValue
class NumberPicker extends StatelessWidget {
  ///height of every list element for normal number picker
  ///width of every list element for horizontal number picker
  static const double kDefaultItemExtent = 47.0;

  ///width of list view for normal number picker
  ///height of list view for horizontal number picker
  static const double kDefaultListViewCrossAxisSize = 100.0;

  ///constructor for horizontal number picker
  NumberPicker.horizontal({
    Key key,
    @required int initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.textMapper,
    this.currentDate,
    this.selectedYear,
    this.selectedMonth,
    this.eventDates,
    this.enabled = false,
    this.itemExtent = kDefaultItemExtent,
    this.listViewHeight = kDefaultListViewCrossAxisSize,
    this.numberToDisplay = 3,
    this.step = 1,
    this.zeroPad = false,
    this.highlightSelectedValue = true,
    this.decoration,
    this.ismonth = false,
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(step > 0),
        selectedIntValue = initialValue,
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = new ScrollController(
          initialScrollOffset: (initialValue - minValue) ~/
              step *
              itemExtent, //eg 1-10, start 5: (5-1)/1*50=4*50=200
        ),
        scrollDirection = Axis.horizontal,
        decimalScrollController = null,
        listViewWidth = numberToDisplay * itemExtent,
        infiniteLoop = false,
        integerItemCount = (maxValue - minValue) ~/ step + 1,
        super(key: key);

  ///constructor for integer number picker
  NumberPicker.integer({
    Key key,
    @required int initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.textMapper,
    this.currentDate,
    this.selectedYear,
    this.selectedMonth,
    this.eventDates,
    this.enabled = false,
    this.itemExtent = kDefaultItemExtent,
    this.listViewWidth = kDefaultListViewCrossAxisSize,
    this.numberToDisplay = 3,
    this.step = 1,
    this.scrollDirection = Axis.vertical,
    this.infiniteLoop = false,
    this.zeroPad = false,
    this.highlightSelectedValue = true,
    this.decoration,
    this.ismonth = false,
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        assert(step > 0),
        assert(scrollDirection != null),
        selectedIntValue = initialValue,
        selectedDecimalValue = -1,
        decimalPlaces = 0,
        intScrollController = infiniteLoop
            ? new InfiniteScrollController(
                initialScrollOffset:
                    (initialValue - minValue) ~/ step * itemExtent,
              )
            : new ScrollController(
                initialScrollOffset:
                    (initialValue - minValue) ~/ step * itemExtent,
              ),
        decimalScrollController = null,
        listViewHeight = 3 * itemExtent,
        integerItemCount = (maxValue - minValue) ~/ step + 1,
        super(key: key);

  ///constructor for decimal number picker
  NumberPicker.decimal({
    Key key,
    @required double initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.textMapper,
    this.currentDate,
    this.selectedYear,
    this.selectedMonth,
    this.eventDates,
    this.enabled = false,
    this.decimalPlaces = 1,
    this.itemExtent = kDefaultItemExtent,
    this.listViewWidth = kDefaultListViewCrossAxisSize,
    this.numberToDisplay = 3,
    this.highlightSelectedValue = true,
    this.decoration,
    this.ismonth = false,
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(decimalPlaces != null && decimalPlaces > 0),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        selectedIntValue = initialValue.floor(),
        selectedDecimalValue = ((initialValue - initialValue.floorToDouble()) *
                math.pow(10, decimalPlaces))
            .round(),
        intScrollController = new ScrollController(
          initialScrollOffset: (initialValue.floor() - minValue) * itemExtent,
        ),
        decimalScrollController = new ScrollController(
          initialScrollOffset: ((initialValue - initialValue.floorToDouble()) *
                      math.pow(10, decimalPlaces))
                  .roundToDouble() *
              itemExtent,
        ),
        listViewHeight = 3 * itemExtent,
        step = 1,
        scrollDirection = Axis.vertical,
        integerItemCount = maxValue.floor() - minValue.floor() + 1,
        infiniteLoop = false,
        zeroPad = false,
        super(key: key);

  ///called when selected value changes
  final ValueChanged<num> onChanged;

  //enabled
  final bool enabled;

  ///min value user can pick
  final int minValue;

  //whether month picker or year picker
  final bool ismonth;

  //Event Date List
  final List<DateTime> eventDates;

  //current date
  final DateTime currentDate;

  //selected month
  final int selectedMonth;

  //selected year
  final int selectedYear;

  ///max value user can pick
  final int maxValue;

  ///build the text of each item on the picker
  final TextMapper textMapper;

  ///inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  ///height of every list element in pixels
  final double itemExtent;

  ///height of list view in pixels
  final double listViewHeight;

  ///width of list view in pixels
  final double listViewWidth;

  ///number of numbers displayed at any one time
  final int numberToDisplay;

  ///ScrollController used for integer list
  final ScrollController intScrollController;

  ///ScrollController used for decimal list
  final ScrollController decimalScrollController;

  ///Currently selected integer value
  final int selectedIntValue;

  ///Currently selected decimal value
  final int selectedDecimalValue;

  ///If currently selected value should be highlighted
  final bool highlightSelectedValue;

  ///Decoration to apply to central box where the selected value is placed
  final Decoration decoration;

  ///Step between elements. Only for integer datePicker
  ///Examples:
  /// if step is 100 the following elements may be 100, 200, 300...
  /// if min=0, max=6, step=3, then items will be 0, 3 and 6
  /// if min=0, max=5, step=3, then items will be 0 and 3.
  final int step;

  /// Direction of scrolling
  final Axis scrollDirection;

  ///Repeat values infinitely
  final bool infiniteLoop;

  ///Pads displayed integer values up to the length of maxValue
  final bool zeroPad;

  ///Amount of items
  final int integerItemCount;

  //
  //----------------------------- PUBLIC ------------------------------
  //

  /// Used to animate integer number picker to new selected value
  void animateInt(int valueToSelect) {
    int diff = valueToSelect - minValue;
    int index = diff ~/ step;
    animateIntToIndex(index);
  }

  /// Used to animate integer number picker to new selected index
  void animateIntToIndex(int index) {
    //   print("$index");
    _animate(intScrollController, index * itemExtent);
  }

  /// Used to animate decimal part of double value to new selected value
  void animateDecimal(int decimalValue) {
    _animate(decimalScrollController, decimalValue * itemExtent);
  }

  /// Used to animate decimal number picker to selected value
  void animateDecimalAndInteger(double valueToSelect) {
    animateInt(valueToSelect.floor());
    animateDecimal(((valueToSelect - valueToSelect.floorToDouble()) *
            math.pow(10, decimalPlaces))
        .round());
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  ///main widget
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    if (ismonth == true) {
      return _monthListView(themeData);
    } else {
      return _integerListView(themeData);
    }

    /* if (infiniteLoop) {
      return _integerInfiniteListView(themeData);
    }
    if (decimalPlaces == 0) {
      return _integerListView(themeData);
    } else {
      return new Row(
        children: <Widget>[
          _integerListView(themeData),
          _decimalListView(themeData),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } */
  }

  String getJaDayName(String day) {
    switch (day) {
      case 'Monday':
        return '月';
        break;
      case 'Tuesday':
        return '火';
        break;
      case 'Wednesday':
        return '水';
        break;
      case 'Thursday':
        return '木';
        break;
      case 'Friday':
        return '金';
        break;
      case 'Saturday':
        return '土';
        break;
      case 'Sunday':
        return '日';
        break;
    }
  }

  Widget _monthListView(ThemeData themeData) {
    var map = Map();

    eventDates.forEach((element) {
      if (!map.containsKey(element)) {
        map[element] = 1;
      } else {
        map[element] += 1;
      }
    });
    TextStyle defaultStyle =
        TextStyle(color: Colors.black); //themeData.textTheme.bodyText2;
    TextStyle selectedStyle = TextStyle(
        color: enabled ? Colors.black : Color.fromRGBO(217, 217, 217, 1),
        fontSize: 18.0,
        fontWeight: FontWeight.bold);
    //themeData.textTheme.headline5.copyWith(color: themeData.accentColor);

    var listItemCount =
        integerItemCount + numberToDisplay - 1; //3=>2, 7=>6, etc.

    return Listener(
      onPointerUp: (ev) {
        ///used to detect that user stopped scrolling
        if (intScrollController.position.activity is HoldScrollActivity) {
          animateInt(selectedIntValue);
        }
      },
      child: new NotificationListener(
        child: new Container(
          height: listViewHeight,
          width: listViewWidth,
          child: Stack(
            children: <Widget>[
              new ListView.builder(
                physics: enabled
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                scrollDirection: scrollDirection,
                controller: intScrollController,
                itemExtent: itemExtent,
                itemCount: listItemCount,
                cacheExtent: _calculateCacheExtent(listItemCount),
                itemBuilder: (BuildContext context, int index) {
                  //Get Current Selected Day
                  String dayName = DateFormat('EEEE').format(
                      DateTime(selectedYear, selectedMonth, selectedIntValue));
                  //Get Japanese Day Name
                  String jaName = getJaDayName(dayName);
                  final int value = _intValueFromIndex(index);
                  final DateTime dateval =
                      DateTime(selectedYear, selectedMonth, value);
                  int eventCount = 0;
                  eventCount = map[dateval] != null ? map[dateval] : 0;

                  //define special style for selected (middle) element
                  final TextStyle itemStyle =
                      value == selectedIntValue && highlightSelectedValue
                          ? selectedStyle
                          : defaultStyle;

                  bool isExtra = index <= numberToDisplay ~/ 2 - 1 ||
                      index >=
                          listItemCount -
                              (numberToDisplay ~/
                                  2); //index == 0 || index == listItemCount - 1; 7: <=4 and >= 6-5 = 1

                  return isExtra
                      ? new Container() //empty first and last element
                      : value == selectedIntValue && highlightSelectedValue
                          ? Container(
                              padding: EdgeInsets.only(top: 6.0, bottom: 6.0),
                              child: Card(
                                margin: EdgeInsets.all(2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: Center(
                                        child: Text("$jaName",
                                            style: TextStyle(
                                                color: enabled
                                                    ? Colors.black
                                                    : Color.fromRGBO(
                                                        217, 217, 217, 1),
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: CircleAvatar(
                                        radius: 20.0,
                                        backgroundColor: Colors.grey[300],
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white,
                                          child: new Text(
                                            getDisplayedValue(value),
                                            style: itemStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : (value == currentDate.day &&
                                  currentDate.year == selectedYear)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new Text(
                                        getDisplayedValue(value),
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: enabled
                                                ? Colors.black
                                                : Color.fromRGBO(
                                                    217, 217, 217, 1),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      dotBuilder(eventCount),
                                    ],
                                  ),
                                )
                              : (value == (selectedIntValue - 1) ||
                                      value == (selectedIntValue + 1))
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            getDisplayedValue(value),
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: enabled
                                                    ? Colors.black
                                                    : Color.fromRGBO(
                                                        217, 217, 217, 1),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          dotBuilder(eventCount),
                                        ],
                                      ),
                                    )
                                  : (value == (selectedIntValue - 2) ||
                                          value == (selectedIntValue + 2))
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              new Text(
                                                getDisplayedValue(value),
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: enabled
                                                        ? Colors.black
                                                        : Color.fromRGBO(
                                                            217, 217, 217, 1),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              dotBuilder(eventCount),
                                            ],
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              new Text(
                                                getDisplayedValue(value),
                                                style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: enabled
                                                        ? Colors.black
                                                        : Color.fromRGBO(
                                                            217, 217, 217, 1),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              dotBuilder(eventCount),
                                            ],
                                          ),
                                        );
                },
              ),
              _NumberPickerSelectedItemDecoration(
                axis: scrollDirection,
                itemExtent: itemExtent,
                decoration: decoration,
              ),
            ],
          ),
        ),
        onNotification: _onIntegerNotification,
      ),
    );
  }

  dotBuilder(int eventCount) {
    return eventCount == 0
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dotIconBuilder(Colors.white),
            ],
          )
        : eventCount >= 4
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  dotIconBuilder(
                    enabled ? Colors.black : Color.fromRGBO(217, 217, 217, 1),
                  ),
                  dotIconBuilder(
                    enabled ? Colors.black : Color.fromRGBO(217, 217, 217, 1),
                  ),
                  dotIconBuilder(
                    enabled ? Colors.black : Color.fromRGBO(217, 217, 217, 1),
                  ),
                  dotIconBuilder(
                    enabled ? Colors.black : Color.fromRGBO(217, 217, 217, 1),
                  ),
                ],
              )
            : eventCount >= 3
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dotIconBuilder(
                        enabled
                            ? Colors.black
                            : Color.fromRGBO(217, 217, 217, 1),
                      ),
                      dotIconBuilder(
                        enabled
                            ? Colors.black
                            : Color.fromRGBO(217, 217, 217, 1),
                      ),
                      dotIconBuilder(
                        enabled
                            ? Colors.black
                            : Color.fromRGBO(217, 217, 217, 1),
                      ),
                    ],
                  )
                : eventCount >= 2
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          dotIconBuilder(
                            enabled
                                ? Colors.black
                                : Color.fromRGBO(217, 217, 217, 1),
                          ),
                          dotIconBuilder(
                            enabled
                                ? Colors.black
                                : Color.fromRGBO(217, 217, 217, 1),
                          ),
                        ],
                      )
                    : eventCount == 1
                        ? dotIconBuilder(
                            enabled
                                ? Colors.black
                                : Color.fromRGBO(217, 217, 217, 1),
                          )
                        : Container();
  }

  Icon dotIconBuilder(Color color) {
    return Icon(
      Icons.circle,
      size: 5.0,
      color: color,
    );
  }

  Widget _integerListView(ThemeData themeData) {
    TextStyle defaultStyle = TextStyle(
        color: Colors.white70, fontSize: 18.0); //themeData.textTheme.bodyText2;
    TextStyle selectedStyle = TextStyle(
        color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold);
    //themeData.textTheme.headline5.copyWith(color: themeData.accentColor);

    var listItemCount =
        integerItemCount + numberToDisplay - 1; //3=>2, 7=>6, etc.

    return Listener(
      onPointerUp: (ev) {
        ///used to detect that user stopped scrolling
        if (intScrollController.position.activity is HoldScrollActivity) {
          animateInt(selectedIntValue);
        }
      },
      child: new NotificationListener(
        child: new Container(
          height: listViewHeight,
          width: listViewWidth,
          child: Stack(
            children: <Widget>[
              new ListView.builder(
                scrollDirection: scrollDirection,
                controller: intScrollController,
                itemExtent: itemExtent,
                itemCount: listItemCount,
                cacheExtent: _calculateCacheExtent(listItemCount),
                itemBuilder: (BuildContext context, int index) {
                  final int value = _intValueFromIndex(index);

                  //define special style for selected (middle) element

                  bool isExtra = index <= numberToDisplay ~/ 2 - 1 ||
                      index >=
                          listItemCount -
                              (numberToDisplay ~/
                                  2); //index == 0 || index == listItemCount - 1; 7: <=4 and >= 6-5 = 1

                  return isExtra
                      ? new Container() //empty first and last element
                      : value == selectedIntValue && highlightSelectedValue
                          ? Center(
                              child: new Text(
                                getDisplayedValue(value),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : (value == currentDate.year)
                              ? Center(
                                  child: new Text(
                                    getDisplayedValue(value),
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : (value == (selectedIntValue - 1) ||
                                      value == (selectedIntValue + 1))
                                  ? Center(
                                      child: new Text(
                                        getDisplayedValue(value),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white60,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : (value == (selectedIntValue - 2) ||
                                          value == (selectedIntValue + 2))
                                      ? Center(
                                          child: new Text(
                                            getDisplayedValue(value),
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white38,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : Center(
                                          child: new Text(
                                            getDisplayedValue(value),
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white24,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                },
              ),
              _NumberPickerSelectedItemDecoration(
                axis: scrollDirection,
                itemExtent: itemExtent,
                decoration: decoration,
              ),
            ],
          ),
        ),
        onNotification: _onIntegerNotification,
      ),
    );
  }

  String getDisplayedValue(int value) {
    final text = zeroPad
        ? value.toString().padLeft(maxValue.toString().length, '0')
        : value.toString();
    return textMapper != null ? textMapper(text) : text;
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  int _intValueFromIndex(int index) {
    index = index -
        (numberToDisplay ~/ 2); //index--; //for extra elements. 3=>1, 7=>3
    index %= integerItemCount;
    return minValue + index * step;
  }

  bool _onIntegerNotification(Notification notification) {
    if (notification is ScrollNotification) {
      //calculate
      int intIndexOfMiddleElement =
          (notification.metrics.pixels / itemExtent).round();
      if (!infiniteLoop) {
        intIndexOfMiddleElement = intIndexOfMiddleElement.clamp(
            0, integerItemCount - 1); //integerItemCount - numberToDisplay~/2
      }
      int intValueInTheMiddle = _intValueFromIndex(intIndexOfMiddleElement +
          numberToDisplay ~/ 2); //3=> +1, 5=> +2, 7=> +3
      /*  print("index: $intIndexOfMiddleElement");
      print("middle value: $intValueInTheMiddle"); */
      intValueInTheMiddle = _normalizeIntegerMiddleValue(intValueInTheMiddle);
      //  print("normalized middle value: $intValueInTheMiddle");

      if (_userStoppedScrolling(notification, intScrollController)) {
        //center selected value
        animateIntToIndex(intIndexOfMiddleElement);
      }

      //update selection
      if (intValueInTheMiddle != selectedIntValue) {
        num newValue;
        if (decimalPlaces == 0) {
          //return integer value
          newValue = (intValueInTheMiddle);
        } else {
          if (intValueInTheMiddle == maxValue) {
            //if new value is maxValue, then return that value and ignore decimal
            newValue = (intValueInTheMiddle.toDouble());
            animateDecimal(0);
          } else {
            //return integer+decimal
            double decimalPart = _toDecimal(selectedDecimalValue);
            newValue = ((intValueInTheMiddle + decimalPart).toDouble());
          }
        }
        onChanged(newValue);
      }
    }
    return true;
  }

  ///There was a bug, when if there was small integer range, e.g. from 1 to 5,
  ///When user scrolled to the top, whole listview got displayed.
  ///To prevent this we are calculating cacheExtent by our own so it gets smaller if number of items is smaller
  double _calculateCacheExtent(int itemCount) {
    double cacheExtent = 250.0; //default cache extent
    if ((itemCount - 2) * kDefaultItemExtent <= cacheExtent) {
      //(count-2)*50<=250, count<=23
      cacheExtent = ((itemCount - 3) * kDefaultItemExtent);
    }
    return cacheExtent;
  }

  ///When overscroll occurs on iOS,
  ///we can end up with value not in the range between [minValue] and [maxValue]
  ///To avoid going out of range, we change values out of range to border values.
  int _normalizeMiddleValue(int valueInTheMiddle, int min, int max) {
    return math.max(math.min(valueInTheMiddle, max), min);
  }

  int _normalizeIntegerMiddleValue(int integerValueInTheMiddle) {
    //make sure that max is a multiple of step
    int max = (maxValue ~/ step) * step;
    return _normalizeMiddleValue(integerValueInTheMiddle, minValue, max);
  }

  int _normalizeDecimalMiddleValue(int decimalValueInTheMiddle) {
    return _normalizeMiddleValue(
        decimalValueInTheMiddle, 0, math.pow(10, decimalPlaces) - 1);
  }

  ///indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(
    Notification notification,
    ScrollController scrollController,
  ) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  ///converts integer indicator of decimal value to double
  ///e.g. decimalPlaces = 1, value = 4  >>> result = 0.4
  ///     decimalPlaces = 2, value = 12 >>> result = 0.12
  double _toDecimal(int decimalValueAsInteger) {
    return double.parse((decimalValueAsInteger * math.pow(10, -decimalPlaces))
        .toStringAsFixed(decimalPlaces));
  }

  ///scroll to selected value
  _animate(ScrollController scrollController, double value) {
    scrollController.jumpTo(value);
/*
    scrollController.animateTo(value,
        duration: new Duration(seconds: 1), curve: new ElasticOutCurve());
 */
  }
}

class _NumberPickerSelectedItemDecoration extends StatelessWidget {
  final Axis axis;
  final double itemExtent;
  final Decoration decoration;

  const _NumberPickerSelectedItemDecoration(
      {Key key,
      @required this.axis,
      @required this.itemExtent,
      @required this.decoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new IgnorePointer(
        child: new Container(
          width: isVertical ? double.infinity : itemExtent,
          height: isVertical ? itemExtent : double.infinity,
          decoration: decoration,
        ),
      ),
    );
  }

  bool get isVertical => axis == Axis.vertical;
}

///Returns AlertDialog as a Widget so it is designed to be used in showDialog method
class NumberPickerDialog extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialIntegerValue;
  final double initialDoubleValue;
  final int decimalPlaces;
  final Widget title;
  final EdgeInsets titlePadding;
  final Widget confirmWidget;
  final Widget cancelWidget;
  final int step;
  final bool infiniteLoop;
  final bool zeroPad;
  final bool highlightSelectedValue;
  final Decoration decoration;

  ///constructor for integer values
  NumberPickerDialog.integer({
    @required this.minValue,
    @required this.maxValue,
    @required this.initialIntegerValue,
    this.title,
    this.titlePadding,
    this.step = 1,
    this.infiniteLoop = false,
    this.zeroPad = false,
    this.highlightSelectedValue = true,
    this.decoration,
    Widget confirmWidget,
    Widget cancelWidget,
  })  : confirmWidget = confirmWidget ?? new Text("OK"),
        cancelWidget = cancelWidget ?? new Text("CANCEL"),
        decimalPlaces = 0,
        initialDoubleValue = -1.0;

  ///constructor for decimal values
  NumberPickerDialog.decimal({
    @required this.minValue,
    @required this.maxValue,
    @required this.initialDoubleValue,
    this.decimalPlaces = 1,
    this.title,
    this.titlePadding,
    this.highlightSelectedValue = true,
    this.decoration,
    Widget confirmWidget,
    Widget cancelWidget,
  })  : confirmWidget = confirmWidget ?? new Text("OK"),
        cancelWidget = cancelWidget ?? new Text("CANCEL"),
        initialIntegerValue = -1,
        step = 1,
        infiniteLoop = false,
        zeroPad = false;

  @override
  State<NumberPickerDialog> createState() =>
      new _NumberPickerDialogControllerState(
          initialIntegerValue, initialDoubleValue);
}

class _NumberPickerDialogControllerState extends State<NumberPickerDialog> {
  int selectedIntValue;
  double selectedDoubleValue;

  _NumberPickerDialogControllerState(
      this.selectedIntValue, this.selectedDoubleValue);

  void _handleValueChanged(num value) {
    if (value is int) {
      setState(() => selectedIntValue = value);
    } else {
      setState(() => selectedDoubleValue = value);
    }
  }

  NumberPicker _buildNumberPicker() {
    if (widget.decimalPlaces > 0) {
      return new NumberPicker.decimal(
          initialValue: selectedDoubleValue,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          decimalPlaces: widget.decimalPlaces,
          highlightSelectedValue: widget.highlightSelectedValue,
          decoration: widget.decoration,
          onChanged: _handleValueChanged);
    } else {
      return new NumberPicker.integer(
        initialValue: selectedIntValue,
        minValue: widget.minValue,
        maxValue: widget.maxValue,
        step: widget.step,
        infiniteLoop: widget.infiniteLoop,
        zeroPad: widget.zeroPad,
        highlightSelectedValue: widget.highlightSelectedValue,
        decoration: widget.decoration,
        onChanged: _handleValueChanged,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      content: _buildNumberPicker(),
      actions: [
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: widget.cancelWidget,
        ),
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(widget.decimalPlaces > 0
                ? selectedDoubleValue
                : selectedIntValue),
            child: widget.confirmWidget),
      ],
    );
  }
}
