import { NovelT } from "../types";

export const stripDatabaseInfoFromNovel = (novel: NovelT): NovelT => {
	let newNovel = { ...novel };
	delete newNovel.downloadedChapters;
	delete newNovel.isDownloaded;
	delete newNovel.inLibrary;
	return newNovel;
}
