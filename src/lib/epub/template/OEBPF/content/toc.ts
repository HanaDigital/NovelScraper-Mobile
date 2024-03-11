import { ChapterDataT } from "../../../../types";

const TOC_XHTML = (chapters: ChapterDataT[]) =>
	`<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>

<head>
  <title>Table of Contents</title>
  <link rel='stylesheet' type='text/css' href='../css/ebook.css' />
</head>

<body>
  <div class='contents'>
    <h1>Table of Contents</h1>
${chapters.map((chapter, i) => `    <a href='s${i + 1}.xhtml'>${chapter.title}</a><br/>`).join("\n")}
  </div>
</body>

</html>
`;
export default TOC_XHTML;
