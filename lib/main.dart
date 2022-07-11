import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_prompter/bloc/bloc/auth_bloc.dart';
import 'package:my_prompter/model/homepage.dart';
import 'package:my_prompter/model/sign_in.dart';
import 'package:my_prompter/repository/auth_repository.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAdSGm9hXLS60GsfhFaJsw_6jOWuzpcTHU",
        appId: "1:59229151211:android:219bcf36b4b6d252e403ae",
        messagingSenderId: "59229151211",
        projectId: "myprompter-43d22",
        storageBucket: "myprompter-43d22.appspot.com",
        databaseURL:
            "https://myprompter-43d22-default-rtdb.europe-west1.firebasedatabase.app/",
      ),
    );
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: "recaptcha-v3-site-key",
    );
  } catch (e) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(
          // AuthRepository şeklinde bi repository oluşturuyor
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        ),
        child: MaterialApp(
          home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Eğer snapshot'ta kullanıcı verileri varsa, bu kişi zaten oturum açmış demektir. Ana sayfaya yönlendiriyor.
                if (snapshot.hasData) {
                  return const Homepage();
                }
                // Oturum açma sayfasını gösterir.
                return const SignIn();
              }),
        ),
      ),
    );
  }
}
