import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

part 'confirm.g.dart';

@widget
Widget confirm(BuildContext context, {ValueNotifier<bool> page}) {
  // final key = use;
  final mobileNumber = "+989121161998";

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
              translate('login.confirm_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox.fromSize(size: Size.fromHeight(16)),
            Text(
              translate('login.confirm_statement'),
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.8,
              ),
            ),
            SizedBox.fromSize(size: Size.fromHeight(48)),
            Text(
              translate('login.resend_code_after'),
              textAlign: TextAlign.center,
            ),
            SizedBox.fromSize(size: Size.fromHeight(8)),
            Counter(),
            SizedBox.fromSize(size: Size.fromHeight(24)),
            // TextFormField(
            //   textDirection: TextDirection.ltr,
            //   decoration: InputDecoration(
            //     prefixIcon: Icon(Icons.lock),
            //     hintText: "1234",
            //   ),
            //   keyboardType: TextInputType.number,
            // ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                // width: 120,
                // constraints: BoxConstraints(
                //   maxWidth: 100,
                // ),
                child: PinCodeTextField(
                  length: 4,
                  autoFocus: true,
                  backgroundColor: Colors.white12,
                  textInputType: TextInputType.number,
                  obsecureText: false,
                  animationType: AnimationType.fade,
                  shape: PinCodeFieldShape.underline,
                  animationDuration: Duration(milliseconds: 50),
                  // borderRadius: BorderRadius.circular(5),
                  fieldHeight: 40,
                  fieldWidth: 30,
                  onChanged: (value) {
                  //   setState(() {
                  //     currentText = value;
                    // });
                  },
                ),
              ),
            ),
            SizedBox.fromSize(size: Size.fromHeight(16)),
            Text(
              translate('login.mobile_alert', args: {"mobile": mobileNumber}),
              textAlign: TextAlign.center,
            ),
            SizedBox.fromSize(size: Size.fromHeight(8)),
            Align(
              child: Container(
                height: 48,
                child: GestureDetector(
                  onTap: (){
                    page.value = false;
                  },
                  child: Text(
                    translate('login.change_number'),
                    // textAlign: TextAlignVertical.bottom,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox.fromSize(size: Size.fromHeight(0)),
            RaisedButton(
              onPressed: (){},
              child: Text(translate('login.confirm')),
              color: Colors.blue,
              textColor: Colors.white,
            ),
            SizedBox.fromSize(size: Size.fromHeight(50)),
          ],
        ),
      ),
    ),
  );
}

@widget
Widget counter(BuildContext context) {
  final seconds = useState(0);
  final minutes = useState(3);

  
  return Text(
    '01:49',
    textAlign: TextAlign.center,
  );
}
