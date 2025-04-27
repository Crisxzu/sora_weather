import 'package:flutter/material.dart';


import '../view/home/home.dart';

class BodyProvider extends ChangeNotifier {
  Widget _body = Container();
  Widget get body => _body;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  double navBarHeight = 0.0;


  BodyProvider(initialBody) {
    _body = initialBody;
  }

  void setBody(Widget value) {
    _body = value;
    notifyListeners();
  }

  Widget _getBodyByIndex(int index) {
    switch (index) {
      case 0:
        return const Home();
      default:
        return Container();
    }
  }


  void setBodyByIndex(int index) {
    _body = _getBodyByIndex(index);
    _selectedIndex = index;
    notifyListeners();
  }

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setNavBarHeight(double value) {
    if(navBarHeight == value) return;
    navBarHeight = value;
    notifyListeners();
  }


  void showToast(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}