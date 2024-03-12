import { create } from "zustand";
import { DatabaseT, NovelT } from "../lib/types";
import { loadDatabase, saveDatabase } from "../lib/database";

type NovelStatusT = {
	[novelURL: string]: {
		totalChapters: number;
		downloadedChapters: number;
		complete: boolean;
	}
}

type State = {
	database: DatabaseT | undefined;
	novelStatus: NovelStatusT;
	cancelNovelDownload: { [novelURL: string]: boolean };
}

type Action = {
	setNovel: (novel: NovelT) => void;
	deleteNovel: (novel: NovelT) => void;
	setNovelStatus: (novelURL: string, totalChapters: number, downloadedChapters: number, complete?: boolean) => void;
	deleteNovelStatus: (novelURL: string) => void;
	setCancelNovelDownload: (novelURL: string, cancel: boolean) => void;
}

const useDatabaseStore = create<State & Action>((set) => ({
	database: undefined,
	novelStatus: {},
	cancelNovelDownload: {},
	setNovel: (novel: NovelT) => set(state => {
		if (!state.database) return { database: state.database };
		const newDatabase = {
			...state.database,
			novels: {
				...state.database.novels,
				[novel.url]: novel
			}
		};
		saveDatabase(newDatabase);
		return { database: newDatabase }
	}),
	deleteNovel: (novel: NovelT) => set(state => {
		if (!state.database) return { database: state.database };
		const novels = { ...state.database?.novels };
		delete novels[novel.url];
		const newDatabase = {
			...state.database,
			novels: novels
		}
		saveDatabase(newDatabase);
		return { database: newDatabase }
	}),
	setNovelStatus: (novelURL, totalChapters, downloadedChapters, complete = false) => set(state => ({
		novelStatus: {
			...state.novelStatus,
			[novelURL]: {
				totalChapters,
				downloadedChapters,
				complete
			}
		}
	})),
	deleteNovelStatus: (novelURL) => set(state => {
		const newNovelStatus = { ...state.novelStatus };
		delete newNovelStatus[novelURL];
		return { novelStatus: newNovelStatus };
	}),
	setCancelNovelDownload: (novelURL, cancel) => set(state => (
		{ cancelNovelDownload: { ...state.cancelNovelDownload, [novelURL]: cancel } }
	)),
}));

loadDatabase().then(database => {
	useDatabaseStore.setState({ database });
	saveDatabase(database);
});

export default useDatabaseStore;
