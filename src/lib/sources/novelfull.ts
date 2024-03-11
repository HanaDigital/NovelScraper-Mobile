const axios = require('axios/dist/browser/axios.cjs');
import { load } from "cheerio";
import { ChapterDataT, ChapterT, NovelT, SOURCES } from "../types";
import { generateEPUB, getPropagandaHTML } from "../epub/epub";
import { NOVEL_CHAPTERS_URI, readChaptersFromInternal, readFileFromInternal, saveChaptersToInternal, saveFileToInternal, saveNovelEpubToDownloads } from "../fs";
import { AutoQueue } from "../queue";
import { UpdateDownloadStatusT } from "../../contexts/DatabaseContext";
import { Dispatch, SetStateAction } from "react";

export const searchNovelFullNovels = async (query: string): Promise<NovelT[]> => {
	try {
		const searchURL = `${SOURCES.NovelFull.url}/search?keyword=${encodeURIComponent(query)}`;
		const res = await axios.get(searchURL);
		const $ = load(res.data);

		const novels: NovelT[] = [];
		$("#list-page .row").each((_, el) => {
			const novelEl = $(el);
			const titleEl = novelEl.find("h3.truyen-title a");
			const url = titleEl.attr("href");
			const title = titleEl.text().trim();
			if (!url || !title) return;
			const author = novelEl.find(".author").text().trim();
			const thumbnailURL = novelEl.find("img").attr("src");
			const novel: NovelT = {
				source: SOURCES.NovelFull.name,
				url: `${SOURCES.NovelFull.url}${url}`,
				title: title,
				authors: author ? [author] : [],
				thumbnailURL: thumbnailURL ? `${SOURCES.NovelFull.url}${thumbnailURL}` : undefined,
			};
			novels.push(novel);
		});

		return novels;
	} catch (error) {
		console.error(error);
		return [];
	}
}

export const loadNovelFullNovel = async (url: string, novelData?: NovelT): Promise<NovelT | undefined> => {
	try {
		const res = await axios.get(url);
		const $ = load(res.data);

		const novelInfoEl = $(".col-info-desc");
		const title = novelInfoEl.find(".desc > h3.title").first().text().trim();
		const rating = novelInfoEl.find(".small").text().trim().replace("Rating: ", "").replace(/from[\S\s]*?(?=\d)/, "from ");
		const description = novelInfoEl.find(".desc-text").text().trim();
		const latestChapter = novelInfoEl.find(".l-chapter > ul.l-chapters > li").first().text().trim();
		const coverURL = novelInfoEl.find(".info-holder .book img").attr("src");
		const authors = novelInfoEl.find(".info-holder > .info > div:first-of-type > a").map((_, el) => $(el).text().trim()).get();
		const alternateTitles = novelInfoEl.find(".info-holder .info > div:nth-of-type(2)").text().replace("Alternative names:", "").trim().split(", ");
		const genres = novelInfoEl.find(".info-holder .info > div:nth-of-type(3) > a").map((_, el) => $(el).text().trim()).get();
		const status = novelInfoEl.find(".info-holder .info > div:nth-of-type(5) > a").text().trim();

		const chaptersEl = $("#list-chapter");
		let chaptersPerPage = 0;
		$(".row ul.list-chapter").each((_, el) => {
			chaptersPerPage += $(el).find("li").length;
		});

		let totalPages = 1;
		let totalChapters = 0;
		const lastPageURL = chaptersEl.find("ul.pagination > li.last").find("a").attr("href");
		if (lastPageURL) {
			// Get total chapters if there are multiple pages
			totalPages = Number.parseInt(lastPageURL.match(/page=(\d+)/)?.[1] || "1");
			totalChapters = chaptersPerPage * (totalPages - 1);

			try {
				const lastPageRes = await axios.get(`${SOURCES.NovelFull.url}${lastPageURL}`);
				const lastPage$ = load(lastPageRes.data);
				lastPage$("#list-chapter .row ul.list-chapter").each((_, el) => {
					totalChapters += $(el).find("li").length;
				});
			} catch (error) {
				console.error("Error while getting total chapters:", error);
			}
		} else {
			// Get total chapters if there is only one page
			totalChapters = chaptersPerPage;
		}

		const novel: NovelT = {
			source: SOURCES.NovelFull.name,
			url,
			title,
			authors,
			genres,
			alternateTitles,
			description,
			coverURL: coverURL ? `${SOURCES.NovelFull.url}${coverURL}` : undefined,
			latestChapter,
			totalChapters,
			status,
			rating,
		};

		return novelData ? { ...novelData, ...novel } : novel;
	} catch (error) {
		console.error(error);
		return novelData;
	}
}

