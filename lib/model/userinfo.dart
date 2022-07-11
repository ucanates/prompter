import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_prompter/model/homepage.dart';
import 'package:my_prompter/model/user.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key}) : super(key: key);

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final user = FirebaseAuth.instance.currentUser!;
  late Future<Theuser> theuser;
  Future<Theuser> callApi() async {
    // kullanıcının tokenini alıyor
    final idToken = await user.getIdToken();
    //http'ye get isteğini yolluyor kullanıcının tokeniyle giriş yapıyor
    final response = await http.get(
      Uri.parse(
          "https://firestore.googleapis.com/v1/projects/myprompter-43d22/databases/(default)/documents/users/${user.uid}"),
      headers: {
        "authorization": 'Bearer $idToken',
      },
    );
    if (response.statusCode == 200) {
      // Sunucu 200 OK yanıtı verdiyse,JSON'u parçalıyor.Fields kısmının içindekileri alıyor
      //ve Theuser'ın içindeki metoda map olarak yolluyor
      return Theuser.fromJson(jsonDecode(response.body)["fields"]);
    } else {
      throw Exception('Failed to load');
    }
  }

  @override
  void initState() {
    theuser = callApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: IconButton(
            onPressed: (() {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Homepage()));
            }),
            icon: const Icon(Icons.arrow_back)),
        body: FutureBuilder<Theuser>(
          future: theuser,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: Text('Loading....'));
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(
                      child: Text(
                    'Email: ${snapshot.data!.email}\n Is Scrolling: ${snapshot.data!.scroll}\n Scrolling Speed: ${snapshot.data!.speedFactor}',
                    style: const TextStyle(fontSize: 25, height: 2),
                  ));
                }
            }
          },
        ));
  }
}
