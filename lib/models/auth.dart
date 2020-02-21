import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:for_kish_driver/helpers/types.dart';
import 'package:for_kish_driver/api/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _authKey = "__auth__";

class Auth with ChangeNotifier {
  bool loaded = false;
  bool loggedin = false;
  bool waitingForCode = false;
  String mobile;
  Driver driver;

  Auth(){
    load();
  }

  void login(String mobile) async{
    this.mobile = mobile;
    try{
      waitingForCode = await requestVerificationCode(mobile);
    }catch(err){
      print(err);
      waitingForCode = false;
    }
    notifyListeners();
    save();
  }

  void relogin() {
    this.loggedin = false;
    this.mobile = "";
    waitingForCode = false;
    notifyListeners();
    save();
  }

  void verify(String code) async{
    try{
      Driver driver = await verifyCode(this.mobile, code);
      if(driver != null){
        this.driver = driver;
        this.waitingForCode = true;
        this.loggedin = true;
      }else{
        this.waitingForCode = false;
        this.loggedin = false;
        this.driver = null;
      }
    }catch(err){
      print(err);
      this.waitingForCode = false;
      this.loggedin = false;
      this.driver = null;
    }
    notifyListeners();
    save();
  }

  Future<void> load() async {
    try{
      final preferences = await SharedPreferences.getInstance();

      if(preferences.containsKey(_authKey)) {
        var map = jsonDecode(preferences.getString(_authKey));

        this.loggedin = map['loggedin'];
        this.waitingForCode = map['waitingForCode'];
        this.mobile = map['mobile'];
        this.driver = map['driver']==null ? null : Driver.fromJson(map['driver']);
      }
    }catch(err){
      print(err);
      this.loggedin = false;
      this.waitingForCode = false;
      this.mobile = null;
      this.driver = null;
    }
    this.loaded = true;
    notifyListeners();
  }

  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_authKey, jsonEncode(this));
  }

  Map<String, dynamic> toJson() =>
    {
      'loggedin': loggedin,
      'waitingForCode': waitingForCode,
      'mobile': mobile,
      'driver': driver?.toJson(),
    };
}