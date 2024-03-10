import { useState } from "react";
import { Image, StyleSheet, Text, View } from "react-native";
import { FlatList, TextInput, TouchableOpacity } from "react-native-gesture-handler";
import { NovelT } from "../../lib/types";
import { searchNovelFull } from "../../lib/sources/novelfull";
import { StackScreenProps } from "@react-navigation/stack";
import { SourcesStackParamList } from "./SourcesNavigator";
import { assertUnreachable } from "../../lib/utils";

type Props = StackScreenProps<SourcesStackParamList, "Source">;
export default function SourceScreen({ route, navigation }: Props) {
	const source = route.params.source;
	const [search, setSearch] = useState("");
	const [isSearching, setIsSearching] = useState(false);
	const [searchedNovels, setSearchedNovels] = useState<NovelT[]>([]);

	const handleSourceSearch = async (search: string): Promise<NovelT[]> => {
		// TODO: Handle sources here
		switch (source.name) {
			case "NovelFull":
				return await searchNovelFull(search);
			case "BoxNovel":
				return [];	// FIXME: Add BoxNovel support
		}
		return assertUnreachable(source.name);
	}

	const handleSearch = async () => {
		if (isSearching) return;
		setIsSearching(true);
		const novels = await handleSourceSearch(search);
		setSearchedNovels(novels);
		setIsSearching(false);
	}

	return (
		<View style={styles.container}>
			<TextInput
				style={styles.searchInput}
				placeholder="Search"
				value={search}
				onChange={(e) => setSearch(e.nativeEvent.text)}
				onSubmitEditing={handleSearch}
				editable={!isSearching}
				selectTextOnFocus={!isSearching}
			/>
			{(searchedNovels.length === 0 && !!search && !isSearching) && (
				<Text style={styles.emptyText}>NO NOVELS FOUND, TRY AGAIN</Text>
			)}
			{isSearching && (
				<Text style={styles.emptyText}>SEARCHING...</Text>
			)}
			<FlatList
				style={styles.flatList}
				data={searchedNovels}
				renderItem={({ item }) => (
					<TouchableOpacity
						key={item.url}
						style={styles.novelButton}
						onPress={() => navigation.navigate("Novel", { novel: item })}
					>
						<Image source={{ uri: item.thumbnailURL }} style={styles.novelImage} />
						<View style={styles.novelInfo}>
							<Text style={styles.novelTitle}>{item.title}</Text>
						</View>
					</TouchableOpacity>
				)}
			/>
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		flexDirection: "column",
	},
	searchInput: {
		padding: 10,
		borderRadius: 5,
		backgroundColor: "white",
		elevation: 2,
		marginHorizontal: 10,
		marginTop: 10,
	},
	emptyText: {
		textAlign: "center",
		marginTop: 10,
		fontSize: 14,
		color: "gray",
		fontWeight: "bold",
	},
	flatList: {
		padding: 10,
		flex: 1,
		flexDirection: "column",
		gap: 10,
	},
	novelButton: {
		flexDirection: "row",
		backgroundColor: "white",
		borderRadius: 5,
		elevation: 5,
		overflow: "hidden",
		marginBottom: 10,
	},
	novelImage: {
		width: 182,
		height: 82,
		resizeMode: "contain",
	},
	novelInfo: {
		flex: 1,
		padding: 10,
	},
	novelTitle: {
		fontWeight: "bold",
	}
});
