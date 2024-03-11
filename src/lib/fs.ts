import RNFS from 'react-native-fs';
import { DatabaseT } from './types';
import { convertBlobToString, getFileSafeString, getFolderSafeString } from './utils';

export const DOWNLOADS_URI = RNFS.DownloadDirectoryPath;
export const INTERNAL_URI = RNFS.DocumentDirectoryPath;

export const DATABASE_FILE_NAME = 'database.json';
export const DATABASE_URI = INTERNAL_URI + `/${DATABASE_FILE_NAME}`;

export const NOVEL_URI = (novelURL: string) => `${INTERNAL_URI}/${getFolderSafeString(novelURL)}`;
export const NOVEL_CHAPTERS_URI = (novelURL: string) => `${INTERNAL_URI}/${getFolderSafeString(novelURL)}/chapters.json`;

export const saveNovelEpubToDownloads = async (title: string, epub: Blob): Promise<boolean> => {
	try {
		const epubString = await convertBlobToString(epub);
		return await saveFileToDownloads(`${title}.epub`, epubString, "base64");
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const saveChaptersToInternal = async (novelURL: string, chapters: string): Promise<boolean> => {
	try {
		return await saveFileToInternal(NOVEL_CHAPTERS_URI(novelURL), chapters);
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const readChaptersFromInternal = async (novelURL: string): Promise<string | undefined> => {
	try {
		return await readFileFromInternal(NOVEL_CHAPTERS_URI(novelURL));
	} catch (error) {
		console.error(error);
		return undefined;
	}
}

export const deleteNovelFromInternal = async (novelURL: string): Promise<boolean> => {
	try {
		const novelURI = NOVEL_URI(novelURL);
		const exists = await RNFS.exists(novelURI);
		if (exists) await RNFS.unlink(novelURI);
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const saveDatabaseToInternal = async (database: DatabaseT): Promise<boolean> => {
	try {
		await RNFS.writeFile(DATABASE_URI, JSON.stringify(database), "utf8");
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const loadDatabaseFromInternal = async (): Promise<DatabaseT | undefined> => {
	try {
		const fileContent = await RNFS.readFile(DATABASE_URI, "utf8");
		return JSON.parse(fileContent) as DatabaseT;
	} catch (error) {
		console.error(error);
		return undefined;
	}
}

export const saveFileToDownloads = async (fileName: string, content: string, encoding = "utf8"): Promise<boolean> => {
	try {
		const fileURI = DOWNLOADS_URI + `/${getFileSafeString(fileName)}`;
		const exists = await RNFS.exists(fileURI);
		if (exists) await RNFS.unlink(fileURI);
		await RNFS.writeFile(fileURI, content, encoding);
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const saveFileToInternal = async (filePathURI: string, content: string, encoding = "utf8"): Promise<boolean> => {
	try {
		const path = filePathURI.replace(/\/[^\/]*?$/, '');
		const pathExists = await RNFS.exists(path);
		if (!pathExists) await RNFS.mkdir(path);
		await RNFS.writeFile(filePathURI, content, encoding);
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const readFileFromInternal = async (filePathURI: string, encoding = "utf8"): Promise<string | undefined> => {
	try {
		const pathExists = await RNFS.exists(filePathURI);
		if (!pathExists) {
			console.log(`Didn't find ${filePathURI} in internal storage`);
			return undefined;
		}
		return await RNFS.readFile(filePathURI, encoding);
	} catch (error) {
		console.error(error);
		return undefined;
	}
}
