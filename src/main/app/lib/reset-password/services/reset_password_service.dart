import 'package:app/base_service.dart';
import 'package:http/http.dart' as http;

class ResetPasswordService extends BaseService {
  @override
  final String url;

  ResetPasswordService(this.url);

  Future<void> setPassword({required String password, required String token}) async {
    final uri = await formatUrl('/reset-password', query: {'token': token});

    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: password);

    processResponse(response);
  }

  Future<void> submitRequest({required String email}) async {
    final uri = await formatUrl('/forgot-password');
    print('email: $email');

    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: email);

    processResponse(response);
  }
}
