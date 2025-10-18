import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/navigation_service.dart';
import 'shared/services/socket_service.dart';
import 'shared/services/permission_service.dart';
import 'shared/services/streaming_service.dart';
import 'features/socket/presentation/pages/socket_connection_page.dart';

/// Application principale
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService.instance),
        ChangeNotifierProvider(create: (_) => StreamingService.instance),
      ],
      child: MaterialApp(
        title: 'Hackathon App',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        navigatorKey: NavigationService.navigatorKey,
        home: const SocketConnectionPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
