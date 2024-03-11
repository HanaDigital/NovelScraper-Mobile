import RNFS from 'react-native-fs';
import { DatabaseT } from './types';

export const DOWNLOADS_URI = RNFS.DownloadDirectoryPath;

export const DATABASE_FILE_NAME = 'database.json';
export const DATABASE_URI = RNFS.DocumentDirectoryPath + `/${DATABASE_FILE_NAME}`;

export const saveFileToDownloads = async (fileName: string, content: string, encoding = "utf8"): Promise<boolean> => {
	try {
		const path = DOWNLOADS_URI + `/${fileName}`;
		await RNFS.writeFile(path, content, encoding);
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const saveDatabaseToFile = async (database: DatabaseT): Promise<boolean> => {
	try {
		await RNFS.writeFile(DATABASE_URI, JSON.stringify(database), "utf8");
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const loadDatabaseFromFile = async (): Promise<DatabaseT | undefined> => {
	try {
		const fileContent = await RNFS.readFile(DATABASE_URI, "utf8");
		return JSON.parse(fileContent) as DatabaseT;
	} catch (error) {
		console.error(error);
		return undefined;
	}
}
