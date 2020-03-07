import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:for_kish_driver/helpers/types.dart';

import 'backend_address.dart';

Future<bool> requestVerificationCode(String mobile) async {
  // await Future.delayed(Duration(milliseconds: 200));
  // return true;

  var url ='$baseUrl/driver/send_activation';

  Map data = {
    'mobile': mobile,
  };
  var body = jsonEncode(data);

  var response = await http.post(url,
    headers: {"Content-Type": "application/json"},
    body: body
  );
  print("${response.statusCode}");
  print("${response.body}");
  if(response.statusCode==200){
    var responseJson = jsonDecode(response.body);
    var succeed = responseJson['succeed'];
    if(succeed != null && succeed is bool && succeed){
      return true;
    }
  }
  return false;
}

class VerificationResponse {
  Driver driver;
  String token;

  VerificationResponse({this.driver, this.token});
}

Future<VerificationResponse> verifyCode(String mobile, String code) async {
  // await Future.delayed(Duration(milliseconds: 200));
  // if(code == '1234'){
  //   return Driver(
  //     id: '4321-1234',
  //     firstname: 'کیوان',
  //     lastname: 'آرین‌پور',
  //     firstnameEn: 'Kayvan',
  //     lastnameEn: 'Arianpour',
  //     mobile: '09121161998',
  //     photoUrl: '',
  //   );
  // }
  // return null;

  var url ='$baseUrl/driver/verify_activation';

  Map data = {
    'mobile': mobile,
    'code': code,
  };
  var body = jsonEncode(data);

  var response = await http.post(url,
    headers: {"Content-Type": "application/json"},
    body: body
  );
  print("${response.statusCode}");
  print("${response.body}");
  if(response.statusCode==200){
    var responseJson = jsonDecode(response.body);
    if(responseJson != null){
      var driver = Driver.fromJson(responseJson);
      var token = responseJson['token'];
      return VerificationResponse(driver: driver, token: token);
    }
  }
  return null;
}