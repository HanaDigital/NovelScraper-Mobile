import { ChapterDataT } from "../../../types";

const NAVIGATION_NCX = (title: string, authors: string[], chapters: ChapterDataT[]) =>
	`<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE ncx PUBLIC '-//NISO//DTD ncx 2005-1//EN' 'http://www.daisy.org/z3986/2005/ncx-2005-1.dtd'>
<ncx xmlns='http://www.daisy.org/z3986/2005/ncx/'>
<head>
	<meta name='dtb:uid' content='0000-0000-0001'/>
	<meta name='dtb:depth' content='1'/>
	<meta name='dtb:totalPageCount' content='0'/>
	<meta name='dtb:maxPageNumber' content='0'/>
</head>
<docTitle><text>${title}</text></docTitle>
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
${chapters.map((chapter, i) =>
		`	<navPoint class='section' id='s${i + 1}' playOrder='${i + 3}'>
	<navLabel><text>${chapter.title}</text></navLabel>
	<content src='content/s${i + 1}.xhtml'/>
	</navPoint>
`).join("\n")}
</navMap>
</ncx>
`;
export default NAVIGATION_NCX;
