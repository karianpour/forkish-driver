import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish_driver/models/auth.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

part 'login.g.dart';

class LoginData {
  String mobile = "";
}

@widget
Widget login(BuildContext context) {
  final auth = Provider.of<Auth>(context);
  final formKey = useMemoized(()=>GlobalKey<FormState>());
  final data = useMemoized(() => LoginData());

  final locale = LocalizedApp.of(context).delegate.currentLocale.languageCode;

  return Container(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100),
            Image.asset('assets/images/car.png', height: 100,),
            Text(
              translate('login.welcome'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              translate('login.welcome_desc'),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 100),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: translate('login.mobile'),
                  prefixIcon: Icon(Icons.call),
                  hintText: "+989121234567",
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value){
                  data.mobile = value;
                },
              ),
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: (){
                auth.login(data.mobile);
              },
              child: Text(translate('login.login')),
              color: Colors.blue,
              textColor: Colors.white,
            ),
            SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                height: 48,
                child: GestureDetector(
                  onTap: (){
                    if(locale!='fa'){
                      changeLocale(context, 'fa');
                    }else{
                      changeLocale(context, 'en');
                    }
                  },
                  child: Text(
                    translate(locale=='fa' ? 'languages.english': 'languages.farsi'),
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    ),
  );
}