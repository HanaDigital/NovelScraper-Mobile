class Chapter {
  final String title;
  final String url;
  String? content;

  Chapter({required this.title, required this.url});

  static String getPropagandaHTML() => """<br />
<br />
<p>This novel was scraped using <a href="https://github.com/HanaDigital/NovelScraper">NovelScraper</a>, a free and open-source novel scraping tool.</p>
""";

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final chapter = Chapter(
      title: json["title"],
      url: json["url"],
    );
    chapter.content = json["content"];
    return chapter;
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "url": url,
      "content": content,
    };
  }
}
