import { NovelT } from "../types";
import { NativeModules } from "react-native";
const { ScraperModule } = NativeModules;

export const getNovelPaginationPages = (
	pagePrefixURL: string,
	startPage: number,
	totalPage: number,
	callback: (error: any, novelPaginationPages: string[]) => void
) => {
	ScraperModule.getNovelPaginationPages(pagePrefixURL, startPage, totalPage, callback)
}

export const getNovelChapterPages = (
	chapterLinks: string[],
	callback: (error: any, novelPaginationPages: string[]) => void
) => {
	ScraperModule.getNovelChapterPages(chapterLinks, callback);
}

export const stripDatabaseInfoFromNovel = (novel: NovelT): NovelT => {
	let newNovel = { ...novel };
	delete newNovel.downloadedChapters;
	delete newNovel.isDownloaded;
	delete newNovel.inLibrary;
	return newNovel;
}
