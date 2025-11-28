import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/space_item.dart';

class DetailPage extends StatefulWidget {
  final SpaceItem item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> favorites = [];
  String currentUser = "";
  late AnimationController favAnim;

  @override
  void initState() {
    super.initState();
    favAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    loadFavorites();
  }

  @override
  void dispose() {
    favAnim.dispose();
    super.dispose();
  }

  // ============================================================
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    currentUser = prefs.getString("current_username") ?? "";
    final key = "favorites_$currentUser";

    final stored = prefs.getStringList(key) ?? [];

    favorites =
        stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    setState(() {});
  }

  Future<void> toggleFavorite() async {
    favAnim.forward().then((_) => favAnim.reverse());

    final prefs = await SharedPreferences.getInstance();
    final key = "favorites_$currentUser";

    final exists = favorites.any((f) => f["id"] == widget.item.id);

    if (exists) {
      favorites.removeWhere((f) => f["id"] == widget.item.id);
    } else {
      favorites.add(widget.item.toJson());
    }

    prefs.setStringList(
      key,
      favorites.map((e) => jsonEncode(e)).toList(),
    );

    setState(() {});
  }

  bool get isFav => favorites.any((f) => f["id"] == widget.item.id);

  void openWebsite(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka halaman web")),
      );
    }
  }

  // ============================================================
  //   WIDGET INFO ROW (icon + label + value)
  // ============================================================
  Widget infoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPurplePrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label\n",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: GoogleFonts.poppins(
                      height: 1.4,
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  //                        BUILD UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: kPurpleBg1,
      body: Stack(
        children: [
          // ================= IMAGE HEADER ==================
          Hero(
            tag: "img_${item.id}",
            child: Container(
              height: 360,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // gradient overlay
          Container(
            height: 360,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(.4),
                  Colors.black.withOpacity(.1),
                  Colors.transparent
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ================= BACK + FAVORITE BTN ==================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON
                  _circleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),

                  // FAVORITE BUTTON
                  ScaleTransition(
                    scale: favAnim,
                    child: _circleButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? Colors.redAccent : kPurplePrimary,
                      onTap: toggleFavorite,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= DETAIL CONTENT ==================
          DraggableScrollableSheet(
            initialChildSize: .60,
            minChildSize: .60,
            maxChildSize: 1,
            builder: (context, scroll) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  controller: scroll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // TITLE
                      Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // DATE + TYPE
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            "${item.publishedAt.day}/${item.publishedAt.month}/${item.publishedAt.year}",
                            style: GoogleFonts.poppins(
                                fontSize: 12.5, color: kTextLight),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: kPurplePrimary.withOpacity(.15),
                            ),
                            child: Text(
                              item.getTypeString().toUpperCase(),
                              style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: kPurplePrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ================= IMPORTANT API INFO ==================
                      infoRow(Icons.article_rounded, "Summary", item.summary),
                      infoRow(Icons.language_rounded, "News Site", item.newsSite),
                      infoRow(Icons.star_rounded, "Featured",
                          item.featured.toString()),
                      infoRow(Icons.update_rounded, "Updated At",
                          item.updatedAt.toString()),

                      if (item.launches.isNotEmpty)
                        infoRow(Icons.rocket_launch_rounded, "Launches",
                            item.launches.join(", ")),
                      if (item.events.isNotEmpty)
                        infoRow(Icons.event_available_rounded, "Events",
                            item.events.join(", ")),


                      const SizedBox(height: 24),

                      // ================= BUTTON OPEN WEBSITE ==================
                      if (item.url.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_new_rounded,
                                color: Colors.white),
                            onPressed: () => openWebsite(item.url),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPurplePrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            label: Text(
                              "Buka Halaman Web",
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  //               BEAUTIFUL CIRCLE BUTTON
  // ============================================================
  Widget _circleButton(
      {required IconData icon,
      required VoidCallback onTap,
      Color color = Colors.black87}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
