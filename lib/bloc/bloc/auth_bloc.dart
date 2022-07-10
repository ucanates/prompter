import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:my_prompter/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  //authrepository objesi oluşturuyor
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(UnAuthenticated()) {
    //Kullanıcı Oturum Açma Düğmesine Bastığında, bunu işlemesi için
    //SignInRequested Olayı AuthBloc'a yollanır ve kullanıcının kimliği doğrulanırsa
    //Authenticated State durumunu yayınlar
    on<SignInRequested>((event, emit) async {
      emit(Loading());
      try {
        await authRepository.signIn(
            email: event.email, password: event.password);
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });
    //Kullanıcı sign up butonuna bastığında,
    //SignUpRequest olayı işlemesi için AuthBloc'a yollanır ve kullanıcının kimliği doğrulanırsa
    //Authenticated durumunu yayınlar
    on<SignUpRequested>((event, emit) async {
      emit(Loading());
      try {
        await authRepository.signUp(
            email: event.email, password: event.password);
        emit(Authenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(UnAuthenticated());
      }
    });

    //Kullanıcı signout butonuna bastığında,
    //SignOutRequested olayı işlemesi için AuthBloc'a yollanır ve
    //UnAuthenticated durumunu yayınlar
    on<SignOutRequested>((event, emit) async {
      emit(Loading());
      await authRepository.signOut();
      emit(UnAuthenticated());
    });
  }
}
