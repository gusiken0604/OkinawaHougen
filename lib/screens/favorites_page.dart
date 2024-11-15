import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('沖縄方言お気に入り'), // タイトルを1行に調整
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favorites = favoritesProvider.favorites;

          return favorites.isEmpty
              ? const Center(child: Text('お気に入りはありません'))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    return ListTile(
                      title: Text(item['hougen'] ?? ''),
                      subtitle: Text(item['japanese'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // お気に入りから削除
                          favoritesProvider.toggleFavorite(item);
                        },
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}