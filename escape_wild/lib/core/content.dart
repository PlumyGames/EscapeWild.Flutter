import 'package:escape_wild/core.dart';

class Contents {
  Contents._();

  static final items = ItemContents();
  static final mods = ModContents();
  static final craftRecipes = CraftRecipeContents();
  static final foodRecipes = FoodRecipeContents();
  static final hardness = HardnessContents();

  static Item getItemMetaByName(String name) {
    return items[name] ?? Item.empty;
  }

  static ModProtocol? getModById(String modId) {
    if (modId == Vanilla.instance.modId) return Vanilla.instance;
    return mods[modId];
  }

  static List<CraftRecipeProtocol> getCraftRecipesByCat(CraftRecipeCat cat) {
    return craftRecipes[cat] ?? const [];
  }

  static Hardness getHardnessByName(String name) {
    return hardness[name] ?? Hardness.normal;
  }

  static final Map<ItemMatcher, List<Item>> _matcher2Items = {};

  static List<Item> getMatchedItems(ItemMatcher matcher) {
    var items = _matcher2Items[matcher];
    if (items != null) return items;
    items = matcher.filterTypeMatchedItems(Contents.items.name2Item.values).toList();
    return _matcher2Items[matcher] = items;
  }
}

class ItemContents {
  Map<String, Item> name2Item = {};
}

extension ItemContentsX on ItemContents {
  Item? operator [](String name) => name2Item[name];

  void operator <<(Item item) => name2Item[item.registerName] = item;

  void addAll(Iterable<Item> items) {
    for (final item in items) {
      this << item;
    }
  }

  List<Item> toList() => name2Item.values.toList();
}

class ModContents {
  Map<String, ModProtocol> modId2Mod = {};
}

extension ModContentsX on ModContents {
  ModProtocol? operator [](String name) => modId2Mod[name];
}

class CraftRecipeContents {
  Map<CraftRecipeCat, List<CraftRecipeProtocol>> cat2Recipes = {};
  Map<String, CraftRecipeProtocol> name2Recipe = {};
}

extension CraftRecipeContentsX on CraftRecipeContents {
  List<CraftRecipeProtocol>? operator [](CraftRecipeCat cat) => cat2Recipes[cat];

  void operator <<(CraftRecipeProtocol recipe) {
    name2Recipe[recipe.registerName] = recipe;
    var list = cat2Recipes[recipe.cat];
    if (list == null) {
      list = <CraftRecipeProtocol>[];
      cat2Recipes[recipe.cat] = list;
    }
    list.add(recipe);
  }

  void addAll(Iterable<CraftRecipeProtocol> recipes) {
    for (final recipe in recipes) {
      this << recipe;
    }
  }
}

class HardnessContents {
  Map<String, Hardness> name2Hardness = {};
}

extension HardnessContentsX on HardnessContents {
  Hardness? operator [](String name) => name2Hardness[name];

  void operator <<(Hardness hardness) => name2Hardness[hardness.registerName] = hardness;

  void addAll(Iterable<Hardness> hardnessList) {
    for (final hardness in hardnessList) {
      this << hardness;
    }
  }
}

class ItemPoolContents {
  Map<String, ItemPool> name2Pool = {};
}

extension ItemPoolContentsX on ItemPoolContents {
  ItemPool? operator [](String name) => name2Pool[name];

  void operator <<(ItemPool pool) => name2Pool[pool.registerName] = pool;

  void addAll(Iterable<ItemPool> poolList) {
    for (final name2Pool in poolList) {
      this << name2Pool;
    }
  }
}

class FoodRecipeContents {
  Map<String, CookRecipeProtocol> name2FoodRecipe = {};
}

extension FoodRecipeContentsX on FoodRecipeContents {
  CookRecipeProtocol? operator [](String name) => name2FoodRecipe[name];

  void operator <<(CookRecipeProtocol recipe) => name2FoodRecipe[recipe.registerName] = recipe;

  void addAll(Iterable<CookRecipeProtocol> recipes) {
    for (final recipe in recipes) {
      this << recipe;
    }
  }
}
