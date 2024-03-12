import { Image, StyleSheet, Text, View } from "react-native";
import { useCallback, useContext, useEffect, useState } from "react";
import { FlatList, TextInput, TouchableOpacity } from "react-native-gesture-handler";
import { StackScreenProps } from "@react-navigation/stack";
import { LibraryStackParamList } from "./LibraryNavigator";
import { useFocusEffect } from "@react-navigation/native";
import useDatabaseStore from "../../stores/databaseStore";

type Props = StackScreenProps<LibraryStackParamList, "Library">;
export default function LibraryScreen({ navigation }: Props) {
	const dbNovels = useDatabaseStore(state => state.database?.novels);

	const [search, setSearch] = useState("");
	const [filteredNovels, setFilteredNovels] = useState(Object.values(dbNovels || {}));

	useFocusEffect(useCallback(() => {
		setSearch("");
		setFilteredNovels(Object.values(dbNovels || {}));
	}, [dbNovels]));

	const handleSearch = () => {
		if (search === "") {
			setFilteredNovels(Object.values(dbNovels || {}));
		} else {
			setFilteredNovels(Object.values(dbNovels || {})
				.filter(novel => novel.title.toLowerCase().includes(search.toLowerCase()))
			);
		}
	}

	return (
		<View style={styles.container}>
			<TextInput
				style={styles.searchInput}
				placeholder="Search"
				value={search}
				onChange={(e) => setSearch(e.nativeEvent.text)}
				onSubmitEditing={handleSearch}
			/>
			{filteredNovels.length === 0 && (
				<Text style={styles.emptyText}>
					{!!search ? "NO NOVELS FOUND" : "NO NOVELS SAVED YET"}
				</Text>
			)}
			<FlatList
				style={styles.flatList}
				data={filteredNovels}
				renderItem={({ item }) => (
					<TouchableOpacity
						key={item.url}
						style={styles.novelButton}
						onPress={() => navigation.navigate("Novel", { novel: item })}
					>
						<Image source={{ uri: item.coverURL }} style={styles.novelImage} />
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
		marginBottom: 5,
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
		paddingTop: 5,
		flex: 1,
		flexDirection: "column",
		gap: 10,
	},
	novelButton: {
		flexDirection: "row",
		backgroundColor: "white",
		borderRadius: 5,
		elevation: 2,
		overflow: "hidden",
		marginBottom: 10,
	},
	novelImage: {
		width: 221 * 0.7,
		height: 324 * 0.7,
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
