import { DatabaseT } from './types';
import { AutoQueue } from './queue';
import RNFS from 'react-native-fs';

export const DATABASE_FILE_NAME = 'database.json';
export const databaseURI = () => RNFS.DocumentDirectoryPath + `/${DATABASE_FILE_NAME}`;

export const saveDatabaseToFile = async (database: DatabaseT): Promise<boolean> => {
	try {
		const databaseUri = databaseURI();
		await RNFS.writeFile(databaseUri, JSON.stringify(database), 'utf8');
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const loadDatabaseFromFile = async (): Promise<DatabaseT | undefined> => {
	try {
		const databaseUri = databaseURI();
		const fileContent = await RNFS.readFile(databaseUri, 'utf8');
		return JSON.parse(fileContent) as DatabaseT;
	} catch (error) {
		console.error(error);
		return undefined;
	}
}

export const testQueue = () => {
	const aQueue = new AutoQueue();
	const test = (num: number, delay: number) => new Promise((resolve, reject) => {
		setTimeout(() => {
			console.log(`Test ${num} after ${delay}ms`);
			resolve(true);
		}, delay);
	});
	aQueue.enqueue(() => test(1, 5000));
	aQueue.enqueue(() => test(2, 5000));
	aQueue.enqueue(() => test(3, 5000));
	aQueue.enqueue(() => test(4, 5000));
	aQueue.enqueue(() => test(5, 5000)).then(res => console.log(res));
}
