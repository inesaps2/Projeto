import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> login(String email, String password) async {
  final uri = Uri.parse("http://10.0.2.2:3000/api/auth/login");

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Login efetuado com sucesso!");
      print("🔐 Dados do utilizador: ${data['user']}");
    } else {
      final error = jsonDecode(response.body);
      print("❌ Erro no login: ${error['error']}");
    }
  } catch (e) {
    print("🚫 Erro de ligação: $e");
  }
}
