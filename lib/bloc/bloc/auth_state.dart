part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {}

// Kullanıcı signin veya signup düğmesine bastığında, durum önce loading ve ardından Authenticated olarak değiştirilir.
class Loading extends AuthState {
  @override
  List<Object?> get props => [];
}

// Kullanıcının kimliği doğrulandığında, durum Authenticated olarak değiştirilir.
class Authenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

// Bu bloc'un ilk halidir. Kullanıcının kimliği doğrulanmadığında, durum UnAuthenticated olarak değiştirilir.
class UnAuthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

// Herhangi bir hata oluşursa durum AuthError olarak değiştirilir.
class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
  @override
  List<Object?> get props => [error];
}
