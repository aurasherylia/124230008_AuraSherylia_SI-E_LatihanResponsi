import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/space_item.dart';

class ApiService {
  static const String baseUrl = "https://api.spaceflightnewsapi.net/v4";

  static Future<List<SpaceItem>> fetchList(ContentType type) async {
    final path = contentTypeToPath(type);
    final url = "$baseUrl/$path/?limit=20&ordering=-published_at";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Gagal memuat data ($path)");
    }

    final data = jsonDecode(response.body);
    final List results = data["results"];

    return results.map((e) => SpaceItem.fromJson(e)).toList();
  }


  static Future<SpaceItem> fetchDetail(ContentType type, int id) async {
    final path = contentTypeToPath(type);
    final url = "$baseUrl/$path/$id/";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Gagal memuat detail item");
    }

    return SpaceItem.fromJson(jsonDecode(response.body));
  }
}
