import JSZip from "jszip";
import { ChapterDataT, ChaptersT, NovelT } from "../types";
import { downloadImageBlob } from "../utils";
import { saveFileToDownloads } from "../fs";

export const testEpubGen = async () => {
	const novel: NovelT = {
		source: "NovelFull",
		url: "https://example.com",
		title: "Test NEW Novel",
		authors: ["Test Author"],
		genres: ["Test Genre"],
		description: "This is a test novel",
		coverURL: "https://m.media-amazon.com/images/I/81bdOXBN+6L._SY466_.jpg",
	};
	const chapters: ChapterDataT[] = [
		{
			title: "Test Chapter 1",
			url: "https://example.com/chapter1",
			content: "This is the content of chapter 1",
		},
		{
			title: "Test Chapter 2",
			url: "https://example.com/chapter2",
			content: "This is the content of chapter 2",
		},
	];

	try {
		const epubBlob = await generateEPUB(novel, chapters);
		const epub = await getBlobAsStringP(epubBlob);
		await saveFileToDownloads("test.epub", epub, "base64");
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

const getBlobAsStringP = (blob: Blob): Promise<string> => {
	return new Promise<string>((resolve, reject) => {
		const fr = new FileReader();
		fr.onload = () => {
			if (!fr.result) return reject("Failed to read blob");
			resolve(fr.result as string);
		}
		fr.readAsText(blob);
	});
}

export const generateEPUB = async (novel: NovelT, chapters: ChapterDataT[]) => {
	const zip = new JSZip();

	zip.file("mimetype", "application/epub+zip");
	zip.file("META-INF/container.xml", getContainerXML());
	const OEBPSFolder = zip.folder("OEBPS");
	if (!OEBPSFolder) throw new Error("Failed to create OEBPS folder");
	OEBPSFolder.file("cover.xhtml", getCoverXHTML(novel.title));
	OEBPSFolder.file("ebook.opf", getEbookOPF(novel, chapters));
	OEBPSFolder.file("navigation.ncx", getNavigationNCX(novel, chapters));

	const contentFolder = OEBPSFolder.folder("content");
	if (!contentFolder) throw new Error("Failed to create content folder");
	contentFolder.file("toc.xhtml", getTocXHTML(novel, chapters));
	chapters.forEach((chapter, i) => {
		contentFolder.file(`s${i + 1}.xhtml`, getChapterXHTML(i + 1, novel, chapter));
	});

	OEBPSFolder.file("css/ebook.css", "");

	let coverBlob: any = "";
	if (novel.coverURL) coverBlob = await downloadImageBlob(novel.coverURL) || "";
	OEBPSFolder.file("images/cover.jpeg", coverBlob, { base64: true });

	return await zip.generateAsync({ type: "blob", mimeType: "application/epub+zip" })
}

const getContainerXML = () => {
	return `
		<?xml version='1.0' encoding='UTF-8' ?>
		<container version='1.0' xmlns='urn:oasis:names:tc:opendocument:xmlns:container'>
			<rootfiles>
				<rootfile full-path='OEBPF/ebook.opf' media-type='application/oebps-package+xml'/>
			</rootfiles>
		</container>
	`;
}

const getCoverXHTML = (novelTitle: string) => {
	return `
		<?xml version='1.0' encoding='UTF-8' ?>
		<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN'  'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
		<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'>
			<head>
				<title>${novelTitle}</title>
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

	`;
}

const getEbookOPF = (novel: NovelT, chapters: ChapterDataT[]) => {
	return `
		<?xml version='1.0' encoding='utf-8'?>
		<package xmlns='http://www.idpf.org/2007/opf' version='2.0' unique-identifier='BookId'>
		<metadata xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:opf='http://www.idpf.org/2007/opf'>
			<dc:title>${novel.title}</dc:title>
			<dc:identifier id='BookId' opf:scheme='URI'>0000-0000-0001</dc:identifier>
			<dc:language>en</dc:language>
			<dc:creator opf:role='aut' opf:file-as=''>${novel.authors?.join(", ") || "Unknown"}</dc:creator>
			<dc:publisher></dc:publisher>
			<dc:description>${novel.description || ""}</dc:description>
			<dc:coverage></dc:coverage>
			<dc:source>${novel.source}</dc:source>
			<dc:date opf:event='publication'></dc:date>
			<dc:date opf:event='modification'>2024-03-08</dc:date>
			<dc:rights></dc:rights>
			<dc:subject>${novel.genres?.join(", ") || "Unknown"}</dc:subject>
			<meta name='cover' content='cover-image'/>
		</metadata>
		<manifest>
			<item id='cover-image' media-type='image/jpeg' href='images/cover.jpeg'/>
			<item id='cover' media-type='application/xhtml+xml' href='cover.xhtml'/>
			<item id='navigation' media-type='application/x-dtbncx+xml' href='navigation.ncx'/>
			${chapters.map((chapter, i) => {
		return `<item id='s${i + 1}' media-type='application/xhtml+xml' href='content/s${i + 1}.xhtml'/>`;
	}).join("\n")}
			<item id='toc' media-type='application/xhtml+xml' href='content/toc.xhtml'/>
			<item id='css' media-type='text/css' href='css/ebook.css'/>
		</manifest>
		<spine toc='navigation'>
			<itemref idref='cover' linear='yes' />
			<itemref idref='toc'/>
			${chapters.map((chapter, i) => {
		return `<itemref idref='s${i + 1}'/>`;
	}).join("\n")}
		</spine>
		<guide>
			<reference type='toc' title='Contents' href='content/toc.xhtml'></reference>
		</guide>
		</package>
	`;
}

const getNavigationNCX = (novel: NovelT, chapters: ChapterDataT[]) => {
	return `
		<?xml version='1.0' encoding='UTF-8'?>
		<!DOCTYPE ncx PUBLIC '-//NISO//DTD ncx 2005-1//EN' 'http://www.daisy.org/z3986/2005/ncx-2005-1.dtd'>
		<ncx xmlns='http://www.daisy.org/z3986/2005/ncx/'>
		<head>
			<meta name='dtb:uid' content='0000-0000-0001'/>
			<meta name='dtb:depth' content='1'/>
			<meta name='dtb:totalPageCount' content='0'/>
			<meta name='dtb:maxPageNumber' content='0'/>
		</head>
		<docTitle><text>${novel.title}</text></docTitle>
		<docAuthor><text>${novel.authors?.join(", ") || "Unknown"}</text></docAuthor>
		<navMap>
			<navPoint id='cover' playOrder='1'>
				<navLabel><text>Cover</text></navLabel>
				<content src='cover.xhtml'/>
			</navPoint>
			<navPoint class='toc' id='toc' playOrder='2'>
				<navLabel><text>Table of Contents</text></navLabel>
				<content src='content/toc.xhtml'/>
			</navPoint>
			${chapters.map((chapter, i) => {
		return `
					<navPoint class='section' id='s${i + 1}' playOrder='${i + 3}'>
						<navLabel><text>${chapter.title}</text></navLabel>
						<content src='content/s${i + 1}.xhtml'/>
					</navPoint>
				`;
	}).join("\n")}
		</navMap>
		</ncx>
	`;
}

const getChapterXHTML = (id: number, novel: NovelT, chapter: ChapterDataT) => {
	return `
	<?xml version='1.0' encoding='utf-8'?>
	<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
	<html xmlns='http://www.w3.org/1999/xhtml'>
	<head profile='http://dublincore.org/documents/dcmi-terms/'>
		<meta http-equiv='Content-Type' content='text/html;' />
		<title>${novel.title} - ${chapter.title}</title>
		<meta name='DCTERMS.title' content="${novel.title}" />
		<meta name='DCTERMS.language' content='en' scheme='DCTERMS.RFC4646' />
		<meta name='DCTERMS.source' content='${novel.source}' />
		<meta name='DCTERMS.issued' content='{$issued}' scheme='DCTERMS.W3CDTF'/>
		<meta name='DCTERMS.creator' content="${novel.authors?.join(", ") || "Unknown"}"/>
		<meta name='DCTERMS.contributor' content='' />
		<meta name='DCTERMS.modified' content='{$issued}' scheme='DCTERMS.W3CDTF'/>
		<meta name='DCTERMS.provenance' content='' />
		<meta name='DCTERMS.subject' content="${novel.genres?.join(", ") || "Unknown"}" />
		<link rel='schema.DC' href='http://purl.org/dc/elements/1.1/' hreflang='en' />
		<link rel='schema.DCTERMS' href='http://purl.org/dc/terms/' hreflang='en' />
		<link rel='schema.DCTYPE' href='http://purl.org/dc/dcmitype/' hreflang='en' />
		<link rel='schema.DCAM' href='http://purl.org/dc/dcam/' hreflang='en' />
		<link rel='stylesheet' type='text/css' href='../css/ebook.css' />
	</head>
	<body>
		<div id='s${id}'></div>
		<div>${chapter.content}</div>
	</body>
	</html>
	`;
}

const getTocXHTML = (novel: NovelT, chapters: ChapterDataT[]) => {
	return `
		<?xml version='1.0' encoding='utf-8'?>
		<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd' >
		<html xmlns='http://www.w3.org/1999/xhtml'>
			<head>
				<title>Table of Contents</title>
				<link rel='stylesheet' type='text/css' href='../css/ebook.css' />
			</head>
			<body>
				<div class='contents'>
				<h1>Table of Contents</h1>
				${chapters.map((chapter, i) => {
		return `<a href='s${i + 1}.xhtml'>${chapter.title}</a><br/>`;
	}).join("\n")
		}
				</div>
			</body>
		</html>
	`;
}
