import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:escape_wild/game/items/medicine.dart';
import 'package:escape_wild/game/items/stuff.dart';
import 'package:escape_wild/game/items/tools.dart';
export 'package:escape_wild/game/items/foods.dart';
export 'package:escape_wild/game/items/medicine.dart';
export 'package:escape_wild/game/items/stuff.dart';
export 'package:escape_wild/game/items/tools.dart';
export 'package:escape_wild/utils/random.dart';
export 'package:escape_wild/utils/collection.dart';

final yamlAssetsLoader = YamlAssetLoader();
final isGameContentLoaded = ValueNotifier(false);
var _isGameContentLoaded = false;
var _isL10nLoaded = false;

Future<void> loadGameContent() async {
  // load vanilla
  await Vanilla.instance.load();
  _checkGameLoadState();
}

Future<void> loadL10n() async {
  await Vanilla.instance.loadL10n();
  _checkGameLoadState();
}

void _checkGameLoadState() {
  if (_isGameContentLoaded && _isL10nLoaded) {
    isGameContentLoaded.value = true;
  }
}

Future<void> initPlayer() async {
  await player.init();
}

Future<void> onNewGame() async {
  await player.restart();
}

void loadVanilla() {
  Foods.registerAll();
  Medicines.registerAll();
  Stuff.registerAll();
  Tools.registerAll();
}
