import { DatabaseT } from './types';
import { AutoQueue } from './queue';

export const DATABASE_FILE_NAME = 'database.json';

export const saveDatabaseToFile = async (database: DatabaseT): Promise<boolean> => {
	try {
		// const databaseUri = databaseURI();
		// const fileContent = JSON.stringify(database);
		// await FileSystem.writeAsStringAsync(databaseUri, fileContent, { encoding: FileSystem.EncodingType.UTF8 });
		throw new Error('Not implemented');
		return true;
	} catch (error) {
		console.error(error);
		return false;
	}
}

export const loadDatabaseFromFile = async (): Promise<DatabaseT | undefined> => {
	try {
		// const databaseUri = databaseURI();
		// const fileContent = await FileSystem.readAsStringAsync(databaseUri, { encoding: FileSystem.EncodingType.UTF8 });
		// return JSON.parse(fileContent) as DatabaseT;
		throw new Error('Not implemented');
		return {} as DatabaseT;
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
