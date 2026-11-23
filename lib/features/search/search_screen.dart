import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _TileData(
        'Branch',
        'Search for branch',
        Icons.account_balance,
        const Color(0xFF3B2F9F),
        '/home/branch',
      ),
      _TileData(
        'Interest rate',
        'Search for interest rate',
        Icons.trending_up,
        const Color(0xFF7C3AED),
        '/home/interest-rate',
      ),
      _TileData(
        'Exchange rate',
        'Search for exchange rate',
        Icons.swap_horiz,
        const Color(0xFFF59E0B),
        '/home/exchange-rate',
      ),
      // ИЗМЕНЕНО: маршрута /exchange пока нет — обрабатываем заглушкой
      _TileData(
        'Exchange',
        'Exchange amount of money',
        Icons.groups,
        const Color(0xFFEF4444),
        '',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          // ИЗМЕНЕНО: context.pop() вместо Navigator.pop
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final tile = tiles[i];
          return _SearchTile(
            tile: tile,
            onTap: () {
              // ИЗМЕНЕНО: пустой route → заглушка
              if (tile.route.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tile.title}: раздел в разработке'),
                  ),
                );
              } else {
                context.push(tile.route);
              }
            },
          );
        },
      ),
    );
  }
}

class _TileData {
  final String title, subtitle, route;
  final IconData icon;
  final Color color;
  const _TileData(this.title, this.subtitle, this.icon, this.color, this.route);
}

class _SearchTile extends StatelessWidget {
  final _TileData tile;
  final VoidCallback onTap;
  const _SearchTile({required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tile.subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            // Имитация цветной иллюстрации из шаблона
            Container(
              width: 90,
              height: 70,
              decoration: BoxDecoration(
                color: tile.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tile.icon, color: tile.color, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}