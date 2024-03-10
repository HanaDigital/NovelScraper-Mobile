
export const getPropagandaHTML = () => {
	return `
		<br />
		<br />
		<p>This novel was scraped using <a href="https://github.com/HanaDigital/NovelScraper">NovelScraper</a>, a free and open-source novel scraping tool.</p>
	`;
}

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
