import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/crrt_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const CrrtTrainerApp());
}

class CrrtTrainerApp extends StatelessWidget {
  const CrrtTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CrrtState(),
      child: MaterialApp(
        title: 'CRRT Trainer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bgDark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accentBlue,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
          sliderTheme: const SliderThemeData(
            trackHeight: 4,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
