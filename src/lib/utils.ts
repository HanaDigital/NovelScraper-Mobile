
export const assertUnreachable = (x: never): never => {
	throw new Error("Didn't expect to get here");
};

export const downloadImageBlob = async (url: string) => {
	try {
		const res = await fetch(url);
		const blob = await res.blob();
		return blob;
	} catch (error) {
		console.error(error);
		return undefined;
	}
}

export const convertBlobToString = (blob: Blob): Promise<string> => {
	return new Promise<string>((resolve, reject) => {
		const fr = new FileReader();
		fr.onload = () => {
			if (!fr.result) return reject("Failed to read blob");
			resolve(fr.result as string);
		}
		fr.readAsText(blob);
	});
}

export const getFolderSafeString = (str: string): string => {
	return str.replace(/[^a-zA-Z0-9]/g, "_");
}

export const getFileSafeString = (str: string): string => {
	return str.replace(/[^a-zA-Z0-9\.]/g, "_");
}

export const roundNumber = (num: number, factor: number) => {
	return Math.round((num + Number.EPSILON) * (10 ** factor)) / (10 ** factor)
}
