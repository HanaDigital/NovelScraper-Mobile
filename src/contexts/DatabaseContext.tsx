import { Dispatch, ReactNode, SetStateAction, createContext, useEffect, useState } from "react";
import { DatabaseT, NovelT, SOURCES } from "../lib/types";
import { loadDatabaseFromFile, saveDatabaseToFile } from "../lib/fs";
import { AutoQueue } from "../lib/queue";
import clone from "clone";

type DatabaseContextT = {
	database: DatabaseT | undefined;
	setDatabase: Dispatch<SetStateAction<DatabaseT | undefined>>;

	saveNovel: (novel: NovelT) => boolean;
	deleteNovel: (novel: NovelT) => boolean;
}

export const DatabaseContext = createContext<DatabaseContextT>({} as DatabaseContextT);

export const DatabaseProvider = ({ children }: { children: ReactNode }) => {
	const [database, setDatabase] = useState<DatabaseT | undefined>(undefined);
	const [databaseSaveQueue, setDatabaseSaveQueue] = useState(new AutoQueue());

	useEffect(() => {
		loadDatabase();
	}, []);

	useEffect(() => {
		if (database) {
			saveDatabase(database);
		}
	}, [database]);

	const loadDatabase = async () => {
		const db = await loadDatabaseFromFile();
		if (db) {
			console.log("Loaded database from file");
			setDatabase(db);
		} else {
			console.log("Database not found, creating new database");
			const sources: any = clone(SOURCES);
			Object.keys(sources).forEach(key => {
				delete sources[key].logo;
			});
			const newDatabase: DatabaseT = {
				sources: sources,
				novels: {},
			};
			setDatabase(newDatabase);
		}
	}

	const saveNovel = (novel: NovelT) => {
		if (!database) return false;
		if (!database.sources[novel.source]) return false;
		setDatabase(prevDB => {
			if (!prevDB) return prevDB;
			prevDB.novels[novel.url] = novel;
			return { ...prevDB };
		});
		return true;
	}

	const deleteNovel = (novel: NovelT) => {
		if (!database) return false;
		if (!database.sources[novel.source]) return false;
		setDatabase(prevDB => {
			if (!prevDB) return prevDB;
			delete prevDB.novels[novel.url];
			return { ...prevDB };
		});
		return true;
	}

	const saveDatabase = (newDatabase: DatabaseT) => {
		databaseSaveQueue.enqueue(() => saveDatabaseToFile(newDatabase)).then(res => {
			if (res) console.log("Database saved successfully");
			else console.error("Failed to save database");
		});
	}

	return (
		<DatabaseContext.Provider value={{
			database, setDatabase,
			saveNovel, deleteNovel
		}}>
			{children}
		</DatabaseContext.Provider>
	)
}
