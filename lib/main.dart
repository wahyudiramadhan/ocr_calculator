import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/home_bloc.dart';
import 'flavor_config.dart';
import 'repositories/result_repository.dart';
import 'screens/home_screen.dart';

void main() {
  final resultRepository = ResultRepository();

  // Determine flavor from the environment variable (FLAVOR)
  const flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'greenFilesystem');

  // Initialize flavor configuration based on environment
  FlavorConfig.init(
    flavorConfig: _getFlavorConfig(flavor),
  );

  runApp(MyApp(resultRepository: resultRepository));
}

// Helper function to map the flavor string to a FlavorConfig
FlavorConfig _getFlavorConfig(String flavor) {
  switch (flavor) {
    case 'redCameraRoll':
      return FlavorConfig.redCameraRoll;
    case 'redBuiltInCamera':
      return FlavorConfig.redBuiltInCamera;
    case 'greenFilesystem':
      return FlavorConfig.greenFilesystem;
    case 'greenCameraRoll':
      return FlavorConfig.greenCameraRoll;
    default:
      // Log or print to detect if an unexpected flavor is used
      print('Unknown flavor: $flavor. Using greenFilesystem as default.');
      return FlavorConfig.greenFilesystem;
  }
}

class MyApp extends StatelessWidget {
  final ResultRepository resultRepository;

  const MyApp({super.key, required this.resultRepository});

  @override
  Widget build(BuildContext context) {
    // Setup theme based on the flavor
    ThemeData theme;
    switch (FlavorConfig.instance.flavor) {
      case Flavor.redCameraRoll:
      case Flavor.redBuiltInCamera:
        theme = ThemeData(
          primaryColor: const Color(0xFFD32F2F), // Deeper red for primary color
          buttonTheme: const ButtonThemeData(
            buttonColor: Color(0xFFF44336), // Lighter red for button color
            textTheme: ButtonTextTheme.primary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFD32F2F), // Matching AppBar color
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red)
              .copyWith(
                  secondary:
                      const Color(0xFFFF8A80)), // Lighter red for accents
        );
        break;
      case Flavor.greenFilesystem:
      case Flavor.greenCameraRoll:
        theme = ThemeData(
          primaryColor: const Color(0xFF388E3C), // Rich green for primary color
          buttonTheme: const ButtonThemeData(
            buttonColor: Color(0xFF66BB6A), // Lighter green for buttons
            textTheme: ButtonTextTheme.primary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF388E3C), // Matching AppBar color
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
              .copyWith(
                  secondary:
                      const Color(0xFF81C784)), // Lighter green for accents
        );
        break;
    }

    return MaterialApp(
      title: 'Image to Result Calculator',
      theme: theme,
      home: BlocProvider(
        create: (context) => HomeBloc(resultRepository),
        child: HomeScreen(flavor: FlavorConfig.instance.name),
      ),
    );
  }
}
