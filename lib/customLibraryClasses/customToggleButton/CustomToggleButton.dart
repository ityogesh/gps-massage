//library custom_radio_grouped_button;
import 'package:flutter/material.dart';

class CustomToggleButton extends StatefulWidget {
  CustomToggleButton({
    this.buttonLables,
    this.buttonValues,
    this.fontSize = 20,
    this.autoWidth = true,
    this.radioButtonValue,
    this.buttonColor,
    this.padding = 3,
    this.selectedColor,
    this.height = 0,
    this.width = 0,
    this.horizontal = false,
    this.enableShape = false,
    this.elevation = 0,
    this.customShape,
  })  : assert(buttonLables.length == buttonValues.length),
        assert(buttonColor != null),
        assert(selectedColor != null);

  final bool horizontal;

  final List buttonValues;

  final double height;
  final double width;
  final double padding;

  ///Only applied when in vertical mode
  final bool autoWidth;

  final List<String> buttonLables;

  final double fontSize;

  final Function(dynamic) radioButtonValue;

  final Color selectedColor;

  final Color buttonColor;
  final ShapeBorder customShape;
  final bool enableShape;
  final double elevation;

  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  int currentSelected = 0;
  String currentSelectedLabel;

  @override
  void initState() {
    super.initState();
    currentSelectedLabel = widget.buttonLables[0];
  }

  List<Widget> buildButtonsColumn() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLables.length; index++) {
      var button = Padding(
        padding: EdgeInsets.all(widget.padding),
        child: Card(
          color: currentSelectedLabel == widget.buttonLables[index]
              ? widget.selectedColor
              : widget.buttonColor,
          elevation: widget.elevation,
          shape: widget.enableShape
              ? widget.customShape == null
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    )
                  : widget.customShape
              : null,
          child: Container(
            height: widget.height,
            width: widget.width,
            child: MaterialButton(
              shape: widget.enableShape
                  ? widget.customShape == null
                      ? OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey[100], width: 0.0),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        )
                      : widget.customShape
                  : OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey[100], width: 0.0),
                      borderRadius: BorderRadius.zero,
                    ),
              onPressed: () {
                widget.radioButtonValue(widget.buttonValues[index]);
                setState(() {
                  currentSelected = index;
                  currentSelectedLabel = widget.buttonLables[index];
                });
              },
              child: Text(
                widget.buttonLables[index],
                style: TextStyle(
                    color: currentSelectedLabel == widget.buttonLables[index]
                        ? Color.fromRGBO(255, 255, 255, 1)
                        : Color.fromRGBO(255, 255, 255, 1),
                    fontSize: widget.fontSize,
                    fontFamily: 'Oxygen',
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  List<Widget> buildButtonsRow() {
    List<Widget> buttons = [];
    for (int index = 0; index < widget.buttonLables.length; index++) {
      var button = Card(
        color: currentSelectedLabel == widget.buttonLables[index]
            ? widget.selectedColor
            : widget.buttonColor,
        elevation: widget.elevation,
        shape: widget.enableShape
            ? widget.customShape == null
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  )
                : widget.customShape
            : null,
        child: Container(
          height: widget.height,
          width: widget.autoWidth ? null : widget.width,
          constraints: BoxConstraints(maxWidth: 250),
          child: MaterialButton(
            shape: widget.enableShape
                ? widget.customShape == null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      )
                    : widget.customShape
                : OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
            onPressed: () {
              widget.radioButtonValue(widget.buttonValues[index]);
              setState(() {
                currentSelected = index;
                currentSelectedLabel = widget.buttonLables[index];
              });
            },
            child: Text(
              widget.buttonLables[index],
              style: TextStyle(
                  color: currentSelectedLabel == widget.buttonLables[index]
                      ? Color.fromRGBO(255, 255, 255, 1)
                      : Color.fromRGBO(255, 255, 255, 1),
                  fontSize: widget.fontSize,
                  fontFamily: 'Oxygen',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
      buttons.add(button);
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.horizontal
          ? widget.height * (widget.buttonLables.length * 1.5) +
              widget.padding * 2 * widget.buttonLables.length
          : widget.height + widget.padding * 2,
      child: Center(
        child: widget.horizontal
            ? ListView(
                scrollDirection: Axis.vertical,
                children: buildButtonsRow() //buildButtonsRow,
                )
            : ListView(
                scrollDirection: Axis.horizontal,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildButtonsColumn(),
              ),
      ),
    );
  }
}
