import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:noitcelloc/noitcelloc.dart';

part 'backpack.g.dart';

@JsonSerializable()
class Backpack extends Iterable<ItemStack> with ChangeNotifier implements JConvertibleProtocol {
  /// [tracked] is an annotation to declare [ItemStack] or its list is tracked by [Backpack].
  /// For example, those items come from [Backpack.items].
  ///
  /// You should change [ItemStack]'s with [Backpack].
  static const tracked = Object();

  /// [untracked] is an annotation to declare [ItemStack] or its list is untracked by [Backpack].
  /// For example, those items are on campfire.
  ///
  /// You can safely change [ItemStack]'s state.
  static const untracked = Object();
  @JsonKey()
  List<ItemStack> items = [];
  @JsonKey()
  int _mass = 0;

  int get mass => _mass;

  set mass(int m) {
    _mass = m;
    if (kDebugMode) {
      final sum = sumMass();
      assert(sum == mass, "Sum[$sum] != State[$mass]");
    }
  }

  Backpack();

  void loadFrom(Backpack source) {
    items = source.items;
    mass = source.mass;
    notifyListeners();
  }

  void clear() {
    items.clear();
    mass = 0;
    notifyListeners();
  }

  factory Backpack.fromJson(Map<String, dynamic> json) => _$BackpackFromJson(json);

  Map<String, dynamic> toJson() => _$BackpackToJson(this);

  /// Return the part of [item].
  /// - If the [item] is unmergeable, [ItemStack.empty] will be returned.
  /// - If the [massOfPart] is more than or equal to [item.mass],
  ///   the [item] will be removed in backpack, and [item] itself will be returned.
  /// - If the [massOfPart] is less than 0, the [ItemStack.empty] will be returned.
  ItemStack splitItemInBackpack(ItemStack item, int massOfPart) {
    assert(item.meta.mergeable, "${item.meta.name} can't split, because it's unmergeable");
    if (!item.meta.mergeable) return ItemStack.empty;
    final actualMass = item.stackMass;
    if (massOfPart <= 0) {
      return ItemStack.empty;
    }
    if (massOfPart >= actualMass) {
      final part = item.clone();
      removeStack(item);
      return part;
    } else {
      final part = item.split(massOfPart);
      if (part.isNotEmpty) {
        mass -= massOfPart;
        notifyListeners();
      }
      return part;
    }
  }

  void consumeItemInBackpack(ItemStack item, int? mass) {
    if (mass != null) {
      splitItemInBackpack(item, mass);
    } else {
      removeStack(item);
    }
  }

  void addItemsOrMergeAll(Iterable<ItemStack> addition) {
    var addedOrMerged = false;
    for (final item in addition) {
      addedOrMerged |= _addItemOrMerge(item);
    }
    if (addedOrMerged) {
      notifyListeners();
    }
  }

  void addItemOrMerge(ItemStack item) {
    if (_addItemOrMerge(item)) {
      notifyListeners();
    }
  }

  /// It will remove the [stack] in backpack, and won't change [stack]'s state.
  bool removeStack(ItemStack stack) {
    if (stack.isEmpty) return true;
    final removedMass = stack.stackMass;
    stack.mass = 0;
    final hasRemoved = items.remove(stack);
    if (hasRemoved) {
      mass -= removedMass;
      notifyListeners();
    }
    return hasRemoved;
  }

  int indexOfStack(ItemStack? stack) {
    if (stack == null) return -1;
    if (stack.isEmpty) return -1;
    return items.indexOf(stack);
  }

  /// It will directly change the mass of item and track [Backpack.mass] without calling [ItemComp.onSplit],
  /// It won't update the components.
  void changeMass(ItemStack item, int newMass) {
    assert(item.meta.mergeable, "mass of unmergeable can't be changed");
    if (!item.meta.mergeable) return;
    if (newMass <= 0) {
      removeStack(item);
    } else {
      final delta = item.stackMass - newMass;
      item.mass = newMass;
      mass -= delta;
      notifyListeners();
    }
  }

  void removeEmptyOrBrokenStacks() {
    final toRemoved = <ItemStack>[];
    for (final stack in items) {
      if (stack.isEmpty || DurabilityComp.tryGetIsBroken(stack)) {
        toRemoved.add(stack);
      }
    }
    for (final removed in toRemoved) {
      removeStack(removed);
    }
  }

