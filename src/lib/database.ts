import clone from "clone";
import { loadDatabaseFromInternal, saveDatabaseToInternal } from "./fs";
import { DatabaseT, SOURCES, SourceNamesT } from "./types";
import { AutoQueue } from "./queue";
import { DeepWritable } from "ts-essentials";

const databaseSaveQueue = new AutoQueue();

export const loadDatabase = async () => {
	const sources: DeepWritable<typeof SOURCES> = clone(SOURCES);

	const db = await loadDatabaseFromInternal();
	if (db) {
		console.log("Loaded database from file");
		// Add missing sources if any
		const sourceKeys = Object.keys(sources) as SourceNamesT[];
		sourceKeys.forEach((sourceKey) => {
			if (!db.sources[sourceKey]) {
				console.log(`Source ${sourceKey} not found in database, adding it`);
				delete sources[sourceKey].logo;
				db.sources[sourceKey] = sources[sourceKey];
			}
		});
		return db;
	} else {
		console.log("Database not found, creating new database");
		const sourceKeys = Object.keys(sources) as SourceNamesT[];
		sourceKeys.forEach((sourceKey) => {
			delete sources[sourceKey].logo;
		});
		const newDatabase: DatabaseT = {
			sources: sources,
			novels: {},
		};
		return newDatabase;
	}
}

export const saveDatabase = (newDatabase: DatabaseT) => {
	databaseSaveQueue.enqueue(() => saveDatabaseToInternal(newDatabase)).then(res => {
		if (res) console.log("Database saved successfully");
		else console.error("Failed to save database");
	});
}
