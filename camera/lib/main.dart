import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration des services
  await setupServiceLocator();
  
  runApp(const MyApp());
}