  void validate() {
    removeEmptyOrBrokenStacks();
    mass = sumMass();
  }

  static const type = "Backpack";

  @override
  String get typeName => type;

  @override
  Iterator<ItemStack> get iterator => items.iterator;
}

extension BackpackX on Backpack {
  bool matchedAny(Matcher<ItemStack> matcher) {
    var hasMatchedAny = false;
    for (final stack in items) {
      if (matcher(stack)) {
        hasMatchedAny = true;
      }
    }
    return hasMatchedAny;
  }

  List<ItemStack> matchTypeOnlyItems(ItemMatcher matcher) {
    return matcher.filterTypedMatchedStacks(items).toList();
  }

  List<ItemStack> matchExactItems(ItemMatcher matcher) {
    return matcher.filterExactMatchedStacks(items).toList();
  }

  /// Separate the [items] into matched and unmatched.
  MapEntry<List<ItemStack>, List<ItemStack>> separateMatchedFromUnmatched(
    bool Function(ItemStack stack) matcher,
  ) {
    final matched = <ItemStack>[];
    final unmatched = <ItemStack>[];
    for (final item in items) {
      if (matcher(item)) {
        matched.add(item);
      } else {
        unmatched.add(item);
      }
    }
    return MapEntry(matched, unmatched);
  }

  /// return whether [addition] is added or merged.
  bool _addItemOrMerge(ItemStack addition) {
    if (addition.isEmpty) return false;
    final additionMass = addition.stackMass;
    if (addition.meta.mergeable) {
      final existed = getItemByIdenticalMeta(addition);
      if (existed != null) {
        addition.mergeTo(existed);
      } else {
        items.add(addition);
      }
    } else {
      items.add(addition);
    }
    mass += additionMass;
    return true;
  }

  int sumMass() {
    var sum = 0;
    for (final item in items) {
      sum += item.stackMass;
    }
    return sum;
  }

  ItemStack? get firstOrNull => items.firstOrNull;

  ItemStack get firstOrEmpty => items.firstOrNull ?? ItemStack.empty;

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// safe to get an [ItemStack] in [items].
  ItemStack operator [](int index) => items.isEmpty ? ItemStack.empty : items[index.clamp(0, items.length - 1)];

  ItemStack? getItemByName(String name) => items.firstWhereOrNull((e) => e.meta.name == name);

  ItemStack? getItemByIdenticalMeta(ItemStack item) => items.firstWhereOrNull((e) => e.meta == item.meta);

  bool hasItemOfName(String name) => items.any((e) => e.meta.name == name);

  bool hasItem(ItemStack stack) => items.contains(stack);

  int countItemOfName(String name) => items.count((e) => e.meta.name == name);

  int countItemWhere(bool Function(ItemStack) predicate) => items.count(predicate);
}

extension BackpackItemFinderX on Backpack {
  Iterable<ItemCompPair<ToolComp>> findToolsOfType(ToolType toolType) sync* {
    for (final item in items) {
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        yield ItemCompPair(item, asTool);
      }
    }
  }

  Iterable<ItemCompPair<ToolComp>> findToolsOfTypes(List<ToolType> toolTypes) sync* {
    for (final item in items) {
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && toolTypes.contains(asTool.toolType)) {
        yield ItemCompPair(item, asTool);
      }
    }
  }

  ItemCompPair<ToolComp>? findBesToolOfType(ToolType toolType) {
    return findToolsOfType(toolType).maxOfOrNull((p) => p.comp.attr);
  }

  ItemCompPair<ToolComp>? findBesToolOfTypes(List<ToolType> toolTypes) {
    return findToolsOfTypes(toolTypes).maxOfOrNull((p) => p.comp.attr);
  }

  bool hasAnyToolOfTypes(List<ToolType> toolTypes) {
    for (final item in items) {
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && toolTypes.contains(asTool.toolType)) {
        return true;
      }
    }
    return false;
  }

  bool hasAnyToolOfType(ToolType toolType) {
    for (final item in items) {
      final asTool = item.meta.getFirstComp<ToolComp>();
      if (asTool != null && asTool.toolType == toolType) {
        return true;
      }
    }
    return false;
  }
}
