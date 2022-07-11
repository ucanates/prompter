//api'deki verilerin dönüştürüldüğü model
class Theuser {
  final String scroll;
  final String email;
  final String speedFactor;

  const Theuser({
    required this.scroll,
    required this.email,
    required this.speedFactor,
  });
  //map haline gelmiş json verilerini Theuser objesine yerleştiriyor
  factory Theuser.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> scrolljson = json["scroll"];
    Map<String, dynamic> emailjson = json["email"];
    Map<String, dynamic> speedjson = json["speedFactor"];
    return Theuser(
      scroll: scrolljson["stringValue"],
      email: emailjson["stringValue"],
      speedFactor: speedjson["stringValue"],
    );
  }
}
