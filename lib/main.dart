import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish_driver/helpers/number.dart';
import 'package:for_kish_driver/models/work.dart';
import 'package:for_kish_driver/pages/home.dart';
import 'package:for_kish_driver/pages/login/confirm.dart';
import 'package:for_kish_driver/models/auth.dart';
import 'package:for_kish_driver/pages/login/login.dart';
import 'package:for_kish_driver/pages/profile/profile.dart';
import 'package:for_kish_driver/translate_preferences.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

part 'main.g.dart';

class App{
  static Router router = Router();
}

void defineRoutes(Router router) {
  // router.define("/single_news/:newsId", handler: singleNewsHandler);
}

void main() async {
  defineRoutes(App.router);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'fa',
    supportedLocales: ['fa', 'en'],
    preferences: TranslatePreferences(),
  );

  runApp(LocalizedApp(delegate, MyApp()));
}

@widget
Widget myApp(BuildContext context) {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final localizationDelegate = LocalizedApp.of(context).delegate;
  
  return LocalizationProvider(
    state: LocalizationProvider.of(context).state,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Work>(
          create: (_) => Work(),
          update: (_, auth, work) {
            print('updated');
            if(auth.driver?.id != null){
              work.load(auth.driver.id);
            }
            return work;
          },
        ),
      ],
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        // theme: ThemeData.dark(),
        theme: ThemeData(
          fontFamily: 'Nika',
          // primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.deepPurple,
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.deepPurple,
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          localizationDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        initialRoute: '/',
        routes: forKishRoutes,
        onGenerateRoute: App.router.generator,
        home: Consumer<Auth>(
          builder: (context, auth, _) {
            if(!auth.loaded){
              return Scaffold(body: Container());
            }else if(!auth.loggedin){
              if(!auth.waitingForCode){
                return Scaffold(body: Login());
              }else{
                return Scaffold(body: Confirm());
              }
            }else{
              return TaxiScaffold(body: Home());
            }
          },
        ),
      ),
    ),
  );
}

@widget
Widget taxiScaffold(BuildContext context, { @required Widget body }) {
  return Scaffold(
    // extendBodyBehindAppBar: true,
    drawer: AppDrawer(),
    appBar: AppBar(
      title: Text(translate('app.title')),
      actions: <Widget>[
        RawMaterialButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(0),
          onPressed: (){}, 
          child: Icon(Icons.notifications, size: 20),
        ),
      ],
    ),
    body: body,
  );
}

final Map<String, WidgetBuilder> forKishRoutes = {
  '/profile': (context) => Profile(),
};

@widget
Widget appDrawer(BuildContext context) {
  final auth = Provider.of<Auth>(context);

  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${auth.driver?.firstName ?? ''} ${auth.driver?.lastName ?? ''}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${mapNumber(context, auth.driver?.mobile ?? '')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
          ),
        ),
        ListTile(
          title: Text(translate('menu.profile')),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/profile');
          },
        ),
        ListTile(
          title: Text(translate('menu.logout')),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/');
            auth.relogin();
          },
        ),
        ListTile(
          title: Text(translate('languages.farsi')),
          onTap: () {
            Navigator.pop(context);
            changeLocale(context, 'fa');
          },
        ),
        ListTile(
          title: Text(translate('languages.english')),
          onTap: () {
            Navigator.pop(context);
            changeLocale(context, 'en');
          },
        ),
      ],
    ),
  );
}
