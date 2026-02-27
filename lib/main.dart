import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_plan/api/auth_service.dart';
import 'package:vital_plan/app.dart';

void main(List<String> args) {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: const VitalPlanApp(),
    ),
  );
}
