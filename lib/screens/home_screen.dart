import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/home_bloc.dart';
import '../blocs/home_event.dart';
import '../widgets/result_tile.dart';
import '../blocs/home_state.dart';
import '../flavor_config.dart'; // Import FlavorConfig

class HomeScreen extends StatelessWidget {
  final String flavor;

  HomeScreen({required this.flavor});

  void _showStorageOptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: BlocProvider.of<HomeBloc>(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Storage Option:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                RadioListTile<String>(
                  title: const Text('File System'),
                  value: 'file',
                  groupValue: context.read<HomeBloc>().storageOption,
                  onChanged: (String? value) {
                    if (value != null) {
                      BlocProvider.of<HomeBloc>(context).add(
                        ChangeStorageOption(value),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
                // Tampilkan opsi "Database" kecuali di flavor greenFilesystem
                if (FlavorConfig.instance.flavor != Flavor.greenFilesystem)
                  RadioListTile<String>(
                    title: const Text('Database'),
                    value: 'database',
                    groupValue: context.read<HomeBloc>().storageOption,
                    onChanged: (String? value) {
                      if (value != null) {
                        BlocProvider.of<HomeBloc>(context).add(
                          ChangeStorageOption(value),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the theme set by the flavor
    final backgroundColor =
        theme.scaffoldBackgroundColor; // Background from theme
    final appBarColor =
        theme.appBarTheme.backgroundColor; // AppBar color from theme
    final fabColor =
        theme.floatingActionButtonTheme.backgroundColor; // FAB color from theme
    final textStyle = theme.textTheme.bodyLarge; // Text style from theme

    return Scaffold(
      appBar: AppBar(
        title: Text(FlavorConfig.instance.flavor.toString().split('.').last),
        backgroundColor: appBarColor, // AppBar color from theme
      ),
      backgroundColor: backgroundColor, // Background color from theme
      body: Column(
        children: [
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeLoaded) {
                if (state.results.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'No data found.',
                        style: textStyle?.copyWith(
                            color:
                                theme.primaryColorDark), // Adjusted text style
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      return ResultTile(result: state.results[index]);
                    },
                  ),
                );
              } else if (state is HomeError) {
                return Center(
                  child: Text(
                    state.message,
                    style: textStyle?.copyWith(
                        color: theme.colorScheme.error), // Error text style
                  ),
                );
              } else {
                return const Center(child: Text('No data available.'));
              }
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (FlavorConfig.instance.flavor == Flavor.redBuiltInCamera ||
              FlavorConfig.instance.flavor == Flavor.greenFilesystem)
            FloatingActionButton(
              backgroundColor:
                  fabColor, // Floating action button color from theme
              onPressed: () {
                BlocProvider.of<HomeBloc>(context)
                    .add(PickImage(ImageSource.camera, context));
              },
              heroTag: 'camera',
              child: const Icon(Icons.camera),
            ),
          const SizedBox(height: 16),
          if (FlavorConfig.instance.flavor == Flavor.redCameraRoll ||
              FlavorConfig.instance.flavor == Flavor.greenCameraRoll ||
              FlavorConfig.instance.flavor == Flavor.greenFilesystem)
            FloatingActionButton(
              backgroundColor:
                  fabColor, // Floating action button color from theme
              onPressed: () {
                BlocProvider.of<HomeBloc>(context)
                    .add(PickImage(ImageSource.gallery, context));
              },
              heroTag: 'gallery',
              child: const Icon(Icons.photo_library),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor:
                fabColor, // Floating action button color from theme
            onPressed: () {
              _showStorageOptionSheet(context);
            },
            heroTag: 'storageOption',
            child: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
