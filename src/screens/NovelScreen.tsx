import { StackScreenProps } from "@react-navigation/stack";
import type { CompositeScreenProps } from '@react-navigation/native';
import { Image, StyleSheet, Text, View } from "react-native";
import { SourcesStackParamList } from "./sources/SourcesNavigator";
import { ScrollView, TouchableOpacity } from "react-native-gesture-handler";
import { useContext, useEffect, useState } from "react";
import { downloadNovelFullNovel, fetchNovelFullNovel } from "../lib/sources/novelfull";
import { NovelT } from "../lib/types";
import { LibraryStackParamList } from "./library/LibraryNavigator";
import { assertUnreachable, roundNumber } from "../lib/utils";
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
import { stripDatabaseInfoFromNovel } from "../lib/sources/sources";
import useDatabaseStore from "../stores/databaseStore";

type Props = CompositeScreenProps<
	StackScreenProps<SourcesStackParamList, "Novel">,
	StackScreenProps<LibraryStackParamList, "Novel">
>;
export default function NovelScreen({ route, navigation }: Props) {
	const dbNovel = useDatabaseStore(state => state.database?.novels[route.params.novel.url]);
	const dbNovelStatus = useDatabaseStore(state => state.novelStatus[route.params.novel.url]);
	const dbSetNovel = useDatabaseStore(state => state.setNovel);
	const dbDeleteNovel = useDatabaseStore(state => state.deleteNovel);
	const dbCancelNovelDownload = useDatabaseStore(state => state.cancelNovelDownload[route.params.novel.url]);
	const dbSetCancelNovelDownload = useDatabaseStore(state => state.setCancelNovelDownload);

	const [isLoadingNovel, setIsLoadingNovel] = useState(false);
	const [novel, setNovel] = useState(route.params.novel);

	const [showMoreDesc, setShowMoreDesc] = useState(false);

	useEffect(() => {
		if (dbNovel) {
			console.log("Loaded novel from database");
			setNovel(dbNovel);
		}
		else {
			console.log("Novel not found in database, loading from source");
			fetchNovelFromSource();
		}
	}, [dbNovel]);

	const loadSourceNovel = async (novel: NovelT): Promise<NovelT | undefined> => {
		// TODO: Handle sources here
		switch (novel.source) {
			case "NovelFull":
				return await fetchNovelFullNovel(novel.url, novel);
		}
		return assertUnreachable(novel.source);
	}

	const handleDownloadNovel = async () => {
		if (isLoadingNovel) return;
		// TODO: Handle sources here
		switch (novel.source) {
			case "NovelFull":
				await downloadNovelFullNovel(novel);
				return;
		}
		return assertUnreachable(novel.source);
	}

	const fetchNovelFromSource = async () => {
		if (isLoadingNovel) return;
		setIsLoadingNovel(true);
		const loadedNovel = await loadSourceNovel(novel);
		if (loadedNovel) setNovel(stripDatabaseInfoFromNovel(loadedNovel));
		setIsLoadingNovel(false);
	}

	const handleSaveNovel = () => {
		if (isLoadingNovel) return;
		novel.inLibrary = true;
		dbSetNovel(novel);
	}

	const handleDeleteNovel = () => {
		if (!novel.inLibrary) return;
		dbDeleteNovel(novel);
		setNovel(prevNovel => stripDatabaseInfoFromNovel(prevNovel));
		// if (navigation.canGoBack()) navigation.goBack();
	}

	const handleCancelDownload = () => {
		dbSetCancelNovelDownload(novel.url, true);
	}

	if (!novel) return <Text>No Novel Selected!</Text>;
	return (
		<ScrollView style={styles.scrollView}>
			<View style={{ ...styles.novelInfo, opacity: isLoadingNovel ? 0.5 : 1 }}>
				<View style={styles.controls}>
					{(dbNovelStatus && !dbNovelStatus.complete) &&
						<View style={styles.progress}>
							<View style={{
								...styles.progressBar,
								width: `${roundNumber((dbNovelStatus.downloadedChapters
									/ dbNovelStatus.totalChapters)
									* 100, 2)}%`
							}}
							></View>
							<Text>
								{`${roundNumber((dbNovelStatus.downloadedChapters
									/ dbNovelStatus.totalChapters)
									* 100, 2)}%`}
							</Text>
						</View>
					}
					<View style={styles.controlButtons}>
						{(dbNovelStatus && !dbNovelStatus.complete && !dbCancelNovelDownload) &&
							<TouchableOpacity
								onPress={() => handleCancelDownload()}
								disabled={isLoadingNovel}
							>
								<MaterialIcons name="cancel" color="red" size={28} />
							</TouchableOpacity>
						}
						{(novel.inLibrary && (!dbNovelStatus || dbNovelStatus.complete)) &&
							<TouchableOpacity
								onPress={() => handleDownloadNovel()}
								disabled={isLoadingNovel}
							>
								<MaterialIcons name="download" color="green" size={28} />
							</TouchableOpacity>
						}
						{(!dbNovelStatus || dbNovelStatus.complete) &&
							<TouchableOpacity
								onPress={() => novel.inLibrary ? handleDeleteNovel() : handleSaveNovel()}
								disabled={isLoadingNovel}
							>
								<MaterialIcons name="save" color={novel.inLibrary ? "red" : "green"} size={28} />
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
