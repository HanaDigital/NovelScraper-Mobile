import { StackScreenProps } from "@react-navigation/stack";
import type { CompositeScreenProps } from '@react-navigation/native';
import { Image, StyleSheet, Text, View } from "react-native";
import { SourcesStackParamList } from "./sources/SourcesNavigator";
import { ScrollView, TouchableOpacity } from "react-native-gesture-handler";
import { useContext, useEffect, useState } from "react";
import { downloadNovelFullNovel, loadNovelFullNovel } from "../lib/sources/novelfull";
import { DatabaseContext } from "../contexts/DatabaseContext";
import { NovelT } from "../lib/types";
import { LibraryStackParamList } from "./library/LibraryNavigator";
import { assertUnreachable, roundNumber } from "../lib/utils";
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
import { stripDatabaseInfoFromNovel } from "../lib/sources/sources";

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
	}, [db.database]);

	const loadSourceNovel = async (novel: NovelT): Promise<NovelT | undefined> => {
		// TODO: Handle sources here
		switch (novel.source) {
			case "NovelFull":
				return await loadNovelFullNovel(novel.url, novel);
		}
		return assertUnreachable(novel.source);
	}

	const handleDownloadNovel = async () => {
		if (isLoadingNovel) return;
		// TODO: Handle sources here
		switch (novel.source) {
			case "NovelFull":
				const newNovel = await downloadNovelFullNovel(novel, db.updateDownloadStatus);
				setNovel(newNovel);
				db.saveNovel(newNovel);
				return;
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
		setNovel(prevNovel => stripDatabaseInfoFromNovel(prevNovel));
		if (!isDeleted) console.error("Failed to delete novel from database");
		else setInDatabase(false);
		// if (navigation.canGoBack()) navigation.goBack();
	}

	const handleCancelDownload = () => {
		// FIXME: Handle cancel download
	}

	if (!novel) return <Text>No Novel Selected!</Text>;
	return (
		<ScrollView style={styles.scrollView}>
			<View style={{ ...styles.novelInfo, opacity: isLoadingNovel ? 0.5 : 1 }}>
				<View style={styles.controls}>
					{(db.downloadStatus[novel.url] && !db.downloadStatus[novel.url].complete) &&
						<View style={styles.progress}>
							<View style={{
								...styles.progressBar,
								width: `${roundNumber((db.downloadStatus[novel.url].downloadedChapters
									/ db.downloadStatus[novel.url].totalChapters)
									* 100, 2)}%`
							}}
							></View>
							<Text>
								{`${roundNumber((db.downloadStatus[novel.url].downloadedChapters
									/ db.downloadStatus[novel.url].totalChapters)
									* 100, 2)}%`}
							</Text>
						</View>
					}
					<View style={styles.controlButtons}>
						{(novel.inLibrary && (!db.downloadStatus[novel.url] || db.downloadStatus[novel.url].complete)) &&
							<TouchableOpacity
								onPress={() => handleDownloadNovel()}
								disabled={isLoadingNovel}
							>
								<MaterialIcons name="download" color="green" size={28} />
							</TouchableOpacity>
						}
						{(!db.downloadStatus[novel.url] || db.downloadStatus[novel.url].complete) &&
							<TouchableOpacity
								onPress={() => inDatabase ? handleDeleteNovel() : handleSaveNovel()}
								disabled={isLoadingNovel}
							>
								<MaterialIcons name="save" color={inDatabase ? "red" : "green"} size={28} />
							</TouchableOpacity>
						}
					</View>
				</View>

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
					<Text style={styles.label}>Downloaded Chapters</Text>
					<Text style={styles.value}>{novel.downloadedChapters || "Unknown"}</Text>
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
	controls: {
		flexDirection: "row",
		justifyContent: "space-between",
		alignItems: "center",
		padding: 10,
	},
	progress: {
		width: "50%",
		height: 20,
		flexDirection: "row",
		gap: 10,
		backgroundColor: "lightgray",
	},
	progressBar: {
		backgroundColor: "#22272e",
		height: "100%",
	},
	controlButtons: {
		flex: 1,
		flexDirection: "row",
		justifyContent: "flex-end",
		gap: 20,
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
