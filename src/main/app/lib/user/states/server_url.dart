import 'package:app/config/models/config.dart';
import 'package:app/user/services/server_url_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'server_url.freezed.dart';

class ServerUrlCubit extends Cubit<ServerUrlState> {
  ServerUrlCubit(super.initialState);

  void setUrl(String url) {
    emit(state.copyWith(serverUrl: url));
    EasyDebounce.debounce('server-url-change', Duration(milliseconds: 500), () async {
      emit(state.copyWith(loading: true));
      try {
        var service = ServerUrlService(url);
        var config = await service.getConfig();

        emit(state.copyWith(config: config, error: false, loading: false));
      } catch (e) {
        emit(state.copyWith(error: true, loading: false));
      }
    });
  }
}

@freezed
sealed class ServerUrlState with _$ServerUrlState {
  const factory ServerUrlState({
    String? serverUrl,
    @Default(false) bool loading,
    Config? config,
    @Default(false) bool error,
  }) = _ServerUrlState;
}
