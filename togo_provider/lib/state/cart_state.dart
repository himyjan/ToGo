import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/models.dart';

class CartState extends ChangeNotifier {
  List<int> _ids = [];
  List<Order> _items = [];

  CartState() {
    init();
  }

  List<Order> get items => _items;

  bool get isEmpty => total == 0;
  bool get notEmpty => total > 0;

  int get total {
    int total = 0;

    for (var item in items) {
      total += item.quantity;
    }

    return total;
  }

  double get totalPrice {
    double totalPrice = 0;

    for (var item in items) {
      totalPrice += item.totalPrice;
    }

    return totalPrice;
  }

  int count(Product product) {
    final id = product.id;

    if (_ids.contains(id)) {
      final index = _ids.indexOf(id);
      final item = _items.elementAt(index);
      return item.quantity;
    }

    return 0;
  }

  bool has(Product product) {
    return count(product) > 0;
  }

  Order item(int index) => _items[index];

  Future<void> init() async {
    await _restore();
  }

  void addToCart(Product product) {
    _ids.add(product.id);
    _items.add(Order(product: product));
    notifyListeners();
    _save();
  }

  void updateQuantity(Product product, int quantity) {
    final id = product.id;

    if (_ids.contains(id)) {
      final index = _ids.indexOf(id);
      final item = _items.elementAt(index);
      item.quantity = quantity;
      notifyListeners();
      _save();
    }
  }

  void removeFromCart(Product product) {
    final id = product.id;

    if (_ids.contains(id)) {
      final index = _ids.indexOf(id);
      _ids.removeAt(index);
      _items.removeAt(index);
      notifyListeners();
      _save();
    }
  }

  Future<void> _save() async {
    final box = await Hive.openBox('cart');

    await box.put('items', _items.map((item) => item.toJson()).toList());
  }

  Future<void> _restore() async {
    final box = await Hive.openBox('cart');

    if (box.containsKey('items')) {
      final items = box.get('items');

      if (items is List) {
        _items = items.map((item) => Order.fromJson(item)).toList();
        _ids = _items.map((item) => item.product.id).toList();
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _ids = [];
    _items = [];
    super.dispose();
  }
}