export const downloadNovelFullNovel = async (novel: NovelT, updateDownloadStatus: UpdateDownloadStatusT, isCancel: boolean) => {
	let totalChapters = novel.totalChapters || 0;
	let downloadedChapters = novel.downloadedChapters || 0;

	try {
		console.log(`Downloading novel: ${novel.title}`);
		updateDownloadStatus(novel.url, totalChapters, downloadedChapters, false);

		let res = await axios.get(novel.url);
		let $ = load(res.data);

		const lastPageURL = $("#list-chapter ul.pagination > li.last").find("a").attr("href");
		const totalPages = Number.parseInt(lastPageURL?.match(/page=(\d+)/)?.[1] || "1");

		// Get all chapter links
		console.log(`Getting chapter links from ${totalPages} pages`);
		const chapterLinks: ChapterT[] = [];
		for (let i = 1; i <= totalPages; i++) {
			if (isCancel) throw new Error("Download cancelled");
			console.log(`Getting chapter links from page ${i} of ${totalPages}`);
			$("#list-chapter .row ul.list-chapter > li").each((_, el) => {
				const chapterEl = $(el);
				const title = chapterEl.find("a").text().trim();
				const url = chapterEl.find("a").attr("href");
				if (title && url) chapterLinks.push({ title, url: `${SOURCES.NovelFull.url}${url}` });
				else throw new Error("Failed to get chapter title or url");
			});

			if (i + 1 > totalPages) break;
			res = await axios.get(`${novel.url}?page=${i}`);
			$ = load(res.data);
		}
		totalChapters = chapterLinks.length;
		updateDownloadStatus(novel.url, totalChapters, downloadedChapters, false);
		console.log(`Total chapters: ${totalChapters}`);
		if (isCancel) throw new Error("Download cancelled");

		let chapters: ChapterDataT[] = [];
		// Load downloaded chapters from cache if any
		if (novel.downloadedChapters) {
			const chaptersJsonStr = await readChaptersFromInternal(novel.url);
			if (chaptersJsonStr) chapters = JSON.parse(chaptersJsonStr) as ChapterDataT[];
		}

		// Download chapters
		downloadedChapters = 0;
		const chaptersSaveQueue = new AutoQueue();
		for (let i = 0; i < chapterLinks.length; i++) {
			if (isCancel) throw new Error("Download cancelled");
			const chapter = chapterLinks[i];
			if (chapters.length > i && chapters[i].url === chapter.url && chapters[i].title === chapter.title) {
				downloadedChapters++;
				console.log(`Chapter ${i + 1} of ${chapterLinks.length} already downloaded`);
				continue;
			} else if (chapters.length > i) {
				chapters.splice(i, 1);
			}
			console.log(`Downloading chapter ${i + 1} of ${chapterLinks.length}`);
			const content = await downloadNovelFullChapter(chapter.title, chapter.url);
			if (!content) throw new Error("Failed to download chapter content");
			chapters.push({ ...chapter, content });

			// Cache downloaded chapters to file
			chaptersSaveQueue.enqueue(() => saveChaptersToInternal(novel.url, JSON.stringify(chapters)));
			downloadedChapters++;
			updateDownloadStatus(novel.url, totalChapters, downloadedChapters, false);
		}
		updateDownloadStatus(novel.url, totalChapters, downloadedChapters, false);

		// Generate and save EPUB
		if (isCancel) throw new Error("Download cancelled");
		console.log("Generating EPUB");
		const epubBlob = await generateEPUB(novel, chapters);
		await saveNovelEpubToDownloads(novel.title, epubBlob);
		novel.isDownloaded = true;
	} catch (error) {
		console.error(error);
	}

	novel.totalChapters = totalChapters;
	novel.downloadedChapters = downloadedChapters;
	updateDownloadStatus(novel.url, totalChapters, downloadedChapters, true);
	return novel;
}

const downloadNovelFullChapter = async (title: string, url: string) => {
	try {
		const res = await axios.get(url);
		const $ = load(res.data);

		let contentEl = $("#chapter-content");

		// Remove scripts and iframes
		contentEl.find("script").remove();
		contentEl.find("iframe").remove();

		// Remove ads, classes, ids, styles, comments, etc.
		let content = contentEl.html();
		if (!content) throw new Error("Failed to get chapter content:");
		content = content
			.replace(/class=".*?"/g, "")
			.replace(/id=".*?"/g, "")
			.replace(/style=".*?"/g, "")
			.replace(/data-.*?=".*?"/g, "")
			.replace(/<!--.*?-->/g, "")
			.replace(/<div align="left"[\s\S]*?If you find any errors \( Ads popup, ads redirect, broken links, non-standard content, etc.. \)[\s\S]*?<\/div>/g, "")
			;

		const titleHTML = `<h1>${title}</h1>`;
		const propagandaHTML = getPropagandaHTML();

		content = titleHTML + content + propagandaHTML;

		return content;
	} catch (error) {
		console.error(error);
		return undefined;
	}
}
