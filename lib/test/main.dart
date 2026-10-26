import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: MenuPage()),
  );
}

// ===================== DATA =====================
class Menu {
  const Menu(this.name, this.category, this.price);
  final String name;
  final String category;
  final int price;
}

const baseMenus = [
  Menu('Rendang', 'Lauk', 25000),
  Menu('Ayam Pop', 'Lauk', 22000),
  Menu('Gulai Tunjang', 'Lauk', 23000),
  Menu('Dendeng Balado', 'Lauk', 27000),
  Menu('Gulai Nangka', 'Sayur', 8000),
  Menu('Daun Singkong', 'Sayur', 6000),
  Menu('Terung Balado', 'Sayur', 7000),
  Menu('Es Teh Manis', 'Minuman', 5000),
  Menu('Teh Talua', 'Minuman', 12000),
  Menu('Es Tebak', 'Minuman', 15000),
];

// 50 menu: daftar dasar diulang lima kali
final menus = List.generate(50, (i) {
  final m = baseMenus[i % baseMenus.length];
  return Menu('${m.name} #${i + 1}', m.category, m.price);
});

const categories = ['Semua', 'Lauk', 'Sayur', 'Minuman'];

// ===================== HALAMAN =====================
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _isGrid = false;
  String _category = 'Semua';

  @override
  Widget build(BuildContext context) {
    final shown = _category == 'Semua'
        ? menus
        : menus.where((m) => m.category == _category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Padang (${shown.length})'),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: CategoryBar(
              selected: _category,
              onSelected: (c) {
                setState(() {
                  _category = c;
                });
              },
            ),
          ),
          Expanded(child: _isGrid ? _buildGrid(shown) : _buildList(shown)),
        ],
      ),
    );
  }

  Widget _buildList(List<Menu> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        debugPrint('build item $index');
        return MenuTile(menu: data[index]);
      },
    );
  }

  Widget _buildGrid(List<Menu> data) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return MenuCard(menu: data[index]);
      },
    );
  }
}

// ===================== WIDGET =====================
class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        for (final c in categories)
          Padding(
            padding: const EdgeInsets.all(4),
            child: ChoiceChip(
              label: Text(c),
              selected: c == selected,
              onSelected: (_) => onSelected(c),
            ),
          ),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({super.key, required this.menu});

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(menu.name[0])),
      title: Text(menu.name),
      subtitle: Text(menu.category),
      trailing: Text('Rp${menu.price}'),
    );
  }
}

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.menu});

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(child: Text(menu.name[0])),
            const Spacer(),
            Text(
              menu.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Rp${menu.price}'),
          ],
        ),
      ),
    );
  }
}
