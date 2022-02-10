import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_app_user_flutter/providers/app_state.dart';
import 'package:taxi_app_user_flutter/providers/user.dart';
import 'package:taxi_app_user_flutter/screens/login.dart';
import 'package:taxi_app_user_flutter/screens/splash.dart';
import 'locators/service_locator.dart';
import 'screens/home.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();

  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AppStateProvider>.value(
        value: AppStateProvider(),
      ),
      ChangeNotifierProvider<UserProvider>.value(
        value: UserProvider.initialize(),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Txapita',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_MyAppState();
}

class _MyAppState extends State<MyApp>{
  @override
  void initState() {
    _checkPermissionLocation();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider auth = Provider.of<UserProvider>(context);
    switch (auth.status) {
      case Status.Uninitialized:
        return Splash();
      case Status.Unauthenticated:
      case Status.Authenticating:
        return LoginScreen();
      case Status.Authenticated:
        return MyHomePage(title: '',);
      default:
        return LoginScreen();
    }
  }

  _checkPermissionLocation()async{
    bool serviceEnable;
    LocationPermission locationPermission;

    serviceEnable=await Geolocator.isLocationServiceEnabled();
    if(!serviceEnable){
      print('loii_: Location services are disabled.');
    }

    locationPermission=await Geolocator.checkPermission();
    if(locationPermission==LocationPermission.denied){
      locationPermission= await Geolocator.requestPermission();
      if(locationPermission==LocationPermission.denied){
        print('loii_: Location services are disabled.');
      }
    }

    if(locationPermission==LocationPermission.deniedForever){
      print('loii_: Location permissions are permanently denied, we cannot request permissions.');
    }

  }
}