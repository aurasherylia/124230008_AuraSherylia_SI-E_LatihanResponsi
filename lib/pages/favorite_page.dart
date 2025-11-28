// lib/pages/favorite_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/space_item.dart';
import 'detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favorites = [];
  String currentUser = "";

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // ============================================================
  /// LOAD FAVORITE BERDASARKAN USER LOGIN
  // ============================================================
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil user login sekarang
    currentUser = prefs.getString("current_username") ?? "";

    // Key khusus user
    final key = "favorites_$currentUser";

    final list = prefs.getStringList(key) ?? [];

    favorites = list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    setState(() {});
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "favorites_$currentUser";

    prefs.setStringList(
      key,
      favorites.map((e) => jsonEncode(e)).toList(),
    );
  }

  void removeFavorite(int id) {
    favorites.removeWhere((e) => e["id"] == id);
    saveFavorites();
    setState(() {});
  }

  // ============================================================
  void showDeletePopup(int id) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded,
                  size: 70, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text("Hapus Favorit?",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                "Hapus item ini dari daftar favoritmu?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: kTextLight),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Batal",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        removeFavorite(id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Hapus",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurpleBg1,
      appBar: AppBar(
        backgroundColor: kPurpleBg1,
        elevation: 0,
        title: Text(
          "Favorite",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, color: kTextDark),
        ),
      ),

      body: favorites.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (_, i) {
                final data = favorites[i];
                final item = SpaceItem.fromJson(data);

                return Dismissible(
                  key: Key(item.id.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    showDeletePopup(item.id);
                    return false;
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.delete,
                        color: Colors.white, size: 28),
                  ),
                  child: _favoriteCardHorizontal(item),
                );
              },
            ),
    );
  }

  // ============================================================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 90, color: kPurplePrimary.withOpacity(0.35)),
          const SizedBox(height: 14),
          Text("Belum ada favorit",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            "Tambahkan item ke favorit dari halaman List",
            style: GoogleFonts.poppins(fontSize: 13, color: kTextLight),
          ),
        ],
      ),
    );
  }

  // ============================================================
  Widget _favoriteCardHorizontal(SpaceItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(item: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 7))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: Image.network(
                item.imageUrl,
                width: 130,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 130, height: 110, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(right: 14, top: 14, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: kTextDark)),
                    const SizedBox(height: 4),
                    Text(item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: kTextLight)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
