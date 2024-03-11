import { ChapterDataT } from "../../../types";

const EBOOK_OPF = (title: string, authors: string[], description: string, genres: string[], chapters: ChapterDataT[]) =>
	`<?xml version='1.0' encoding='utf-8'?>
<package xmlns='http://www.idpf.org/2007/opf' version='2.0' unique-identifier='BookId'>
	<metadata xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:opf='http://www.idpf.org/2007/opf'>
	<dc:title>${title}</dc:title>
	<dc:identifier id='BookId' opf:scheme='URI'>0000-0000-0001</dc:identifier>
	<dc:language>en</dc:language>
	<dc:creator opf:role='aut' opf:file-as=''>${authors.join(", ")}</dc:creator>
	<dc:publisher></dc:publisher>
	<dc:description>${description}</dc:description>
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
${chapters.map((chapter, i) => `    <item id='s${i + 1}' media-type='application/xhtml+xml' href='content/s${i + 1}.xhtml'/>`).join("\n")}
	<item id='toc' media-type='application/xhtml+xml' href='content/toc.xhtml'/>
	<item id='css' media-type='text/css' href='css/ebook.css'/>
	</manifest>
	<spine toc='navigation'>
	<itemref idref='cover' linear='yes' />
	<itemref idref='toc'/>
${chapters.map((chapter, i) => `    <itemref idref='s${i + 1}' />`).join("\n")}
	</spine>
	<guide>
	<reference type='toc' title='Contents' href='content/toc.xhtml'></reference>
	</guide>
</package>
`;
export default EBOOK_OPF;
