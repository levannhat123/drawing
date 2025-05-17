import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void startSplashAnimation() async {
    emit(SplashLoading());
    await Future.delayed(
        const Duration(seconds: 3)); // Simulate delay for splash screen
    emit(SplashCompleted());
  }
}
