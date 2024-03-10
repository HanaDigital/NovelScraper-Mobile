import { StackScreenProps } from "@react-navigation/stack";
import type { CompositeScreenProps } from '@react-navigation/native';
import { Image, StyleSheet, Text, View } from "react-native";
import { SourcesStackParamList } from "./sources/SourcesNavigator";
import { ScrollView, TouchableOpacity } from "react-native-gesture-handler";
import { useContext, useEffect, useState } from "react";
import { downloadChapter, downloadNovelFullNovel, loadNovelFullNovel } from "../lib/sources/novelfull";
import { DatabaseContext } from "../contexts/DatabaseContext";
import { NovelT } from "../lib/types";
import { LibraryStackParamList } from "./library/LibraryNavigator";
import { assertUnreachable } from "../lib/utils";
import { testEpubGen } from "../lib/epub/epub";
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';

type Props = CompositeScreenProps<
	StackScreenProps<SourcesStackParamList, "Novel">,
	StackScreenProps<LibraryStackParamList, "Novel">
>;
export default function NovelScreen({ route, navigation }: Props) {
	const db = useContext(DatabaseContext);

	const [isLoadingNovel, setIsLoadingNovel] = useState(false);
	const [inDatabase, setInDatabase] = useState(false);
	const [novel, setNovel] = useState(route.params.novel);

	const [showMoreDesc, setShowMoreDesc] = useState(false);

	useEffect(() => {
		// downloadNovelFullNovel(novel);
		// downloadChapter("Chapter 1", "https://novelfull.com/turns-out-im-from-a-real-aristocratic-family/chapter-1.html");
		test();


		const dbNovel = db.database?.novels[novel.url];
		if (dbNovel) {
			console.log("Loaded novel from database");
			setNovel(dbNovel);
			setInDatabase(true);
		}
		else {
			console.log("Novel not found in database, loading from source");
			loadNovel();
		}
	}, []);

	const test = async () => {
		const uri = await testEpubGen();
		// const isAvailable = await Sharing.isAvailableAsync();
		// if (isAvailable) {
		// 	await Sharing.shareAsync(uri, {
		// 		mimeType: "application/epub+zip",
		// 		dialogTitle: "Share this EPUB",
		// 		UTI: "org.idpf.epub-container",
		// 	});
		// } else {
		// 	console.log("Sharing not available");
		// }
	}

	const loadSourceNovel = async (novel: NovelT): Promise<NovelT | undefined> => {
		// TODO: Handle sources here
		switch (novel.source) {
			case "NovelFull":
				return await loadNovelFullNovel(novel.url, novel);
			case "BoxNovel":
				return undefined;	// FIXME: Add BoxNovel support
		}
		return assertUnreachable(novel.source);
	}

	const loadNovel = async () => {
		if (isLoadingNovel) return;
		setIsLoadingNovel(true);

		let loadedNovel = await loadSourceNovel(novel);

		if (loadedNovel) {
			setNovel(loadedNovel);
		}
		setIsLoadingNovel(false);
	}

	const handleSaveNovel = () => {
		if (isLoadingNovel) return;
		const isSaved = db.saveNovel(novel);
		if (!isSaved) console.error("Failed to save novel to database");
		else setInDatabase(true);
	}

	const handleDeleteNovel = () => {
		if (!db.database || !inDatabase || isLoadingNovel) return;
		const isDeleted = db.deleteNovel(novel);
		if (!isDeleted) console.error("Failed to delete novel from database");
		else setInDatabase(false);
	}

	if (!novel) return <Text>No Novel Selected!</Text>;
	return (
		<ScrollView style={styles.scrollView}>
			<View style={{ ...styles.novelInfo, opacity: isLoadingNovel ? 0.5 : 1 }}>
				<TouchableOpacity
					onPress={() => inDatabase ? handleDeleteNovel() : handleSaveNovel()}
					disabled={isLoadingNovel}
				>
					<MaterialIcons name="save" color={inDatabase ? "red" : "green"} size={28} />
				</TouchableOpacity>

				{(novel.coverURL || novel.thumbnailURL) &&
					<Image source={{ uri: novel.coverURL || novel.thumbnailURL }} style={styles.novelImage} />
				}

				<View>
					<Text style={styles.label}>Title</Text>
					<Text style={styles.value}>{novel.title}</Text>
				</View>

				<View>
					<Text style={styles.label}>Authors</Text>
					<Text style={styles.value}>{novel.authors?.join(", ")}</Text>
				</View>

				<View>
					<Text style={styles.label}>Genres</Text>
					<Text style={styles.value}>{novel.genres?.join(", ")}</Text>
				</View>

				<View>
					<Text style={styles.label}>Alternate Titles</Text>
					<Text style={styles.value}>{novel.alternateTitles?.join(", ")}</Text>
				</View>

				<View>
					<Text style={styles.label}>Description</Text>
					<View style={{ ...styles.descriptionView, maxHeight: showMoreDesc ? "100%" : 150 }}>
						<Text style={styles.value}>{novel.description}</Text>
					</View>
					<TouchableOpacity
						style={styles.viewMoreButton}
						onPress={() => setShowMoreDesc(v => !v)}
					>
						<Text>Show {showMoreDesc ? "Less" : "More"}</Text>
					</TouchableOpacity>
				</View>

				<View>
					<Text style={styles.label}>Latest Chapter</Text>
					<Text style={styles.value}>{novel.latestChapter}</Text>
				</View>

				<View>
					<Text style={styles.label}>Total Chapters</Text>
					<Text style={styles.value}>{novel.totalChapters || "Unknown"}</Text>
				</View>

				<View>
					<Text style={styles.label}>Status</Text>
					<Text style={styles.value}>{novel.status}</Text>
				</View>

				<View>
					<Text style={styles.label}>Rating</Text>
					<Text style={styles.value}>{novel.rating}</Text>
				</View>
			</View>
		</ScrollView>
	);
}

const styles = StyleSheet.create({
	scrollView: {
		flex: 1,
	},
	novelInfo: {
		flexDirection: "column",
		gap: 10,
	},
	novelImage: {
		width: 221,
		height: 324,
		resizeMode: "contain",
	},
	label: {
		fontWeight: "bold",
		fontSize: 14,
	},
	value: {
		fontSize: 18,
	},
	descriptionView: {
	},
	viewMoreButton: {
		padding: 2,
		paddingHorizontal: 5,
		marginTop: 10,
		borderRadius: 5,
		backgroundColor: "lightblue",
		elevation: 5,
		alignSelf: "center",
	}
});
