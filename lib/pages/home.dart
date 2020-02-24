import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish_driver/models/work.dart';
import 'package:for_kish_driver/pages/work/ride_page.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';


part 'home.g.dart';

@widget
Widget home(BuildContext context) {

  final activating = useState(false);

  return Consumer<Work>(
    builder: (context, work, _) {
      if(!work.loaded){
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      if(!work.active) {
        return Center(
          child: activating.value ? CircularProgressIndicator() : RaisedButton(
            child: Text(translate('work.activate')),
            onPressed: () async{
              activating.value = true;
              await work.activate();
              activating.value = false;
            },
          ),
        );
      }
      return RidePage();
    }
  );
}