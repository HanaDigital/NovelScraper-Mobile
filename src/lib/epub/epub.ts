import JSZip from "jszip";
import { ChapterDataT, ChaptersT, NovelT } from "../types";
import MIME_TYPE from "./template/mimetype";
import CONTAINER_XML from "./template/META-INF/container";
import EBOOK_OPF from "./template/OEBPF/ebook";
import NAVIGATION_NCX from "./template/OEBPF/navigation";
import TOC_XHTML from "./template/OEBPF/content/toc";
import S_ID_XHTML from "./template/OEBPF/content/s[id]";
import EBOOK_CSS from "./template/OEBPF/css/ebook";
import COVER_JPEG from "./template/OEBPF/images/cover";
import COVER_XHTML from "./template/OEBPF/cover";

export const generateEPUB = async (novel: NovelT, chapters: ChapterDataT[]) => {
	const zip = new JSZip();

	zip.file("mimetype", MIME_TYPE());
	zip.file("META-INF/container.xml", CONTAINER_XML());

	const OEBPSFolder = zip.folder("OEBPS");
	if (!OEBPSFolder) throw new Error("Failed to create OEBPS folder");
	OEBPSFolder.file("cover.xhtml", COVER_XHTML(novel.title));
	OEBPSFolder.file("ebook.opf", EBOOK_OPF(novel.title, novel.authors || [], novel.description || "", novel.genres || [], chapters));
	OEBPSFolder.file("navigation.ncx", NAVIGATION_NCX(novel.title, novel.authors || [], chapters));
	OEBPSFolder.file("css/ebook.css", EBOOK_CSS());
	OEBPSFolder.file("images/cover.jpeg", await COVER_JPEG(novel.coverURL), { base64: true });

	const contentFolder = OEBPSFolder.folder("content");
	if (!contentFolder) throw new Error("Failed to create content folder");
	chapters.forEach((chapter, i) => {
		contentFolder.file(`s${i + 1}.xhtml`, S_ID_XHTML(i + 1, novel.title, novel.authors || [], novel.genres || [], chapter));
	});
	contentFolder.file("toc.xhtml", TOC_XHTML(chapters));

	return await zip.generateAsync({ type: "blob", mimeType: "application/epub+zip" })
}

export const getPropagandaHTML = () =>
	`<br />
<br />
<p>This novel was scraped using <a href="https://github.com/HanaDigital/NovelScraper">NovelScraper</a>, a free and open-source novel scraping tool.</p>
`;
