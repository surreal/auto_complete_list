import 'dart:developer';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CitiesACIWidget extends StatefulWidget {
  final Function(int? cityPosition) _func;
  final Function(FocusNode)? setFocusNode;
  const CitiesACIWidget(this._func, {super.key, this.setFocusNode});

  @override
  // ignore: library_private_types_in_public_api
  _CitiesACWidget createState() => _CitiesACWidget();
}

class _CitiesACWidget extends State<CitiesACIWidget> {
  GlobalKey<AutoCompleteTextFieldState<String>> keyACTV = GlobalKey();
  final String _tagCheckCities = 'tagCheckCities -> ';

  String? _inputTxt;
  List<String>? _citiesList;
  FocusNode? _focusNode;

  final TextEditingController _controller = TextEditingController();
  int? _cityPosition;
  late final SimpleAutoCompleteTextField _inputWidget;

  @override
  void initState() {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.setFocusNode != null) {
        widget.setFocusNode!(_focusNode!);
      }
    });
    _focusNode!.addListener(
      () {
        if (_focusNode!.hasFocus) {
          log('$_tagCheckCities focusNode.addListener() focused');
          _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
        } else {
          log('$_tagCheckCities focusNode.addListener() not focused');
        }
      },
    );

    getCsvFileData('assets/csv/cities_in_israel_he.csv').then((value) {
      _citiesList = value.toString().split('\n');
      _inputWidget = SimpleAutoCompleteTextField(
        key: keyACTV,
        controller: _controller,
        suggestions: _citiesList!,
        cursorColor: Colors.blue,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          labelStyle: TextStyle(color: Colors.grey),
          labelText: 'insert city select from list',
          // hintText: insert_city_select_from_list.i18n(),
          // border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 3),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 3),
          ),
          contentPadding: EdgeInsets.all(0),
        ),
        textChanged: (text) {
          _inputTxt = text;
          _cityPosition = _citiesList!.contains(text) ? _citiesList!.indexOf(text) : null;
          widget._func(_cityPosition);
          log('$_tagCheckCities textChanged(): $_inputTxt; cityPosition: $_cityPosition; citiesList!.contains(text): ${_citiesList!.contains(text)}');
          _inputWidget.updateDecoration(
              decoration: InputDecoration(
                  errorText: text.isEmpty
                      ? 'cant be empty'
                      : !_citiesList!.contains(text)
                          ? 'city not in list'
                          : null));
          widget.createElement();
        },
        clearOnSubmit: false,
        submitOnSuggestionTap: true,
        textSubmitted: (text) => {
          _inputTxt = text,
          _cityPosition = _citiesList!.indexOf(text),
          _inputWidget.updateDecoration(decoration: const InputDecoration(errorText: null)),
          widget._func(_cityPosition),
          log('$_tagCheckCities textSubmitted() == $text'),
        },
      );
      setState(() {});
      log('$_tagCheckCities _CitiesACWidget() citiesList: ${_citiesList!.length}');
    });
    super.initState();
  }

  Future<String> getCsvFileData(String filePath) async {
    final myData = await rootBundle.loadString(filePath);
    log('checkCSVFile -> readCsv() -> rows.length == ${myData.split('\n').length}; filePath == $filePath');
    return myData;
  }

  @override
  Widget build(BuildContext context) {
    return _citiesList != null ? _inputWidget : const TextField();
  }
}
