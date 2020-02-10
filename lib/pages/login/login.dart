import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';

import 'confirm.dart';

part 'login.g.dart';

@widget
Widget loginManager(BuildContext context) {
  final page = useState(false);
  return !page.value ? 
    Login(page: page)
    :
    Confirm(page: page)
    ;
}

@widget
Widget login(BuildContext context, {ValueNotifier<bool> page}) {
  // final key = use;
  final locale = LocalizedApp.of(context).delegate.currentLocale.languageCode;

  return Container(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Form(
      // key: form,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox.fromSize(size: Size.fromHeight(100)),
            Image.asset('assets/images/car.png', height: 100,),
            Text(
              translate('login.welcome'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox.fromSize(size: Size.fromHeight(16)),
            Text(
              translate('login.welcome_desc'),
              textAlign: TextAlign.center,
            ),
            SizedBox.fromSize(size: Size.fromHeight(100)),
            TextFormField(
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: translate('login.mobile'),
                prefixIcon: Icon(Icons.call),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox.fromSize(size: Size.fromHeight(20)),
            RaisedButton(
              onPressed: (){
                page.value = true;
              },
              child: Text(translate('login.login')),
              color: Colors.blue,
              textColor: Colors.white,
            ),
            SizedBox.fromSize(size: Size.fromHeight(20)),
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
            SizedBox.fromSize(size: Size.fromHeight(50)),
          ],
        ),
      ),
    ),
  );
}