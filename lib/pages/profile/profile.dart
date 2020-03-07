import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish_driver/helpers/number.dart';
import 'package:for_kish_driver/models/auth.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

part 'profile.g.dart';

class LoginData {
  String firstname = "";
  String lastname = "";
  String firstnameEn = "";
  String lastnameEn = "";
  String mobile = "";
}

@widget
Widget profile(BuildContext context) {
  final auth = Provider.of<Auth>(context);
  final formKey = useMemoized(()=>GlobalKey<FormState>());
  final data = useMemoized(() {
    var data = LoginData();
    data.firstname = auth.driver.firstname;
    data.lastname = auth.driver.lastname;
    data.firstnameEn = auth.driver.firstnameEn;
    data.lastnameEn = auth.driver.lastnameEn;
    data.mobile = auth.driver.mobile;
    return data;
  });
  final error = useState("");

  return Scaffold(
    appBar: AppBar(
      title: Text(translate('menu.profile')),
    ),
    body: Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 100),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.firstname'),
                  prefixIcon: Icon(Icons.person),
                ),
                initialValue: data.firstname,
                keyboardType: TextInputType.text,
                onChanged: (value){
                  data.firstname = value;
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.lastname'),
                  prefixIcon: Icon(Icons.person),
                ),
                initialValue: data.lastname,
                keyboardType: TextInputType.text,
                onChanged: (value){
                  data.lastname = value;
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.firstnameEn'),
                  prefixIcon: Icon(Icons.person),
                ),
                initialValue: data.firstnameEn,
                keyboardType: TextInputType.text,
                onChanged: (value){
                  data.firstnameEn = value;
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.lastnameEn'),
                  prefixIcon: Icon(Icons.person),
                ),
                initialValue: data.lastnameEn,
                keyboardType: TextInputType.text,
                onChanged: (value){
                  data.lastnameEn = value;
                },
                validator: (value){
                  if(value=='') return translate('signup.mandatory');
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: translate('signup.mobile'),
                  prefixIcon: Icon(Icons.call),
                ),
                initialValue: mapNumber(context, data.mobile),
                readOnly: true,
              ),
              SizedBox(height: 48),
              if(error.value.length != 0)
                Text(
                  error.value,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              if(error.value.length != 0)
                SizedBox(height: 16),
              RaisedButton(
                onPressed: () async {
                  if(formKey.currentState.validate()){
                    // final result = await auth.signup(
                    //   firstname: data.firstname,
                    //   lastname: data.lastname,
                    //   mobile: data.mobile,
                    // );
                    // if(result){
                    //   Navigator.pushNamed(context, '/');
                    // }else{
                    //   error.value = translate('signup.failed');
                    // }
                  }
                },
                child: Text(translate('signup.save')),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
