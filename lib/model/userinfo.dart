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
  Future<String> callApi() async {
    //http'ye get isteğini yolluyor kullanıcının tokeniyle giriş yapıyor
    final response = await http.get(
      Uri.parse("https://www.googleapis.com/blogger/v3/blogs/2399953"),
      headers: {
        "authorization":
            'Bearer ya29.A0AVA9y1s2OgMUrlh8Zrd-lwM_IujDzlxec_-HfKfILR99B0gh5lfoCnPv0fE3Wp70H2QFpOUYqEL4doijO6EyAl_InlxT4LqUmYZeSUBERQRcac1yOgEYOF3T5kPxun24sUebPN3LOiSJAYl-BPwFw3Ji-dqhYUNnWUtBVEFTQVRBU0ZRRTY1ZHI4MzJGNXE2MEc3azZKMjU2LU9uUGlaQQ0163',
      },
    );
    if (response.statusCode == 200) {
      // Sunucu 200 OK yanıtı verdiyse,JSON'u parçalıyor.Fields kısmının içindekileri alıyor
      //ve Theuser'ın içindeki metoda map olarak yolluyor

      return response.body;
    } else {
      throw Exception('Failed to load');
    }
  }

  late Future<String> s;
  @override
  void initState() {
    s = callApi();
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
        body: FutureBuilder<String>(
          future: s,
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
                    snapshot.data.toString(),
                    //style: const TextStyle(fontSize: 25, height: 2),
                  ));
                }
            }
          },
        ));
  }
}
