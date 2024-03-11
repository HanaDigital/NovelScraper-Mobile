import { downloadImageBlob } from "../../../../utils";

const COVER_JPEG = async (coverURL: string | undefined) => {
	let coverBlob: Blob | string = "";
	try {
		if (coverURL) coverBlob = await downloadImageBlob(coverURL) || "";
		return coverBlob;
	} catch (error) {
		console.error(error);
		return "";
	}
}
export default COVER_JPEG;
