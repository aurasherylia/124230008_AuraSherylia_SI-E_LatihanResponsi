// lib/pages/list_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/space_item.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class ListPage extends StatefulWidget {
  final ContentType type;

  const ListPage({super.key, required this.type});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<SpaceItem> items = [];
  List<int> favoriteIds = [];
  String currentUser = "";

  @override
  void initState() {
    super.initState();
    loadFavorites();
    loadData();
  }

  // =========================================================
  //          LOAD FAVORITES BERDASARKAN USER LOGIN
  // =========================================================
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    currentUser = prefs.getString("current_username") ?? "";
    final key = "favorites_$currentUser";

    final stored = prefs.getStringList(key) ?? [];

    favoriteIds =
        stored.map((e) => jsonDecode(e)["id"] as int).toList();

    setState(() {});
  }

  // =========================================================
  Future<void> loadData() async {
    items = await ApiService.fetchList(widget.type);
    setState(() {});
  }

  // =========================================================
  //          TOGGLE FAVORITE + pindah ke FavoritePage
  // =========================================================
  Future<void> toggleFavorite(SpaceItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "favorites_$currentUser";

    final stored = prefs.getStringList(key) ?? [];
    List<Map<String, dynamic>> favs =
    stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    final exists = favs.any((f) => f["id"] == item.id);

    if (exists) {
      favs.removeWhere((f) => f["id"] == item.id);
    } else {
      favs.add(item.toJson());
    }

    await prefs.setStringList(
      key,
      favs.map((e) => jsonEncode(e)).toList(),
    );

    favoriteIds = favs.map((e) => e["id"] as int).toList();
    setState(() {});

    // Langsung pindah ke FavoritePage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritePage()),
    );
  }

  // =========================================================
  @override
  Widget build(BuildContext context) {
    final String title = contentTypeToTitle(widget.type);

    return Scaffold(
      backgroundColor: kPurpleBg1,
      appBar: AppBar(
        backgroundColor: kPurpleBg1,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
      ),

      body: items.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: kPurplePrimary),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isFav = favoriteIds.contains(item.id);

                return _newsCard(item, isFav);
              },
            ),
    );
  }

  // =========================================================
  Widget _newsCard(SpaceItem item, bool isFav) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(item: item)),
        );
        loadFavorites(); // refresh setelah kembali
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            if (item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  item.imageUrl,
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: kTextLight,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),

                      Text(
                        "${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const Spacer(),

                      GestureDetector(
                        onTap: () => toggleFavorite(item),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 26,
                          color: isFav ? Colors.redAccent : Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
