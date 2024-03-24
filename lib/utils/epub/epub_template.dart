import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:novelscraper/models/chapter_model.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/utils/file.dart';

class EpubTemplate {
  static Future<Archive> getArchive(Novel novel, List<Chapter> chapters) async {
    Archive archive = Archive();

    final title = novel.title;
    final authors = novel.authors;
    final description = novel.description ?? "";
    final genres = novel.genres;

    // Root
    ArchiveFile mimetype = ArchiveFile("mimetype", _mimeType().length, _mimeType());
    archive.addFile(mimetype);

    // META-INF
    ArchiveFile container = ArchiveFile("META-INF/container.xml", _container().length, _container());
    archive.addFile(container);

    // OEBPF
    ArchiveFile coverXHTML = ArchiveFile(
      "OEBPF/cover.xhtml",
      _coverXHTML(title).length,
      _coverXHTML(title),
    );
    archive.addFile(coverXHTML);
    ArchiveFile ebookOPF = ArchiveFile(
      "OEBPF/ebook.opf",
      _ebookOPF(title, authors, description, genres, chapters).length,
      _ebookOPF(title, authors, description, genres, chapters),
    );
    archive.addFile(ebookOPF);
    ArchiveFile navigationNCX = ArchiveFile(
      "OEBPF/navigation.ncx",
      _navigationNCX(title, authors, chapters).length,
      _navigationNCX(title, authors, chapters),
    );
    archive.addFile(navigationNCX);

    // OEBPF/css
    ArchiveFile ebookCSS = ArchiveFile(
      "OEBPF/css/ebook.css",
      _ebookCSS().length,
      _ebookCSS(),
    );
    archive.addFile(ebookCSS);

    // OEBPF/content
    ArchiveFile tocXHTML = ArchiveFile(
      "OEBPF/content/toc.xhtml",
      _tocXHTML(chapters).length,
      _tocXHTML(chapters),
    );
    archive.addFile(tocXHTML);
    chapters.asMap().entries.forEach((entry) {
      final id = entry.key + 1;
      final chapter = entry.value;
      final sIdXHTML = ArchiveFile(
        "OEBPF/content/s$id.xhtml",
        _sIdXHTML(id, title, authors, genres, chapter).length,
        _sIdXHTML(id, title, authors, genres, chapter),
      );
      archive.addFile(sIdXHTML);
    });

    // OEBPF/images
    final imageURL = novel.coverURL ?? novel.thumbnailURL;
    if (imageURL != null) {
      final coverImage = await _coverImage(imageURL);
      if (coverImage != null) {
        ArchiveFile coverImageFile = ArchiveFile("OEBPF/images/cover.jpeg", coverImage.length, coverImage);
        archive.addFile(coverImageFile);
      }
    }

    return archive;
  }

  static String _mimeType() => "application/epub+zip";

  static String _container() => """<?xml version='1.0' encoding='UTF-8' ?>
<container version='1.0' xmlns='urn:oasis:names:tc:opendocument:xmlns:container'>
  <rootfiles>
    <rootfile full-path='OEBPF/ebook.opf' media-type='application/oebps-package+xml'/>
  </rootfiles>
</container>
""";

  static String _navigationNCX(
    String title,
    List<String> authors,
    List<Chapter> chapters,
  ) {
    final navPoints = chapters.asMap().entries.map((entry) {
      final id = entry.key + 1;
      final order = entry.key + 3;
      final chapter = entry.value;
      return """	<navPoint class='section' id='s$id' playOrder='$order'>
		<navLabel><text>${chapter.title}</text></navLabel>
		<content src='content/s$id.xhtml'/>
	</navPoint>
""";
    }).join("\n");

    return """<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE ncx PUBLIC '-//NISO//DTD ncx 2005-1//EN' 'http://www.daisy.org/z3986/2005/ncx-2005-1.dtd'>
<ncx xmlns='http://www.daisy.org/z3986/2005/ncx/'>
<head>
	<meta name='dtb:uid' content='0000-0000-0001'/>
	<meta name='dtb:depth' content='1'/>
	<meta name='dtb:totalPageCount' content='0'/>
	<meta name='dtb:maxPageNumber' content='0'/>
</head>
<docTitle><text>$title</text></docTitle>
<docAuthor><text>${authors.join(", ")}</text></docAuthor>
<navMap>
	<navPoint id='cover' playOrder='1'>
    <navLabel><text>Cover</text></navLabel>
    <content src='cover.xhtml'/>
	</navPoint>
	<navPoint class='toc' id='toc' playOrder='2'>
    <navLabel><text>Table of Contents</text></navLabel>
    <content src='content/toc.xhtml'/>
	</navPoint>
$navPoints
</navMap>
</ncx>
""";
  }

