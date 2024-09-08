enum Flavor {
  redCameraRoll,
  redBuiltInCamera,
  greenFilesystem,
  greenCameraRoll,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;

  FlavorConfig({required this.flavor, required this.name});

  static FlavorConfig? _instance;

  static FlavorConfig get instance => _instance!;

  static void init({required FlavorConfig flavorConfig}) {
    _instance = flavorConfig;
  }

  static final redCameraRoll = FlavorConfig(
    flavor: Flavor.redCameraRoll,
    name: 'Red Camera Roll',
  );

  static final redBuiltInCamera = FlavorConfig(
    flavor: Flavor.redBuiltInCamera,
    name: 'Red Built-In Camera',
  );

  static final greenFilesystem = FlavorConfig(
    flavor: Flavor.greenFilesystem,
    name: 'Green Filesystem',
  );

  static final greenCameraRoll = FlavorConfig(
    flavor: Flavor.greenCameraRoll,
    name: 'Green Camera Roll',
  );
}
