import 'package:escape_wild/core/content.dart';
import 'package:escape_wild/core/item.dart';

class Stuff {
  static late Item plasticBottle,
      sticks,
      cutGrass,
      log,
      dryLichen,
      dandelion,
      saveKindlingCartridge,
      sharpStone,
      wasteEmptyCans;

  static void registerAll() {
    Contents.items.addAll([
      plasticBottle = Item.unmergeable("plastic-bottle", mass: 20).asFuel(heatValue: 5.0),
      sticks = Item("sticks").asFuel(
        heatValue: 2.0,
        unit: 100,
      ),
      cutGrass = Item("cut-grass").asFuel(
        heatValue: 4.5,
        unit: 200,
      ),
      log = Item("log").asFuel(
        heatValue: 20.0,
        unit: 500,
      ),
      dryLichen = Item("dry-lichen").asFuel(unit: 10, heatValue: 10.0),
      dandelion = Item("dandelion"),
      //It is said that dandelion boiled with water can relieve some constipation
      saveKindlingCartridge = Item("save-kindling-cartridge"),
      //Put the semi-wet moss or grass into the wooden tube rolled by the bark,
      // and Mars can carry it
      sharpStone = Item("sharp-stone"),
      ///////People's greatest wisdom comes from using tools
      wasteEmptyCans = Item("waste-empty-cans"),
    ]);
  }
}
