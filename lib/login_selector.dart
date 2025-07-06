import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:projeto/main.dart';
import 'login_mobile.dart';
import 'login_web.dart';

class LoginSelector extends StatelessWidget {
  const LoginSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const LoginWeb() : const LoginMobile();
  }
}