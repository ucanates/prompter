import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_prompter/bloc/bloc/auth_bloc.dart';
import 'package:my_prompter/model/homepage.dart';
import 'package:my_prompter/model/sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  //email ve şifre controllerleri siliyor
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

//şifreyi gizlemek için
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt"),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Kullanıcının kimliği doğrulanmışsa anasayfaya  yönlendiriyor
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Homepage(),
              ),
            );
          }
          if (state is AuthError) {
            // Kullanıcının kimliği doğrulanmadıysa hata mesajı gösteriyor
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is Loading) {
            // Kullanıcı kaydolurken yükleme göstergesinin gösteriyor
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UnAuthenticated) {
            // Kullanıcının kimliği doğrulanmamışsa kayıt formunu gösteriyor
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Kayıt Olun",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: "E-posta",
                                  border: OutlineInputBorder(),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  return value != null &&
                                          !EmailValidator.validate(value)
                                      ? "Geçerli bir e-posta giriniz."
                                      : null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                obscureText: _obscureText,
                                autocorrect: false,
                                enableSuggestions: false,
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  hintText: "Şifre",
                                  border: OutlineInputBorder(),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  return value != null && value.length < 6
                                      ? "Min. 6 karakter giriniz"
                                      : null;
                                },
                              ),
                              SizedBox(
                                child: FlatButton(
                                  onPressed: _toggle,
                                  child: const Text("Şifreyi Göster"),
                                  color: Colors.grey,
                                ),
                                height: 15,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _createAccountWithEmailAndPassword(context);
                                  },
                                  child: const Text("Kayıt Ol"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const Text("Zaten hesabınız var mı?"),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignIn()),
                          );
                        },
                        child: const Text("Giriş Yap"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

//email ve şifreyle kayıt olması için method
  void _createAccountWithEmailAndPassword(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignUpRequested(
          _emailController.text,
          _passwordController.text,
        ),
      );
    }
  }
}