  static String _ebookOPF(
    String title,
    List<String> authors,
    String description,
    List<String> genres,
    List<Chapter> chapters,
  ) {
    final chapterEntries = chapters.asMap().entries;

    final items = chapterEntries.map((entry) {
      final id = entry.key + 1;
      return "	<item id='s$id' media-type='application/xhtml+xml' href='content/s$id.xhtml'/>";
    }).join("\n");

    final itemRefs = chapterEntries.map((entry) {
      final id = entry.key + 1;
      return "	<itemref idref='s$id'/>";
    }).join("\n");

    return """<?xml version='1.0' encoding='utf-8'?>
<package xmlns='http://www.idpf.org/2007/opf' version='2.0' unique-identifier='BookId'>
	<metadata xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:opf='http://www.idpf.org/2007/opf'>
	<dc:title>$title</dc:title>
	<dc:identifier id='BookId' opf:scheme='URI'>0000-0000-0001</dc:identifier>
	<dc:language>en</dc:language>
	<dc:creator opf:role='aut' opf:file-as=''>${authors.join(", ")}</dc:creator>
	<dc:publisher></dc:publisher>
	<dc:description>$description</dc:description>
	<dc:coverage></dc:coverage>
	<dc:source></dc:source>
	<dc:date opf:event='publication'></dc:date>
	<dc:date opf:event='modification'>2030-03-05</dc:date>
	<dc:rights></dc:rights>
	<dc:subject>${genres.join(", ")}</dc:subject>
	<meta name='cover' content='cover-image'/>
	</metadata>
	<manifest>
	<item id='cover-image' media-type='image/jpeg' href='images/cover.jpeg'/>
	<item id='cover' media-type='application/xhtml+xml' href='cover.xhtml'/>
	<item id='navigation' media-type='application/x-dtbncx+xml' href='navigation.ncx'/>
$items
	<item id='toc' media-type='application/xhtml+xml' href='content/toc.xhtml'/>
	<item id='css' media-type='text/css' href='css/ebook.css'/>
	</manifest>
	<spine toc='navigation'>
	<itemref idref='cover' linear='yes' />
	<itemref idref='toc'/>
$itemRefs
	</spine>
	<guide>
	<reference type='toc' title='Contents' href='content/toc.xhtml'></reference>
	</guide>
</package>
""";
  }

  static String _coverXHTML(String title) => """<?xml version='1.0' encoding='UTF-8' ?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN'  'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'>
<head>
  <title>$title</title>
  <style type='text/css'>
    body { margin: 0; padding: 0; text-align: center; }
    .cover { margin: 0; padding: 0; font-size: 1px; }
    img { margin: 0; padding: 0; height: 100%; }
  </style>
</head>
<body>
  <div class='cover'><img style='height: 100%;width: 100%;' src='images/cover.jpeg' alt='Cover' /></div>
</body>
</html>
""";

  static String _ebookCSS() => "";

  static String _tocXHTML(List<Chapter> chapters) {
    final chapterLinks = chapters.asMap().entries.map((entry) {
      final id = entry.key + 1;
      final chapter = entry.value;
      return "  <a href='s$id.xhtml'>${chapter.title}</a><br/>";
    }).join("\n");

    return """<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>

<head>
  <title>Table of Contents</title>
  <link rel='stylesheet' type='text/css' href='../css/ebook.css' />
</head>

<body>
  <div class='contents'>
    <h1>Table of Contents</h1>
$chapterLinks
  </div>
</body>

</html>
""";
  }

  static String _sIdXHTML(
    int id,
    String title,
    List<String> authors,
    List<String> genres,
    Chapter chapter,
  ) =>
      """<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>
  <head profile='http://dublincore.org/documents/dcmi-terms/'>
    <meta http-equiv='Content-Type' content='text/html;' />
    <title>$title - ${chapter.title}</title>
    <meta name='DCTERMS.title' content='$title' />
    <meta name='DCTERMS.language' content='en' scheme='DCTERMS.RFC4646' />
    <meta name='DCTERMS.source' content='NovelScraper' />
    <meta name='DCTERMS.issued' content='' scheme='DCTERMS.W3CDTF'/>
    <meta name='DCTERMS.creator' content='${authors.join(", ")}'/>
    <meta name='DCTERMS.contributor' content='' />
    <meta name='DCTERMS.modified' content='' scheme='DCTERMS.W3CDTF'/>
    <meta name='DCTERMS.provenance' content='' />
    <meta name='DCTERMS.subject' content='${genres.join(", ")}' />
    <link rel='schema.DC' href='http://purl.org/dc/elements/1.1/' hreflang='en' />
    <link rel='schema.DCTERMS' href='http://purl.org/dc/terms/' hreflang='en' />
    <link rel='schema.DCTYPE' href='http://purl.org/dc/dcmitype/' hreflang='en' />
    <link rel='schema.DCAM' href='http://purl.org/dc/dcam/' hreflang='en' />
    <link rel='stylesheet' type='text/css' href='../css/ebook.css' />
  </head>
  <body>
    <div id='s$id'></div>
    <div>
		${chapter.content}
	</div>
  </body>
</html>
""";

  static Future<Uint8List?> _coverImage(String imageURL) async => await fetchImage(imageURL);
}
