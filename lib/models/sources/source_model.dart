enum Source {
  novelfull(
    name: "NovelFull",
    url: "novelfull.com",
    logoSrc: "novelfull-logo.png",
  );

  final String name;
  final String url;
  final String logoSrc;

  const Source({
    required this.name,
    required this.url,
    required this.logoSrc,
  });
}
