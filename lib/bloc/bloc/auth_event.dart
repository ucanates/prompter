part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Kullanıcı e-posta ve parola ile oturum açtığında bu olay çağrılır ve
// kullanıcıda oturum açmak için [AuthRepository] çağrılır
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

//Kullanıcı e-posta ve şifre ile kaydolduğunda bu olay çağrılır ve kullanıcıyı kaydetmek için [AuthRepository] çağrılır
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested(this.email, this.password);
}

// Kullanıcı çıkış yaptığında bu olay çağırılır ve kullanıcının oturumunu kapatmak için [AuthRepository] çağrılır
class SignOutRequested extends AuthEvent {}
