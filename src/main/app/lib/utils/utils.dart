import 'package:app/identity/states/identity.dart';
import 'package:app/main.dart';

String? get serverUrl => getIt.get<IdentityCubit>().state.serverUrl;