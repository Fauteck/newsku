import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleCubit<T> extends Cubit<T> {
  SimpleCubit(super.initialState);

  void setValue(T value) {
    emit(value);
  }
}
