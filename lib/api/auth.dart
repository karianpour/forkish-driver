import 'package:for_kish_driver/helpers/types.dart';

Future<bool> requestVerificationCode(String mobile) async {
  await Future.delayed(Duration(milliseconds: 200));
  return true;
}

Future<Driver> verifyCode(String mobile, String code) async {
  await Future.delayed(Duration(milliseconds: 200));
  if(code == '1234'){
    return Driver(
      id: '4321-1234',
      firstName: 'کیوان',
      lastName: 'آرین‌پور',
      firstNameEn: 'Kayvan',
      lastNameEn: 'Arianpour',
      mobile: '09121161998',
      photoUrl: '',
    );
  }
  return null;
}