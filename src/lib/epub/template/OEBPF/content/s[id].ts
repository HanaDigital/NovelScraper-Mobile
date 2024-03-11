import { ChapterDataT } from "../../../../types";

const S_ID_XHTML = (id: number, title: string, authors: string[], genres: string[], chapter: ChapterDataT) =>
	`<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>
  <head profile='http://dublincore.org/documents/dcmi-terms/'>
    <meta http-equiv='Content-Type' content='text/html;' />
    <title>${title} - ${chapter.title}</title>
    <meta name='DCTERMS.title' content='${title}' />
    <meta name='DCTERMS.language' content='en' scheme='DCTERMS.RFC4646' />
    <meta name='DCTERMS.source' content='NovelScraper' />
    <meta name='DCTERMS.issued' content='{$issued}' scheme='DCTERMS.W3CDTF'/>
    <meta name='DCTERMS.creator' content='${authors.join(", ")}'/>
    <meta name='DCTERMS.contributor' content='' />
    <meta name='DCTERMS.modified' content='{$issued}' scheme='DCTERMS.W3CDTF'/>
    <meta name='DCTERMS.provenance' content='' />
    <meta name='DCTERMS.subject' content='${genres.join(", ")}' />
    <link rel='schema.DC' href='http://purl.org/dc/elements/1.1/' hreflang='en' />
    <link rel='schema.DCTERMS' href='http://purl.org/dc/terms/' hreflang='en' />
    <link rel='schema.DCTYPE' href='http://purl.org/dc/dcmitype/' hreflang='en' />
    <link rel='schema.DCAM' href='http://purl.org/dc/dcam/' hreflang='en' />
    <link rel='stylesheet' type='text/css' href='../css/ebook.css' />
  </head>
  <body>
    <div id='s${id}'></div>
    <div>
		${chapter.content}
	</div>
  </body>
</html>
`;
export default S_ID_XHTML;
