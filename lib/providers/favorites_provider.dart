import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void toggleFavorite(Map<String, dynamic> item) {
    if (_favorites.any((favorite) => favorite['id'] == item['id'])) {
      // 同じIDが存在する場合は削除
      _favorites.removeWhere((favorite) => favorite['id'] == item['id']);
    } else {
      // 存在しない場合のみ追加
      _favorites.add(item);
    }
    notifyListeners(); // 変更を通知
  }

  bool isFavorite(Map<String, dynamic> item) {
    return _favorites.any((favorite) => favorite['id'] == item['id']);
  }
}