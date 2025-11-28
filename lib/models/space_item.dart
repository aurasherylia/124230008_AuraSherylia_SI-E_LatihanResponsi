enum ContentType { news, blog, report }

// ==========================================================
//      PATH & TITLE UNTUK API DAN UI
// ==========================================================
String contentTypeToPath(ContentType type) {
  switch (type) {
    case ContentType.news:
      return "articles";
    case ContentType.blog:
      return "blogs";
    case ContentType.report:
      return "reports";
  }
}


String contentTypeToTitle(ContentType type) {
  switch (type) {
    case ContentType.news:
      return "News";
    case ContentType.blog:
      return "Blog";
    case ContentType.report:
      return "Report";
  }
}

ContentType typeFromString(String type) {
  switch (type) {
    case "news":
      return ContentType.news;
    case "blog":
      return ContentType.blog;
    case "report":
      return ContentType.report;
    default:
      return ContentType.news;
  }
}

String typeToString(ContentType type) {
  switch (type) {
    case ContentType.news:
      return "news";
    case ContentType.blog:
      return "blog";
    case ContentType.report:
      return "report";
  }
}

// ==========================================================
//               MODEL FINAL — ANTI ERROR NULL
// ==========================================================
class SpaceItem {
  final int id;
  final String title;
  final String summary;
  final String imageUrl;
  final String url;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final String newsSite;
  final bool featured;
  final List<dynamic> launches;
  final List<dynamic> events;

  final ContentType type;

  SpaceItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.url,
    required this.publishedAt,
    required this.updatedAt,
    required this.newsSite,
    required this.featured,
    required this.launches,
    required this.events,
    required this.type,
  });

  // from API maupun dari SharedPreferences (favorite)
  factory SpaceItem.fromJson(Map<String, dynamic> json) {
    return SpaceItem(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      summary: json["summary"] ?? "",
      // bisa dari API (image_url) atau dari favorite (imageUrl)
      imageUrl: json["image_url"] ?? json["imageUrl"] ?? "",
      url: json["url"] ?? "",

      // FIX: aman kalau null, support "published_at" (API) & "publishedAt" (favorite)
      publishedAt: DateTime.tryParse(
                json["publishedAt"] ?? json["published_at"] ?? "",
              ) ??
          DateTime(2000),

      updatedAt: DateTime.tryParse(
                json["updated_at"] ?? "",
              ) ??
          DateTime(2000),

      newsSite: json["news_site"] ?? "-",
      featured: json["featured"] ?? false,
      launches: json["launches"] ?? [],
      events: json["events"] ?? [],

      type: json["type"] != null
          ? typeFromString(json["type"])
          : ContentType.news,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "summary": summary,
      "imageUrl": imageUrl,
      "url": url,
      "publishedAt": publishedAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "news_site": newsSite,
      "featured": featured,
      "launches": launches,
      "events": events,
      "type": typeToString(type),
    };
  }

  String getTypeString() => typeToString(type);
}
