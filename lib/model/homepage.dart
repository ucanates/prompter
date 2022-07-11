import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_prompter/bloc/bloc/auth_bloc.dart';
import 'package:my_prompter/model/sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:my_prompter/model/userinfo.dart';

void main() => runApp(const Homepage());

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  // Bu widget uygulamanın çalıştığı yer.
  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  //firebase kullanıcısı
  final user = FirebaseAuth.instance.currentUser!;
  //sayfanın kayması için scrollcontroller
  ScrollController _scrollController = ScrollController();
  //texfield içindeki yazıyı kontrol etmesi için
  TextEditingController msgController = TextEditingController();
  bool scroll = false;
  //sayfanın hızı
  int speedFactor = 20;
  //firebase database için yer açıyor
  late DatabaseReference ref;
  //firebase storage için referans
  late Reference storageRef;

//firebase storage'ye kullanıcını mail adresini ekliyor
  void addEmail() {
    storageRef.child("E-mail").putString(
          user.email.toString(),
        );
  }

//firebase storage'ye kullanıcını metinini adresini ekliyor
  void addText() {
    storageRef.child("Text").putString(
          msgController.text,
        );
  }

//firebase storage'ye kullanıcını kullanıcı idsini adresini ekliyor
  void addUid() {
    storageRef.child("userid").putString(
          user.uid,
        );
  }

//hem firebase storage hem firebase firestore'a kullanıcını bilgilerini ekliyor
  Future<void> addUser() {
    //firestora kullanıcının koleksiyonunu oluşturuyor
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    addUid();
    addEmail();
    addText();
    // kullanıcı id'nin document yerini gösteriyor
    final userjson = <String, String>{
      "email": user.email.toString(),
      "text": msgController.text,
      "speedFactor": speedFactor.toString(),
      "scroll": scroll.toString(),
    };
    DocumentReference docRef = users.doc(user.uid);
    return docRef
        .set(userjson)
        .then((value) => print("kullanıcı eklendi"))
        .catchError((error) => print("eklenemedi $error"));
  }

//json olarak realtime databaseden bilgileri alıp,
//uygulamanın içindeki değişkenleri güncelliyor
  void updateRef(Map value) {
    if (mounted) {
      speedFactor = value["Speed"];
      msgController.text = value["Text"];

      setState(() {
        scroll = value["Start"];
      });
      //database de anlık kaydırma ne ise aynısı yapsın diye
      _toggleScrolling();
    }
  }

//database'e yeni hızı yazıyor
  void speedUpdate() async {
    await ref.update({"Speed": speedFactor});
  }

//database'e hareket durumunu yazıyor
  void startUpdate() async {
    await ref.update({"Start": scroll});
  }

  @override
  //controllerleri siliyor
  void dispose() {
    _scrollController.dispose();
    msgController.dispose();
    super.dispose();
  }

  @override
  // anasayfa ilk açıldığında database orneği,
  //storage örneği referansı ve listener snaphot oluşturuluyor
  //listener databasedeki değişimlere bakarak,
  // uygulamanın içindeki değişkenleri güncelliyor
  void initState() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    storageRef = FirebaseStorage.instance.ref().child("users").child(user.uid);
    ref = database.ref("users/${user.uid}");
    ref.onValue.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        updateRef(snapshot.value as Map);
      } else {
        print('Veri yok');
      }
    });
    super.initState();
  }

  void uploadJson() {
    final body = {
      "Email": user.email,
      "Text": msgController.text,
      "Speed": speedFactor,
      "Start": scroll
    };
  }

  //ekrandaki pixelleri ve girilen metnin uzunluğunu kullanarak,
  // kaydırma zamanı oluşturup o kadar sürede aşağıya inmesini başaltıyor
  _scroll() {
    double maxExtent = _scrollController.position.maxScrollExtent;
    double distanceDifference = maxExtent - _scrollController.offset;
    double durationDouble = distanceDifference / speedFactor;

    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(seconds: durationDouble.toInt()),
        curve: Curves.linear);
  }

//_scroll methodunu tetikliyor
  _toggleScrolling() {
    if (scroll) {
      _scroll();
    } else {
      _scrollController.animateTo(_scrollController.offset,
          duration: const Duration(seconds: 1), curve: Curves.linear);
    }
  }

  void _signOut(context) {
    BlocProvider.of<AuthBloc>(context).add(
      SignOutRequested(),
    );
  }

// uygulamadaki değişkenleri database'e yüklüyor
  Future<void> database() async {
    await ref.set(
        {"Text": msgController.text, "Start": scroll, "Speed": speedFactor});
  }

// uygulamadaki değişkenleri başlangıçtaki hallerine döndürüyor
  void reset() {
    msgController.clear();
    speedFactor = 20;
    scroll = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Metin"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.accessibility,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => UserInformation()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            // Kullanıcı oturumu kapattığında oturum açma ekranına gider.
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SignIn()),
              (route) => false,
            );
          }
        },
        //ekranı kullanıcı scroll aşamasında eliyle kontrol ederse scroll metodu,
        // tekrardan ekrandaki pixelleri ve metnin uzunluğunu hesaplayarak,
        // süre oluşturuyor
        child: NotificationListener(
          onNotification: (notif) {
            if (notif is ScrollEndNotification && scroll) {
              Timer(Duration(seconds: 1), () {
                _scroll();
              });
            }

            return true;
          },
          //kullanıcı metnini buraya giriyor
          child: SingleChildScrollView(
            controller: _scrollController,
            child: TextField(
              controller: msgController,
              cursorHeight: 10,
              style: const TextStyle(),
              decoration: const InputDecoration(labelText: "Buraya Giriniz"),
              readOnly: false,
              maxLines: 1000,
              minLines: 2,
            ),
          ),
        ),
      ),

      //uygulumayı kontrol etmesi için gerekli butonlar
      bottomNavigationBar: BottomAppBar(
          child: Row(
        children: [
          //kullanıcının yazdığı metni kayıt etmesi için ve
          // aynı zamanda databasi güncelliyor
          IconButton(
              onPressed: (() {
                database();
                addUser();
                //createUser();
              }),
              icon: const Icon(Icons.save)),
          //metnin kaymasını başlatıyor, durduruyor ve aynı zamanda
          // databaseden scroll değişkenini güncelliyor
          IconButton(
              onPressed: (() {
                setState(() {
                  scroll = !scroll;
                });
                _toggleScrolling();
                startUpdate();
              }),
              icon: const Icon(Icons.play_arrow)),
          //uygulamayı başlangıç haline döndürüyor ve database'i güncelliyor
          IconButton(
              onPressed: (() {
                reset();
                database();
              }),
              icon: const Icon(Icons.restart_alt_outlined)),
          //kayma hızını arttırıyor ve databaseden hız değişkenini güncelliyor
          IconButton(
              onPressed: (() {
                speedFactor = speedFactor + 5;
                _toggleScrolling();
                speedUpdate();
              }),
              icon: const Icon(Icons.double_arrow)),
          //kayma hızını azaltıyor ve databaseden hız değişkenini güncelliyor
          IconButton(
              onPressed: (() {
                speedFactor = speedFactor - 5;
                _toggleScrolling();
                speedUpdate();
              }),
              icon: const Icon(Icons.keyboard_double_arrow_left)),
          //kullanıcı çıkış yapıyor
          IconButton(
              onPressed: (() {
                _signOut(context);
              }),
              icon: const Icon(Icons.logout)),
        ],
      )),
    );
  }
}
