import 'package:app/home/state/local_preferences.dart';
import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';

String? get serverUrl => getIt.get<IdentityCubit>().state.serverUrl;

LocalPreferencesState get localPreferences => getIt.get<LocalPreferencesCubit>().state;