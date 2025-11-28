import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/space_item.dart';
import 'list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String username = "";
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    loadUser();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("current_username") ?? "User";
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("saved_username");
    await prefs.remove("saved_email");
    await prefs.remove("saved_password");

    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  // Animation builder
  Widget animatedItem(Widget child, int index) {
    final anim = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.15, 1, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                .animate(anim),
        child: child,
      ),
    );
  }

  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurpleBg1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER + LOGOUT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Halo, $username !",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),

                  GestureDetector(
                    onTap: logout,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10)
                        ],
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 26,
                        color: kPurplePrimary,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "Jelajahi berita, blog, dan laporan terbaru\ndari dunia antariksa 🚀",
                style: GoogleFonts.poppins(
                  color: kTextLight,
                  fontSize: 13.5,
                ),
              ),

              const SizedBox(height: 26),

              animatedItem(_exploreBanner(), 0),
              const SizedBox(height: 26),

              animatedItem(
                _menuCard(
                  title: "News",
                  subtitle: "Berita antariksa terbaru",
                  icon: Icons.newspaper_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xffb39ddb), kPurplePrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListPage(type: ContentType.news),
                      ),
                    );
                  },
                ),
                1,
              ),

              const SizedBox(height: 16),

              animatedItem(
                _menuCard(
                  title: "Blog",
                  subtitle: "Insight & artikel dari ahli",
                  icon: Icons.menu_book_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xffce93d8), kPurplePrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListPage(type: ContentType.blog),
                      ),
                    );
                  },
                ),
                2,
              ),

              const SizedBox(height: 16),

              animatedItem(
                _menuCard(
                  title: "Report",
                  subtitle: "Analisa & laporan mendalam",
                  icon: Icons.analytics_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xffd1c4e9), kPurplePrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListPage(type: ContentType.report),
                      ),
                    );
                  },
                ),
                3,
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  Widget _exploreBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xfff3e8ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.07),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.travel_explore_rounded,
              size: 40, color: kPurplePrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Jelajahi konten terbaru tentang luar angkasa!",
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: kTextDark,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: 1,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.08),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 32, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
