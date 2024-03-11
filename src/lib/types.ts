// TODO: Add Source types here
export const SOURCES = {
	"NovelFull": {
		name: "NovelFull",
		url: "https://novelfull.com",
		logo: require("../assets/images/novelfull-logo.png")
	},
	// "BoxNovel": {
	// 	name: "BoxNovel",
	// 	url: "https://boxnovel.com",
	// 	logo: require("../assets/images/boxnovel-logo.png")
	// }
} as const;

export type SourceNamesT = keyof typeof SOURCES;
export type SourceURLsT = typeof SOURCES[SourceNamesT]["url"];

export type NovelT = {
	source: SourceNamesT;
	url: string;
	title: string;
	authors?: string[];
	genres?: string[];
	alternateTitles?: string[];
	description?: string;
	coverURL?: string;
	thumbnailURL?: string;
	latestChapter?: string;
	totalChapters?: number;
	downloadedChapters?: number;
	status?: string;
	rating?: string;
	isDownloaded?: boolean;
	inLibrary?: boolean;
}

export type SourceT = {
	name: SourceNamesT;
	url: SourceURLsT;
}

export type DatabaseT = {
	sources: {
		[sourceName in SourceNamesT]: SourceT;
	}
	novels: { [url: string]: NovelT }
}

export type ChapterT = {
	title: string;
	url: string;
}

export type ChapterDataT = ChapterT & {
	content: string;
}

export type ChaptersT = {
	source: string;
	novelURL: string;
	chapters: ChapterDataT[];
}
