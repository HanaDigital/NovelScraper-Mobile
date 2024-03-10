import { StackScreenProps } from "@react-navigation/stack";
import { StyleSheet, Text, View } from "react-native";
import { SourcesStackParamList } from "./SourcesNavigator";
import { ScrollView, TouchableOpacity } from "react-native-gesture-handler";
import ImageAutoHeight from "../../components/ImageAutoHeight";
import { useContext, useEffect, useState } from "react";
import { DatabaseContext } from "../../contexts/DatabaseContext";
import { testQueue } from "../../lib/database";
import { SOURCES } from "../../lib/types";

type Props = StackScreenProps<SourcesStackParamList, "Sources">;
export default function SourcesScreen({ navigation }: Props) {
	const db = useContext(DatabaseContext)
	const [imageStyle, setImageStyle] = useState({ width: 0, height: "auto" });

	const onLayout = (event: any) => {
		var { width } = event.nativeEvent.layout;
		setImageStyle({ width: width, height: "auto" });
	}

	return (
		<ScrollView style={styles.scrollView}>
			<View style={styles.container}>
				{Object.values(db.database?.sources || {}).map((source, i) => (
					<TouchableOpacity
						key={source.url}
						style={styles.button}
						onLayout={onLayout}
						onPress={() => navigation.navigate("Source", { source })}
					>
						<ImageAutoHeight style={imageStyle} source={SOURCES[source.name].logo} />
						<Text style={styles.buttonText}>{source.name}</Text>
					</TouchableOpacity>
				))}
			</View>
		</ScrollView>
	);
}

const styles = StyleSheet.create({
	scrollView: {
		flex: 1,
		display: "flex",
		flexDirection: "column",
	},
	container: {
		flex: 1,
		flexDirection: "row",
		flexWrap: "wrap",
		marginHorizontal: "auto",
		gap: 20,
		padding: 10,
		paddingBottom: 20,
	},
	button: {
		minWidth: "47%",
		backgroundColor: "#ffffff",
		elevation: 5,
		borderRadius: 5,
		overflow: "hidden",
	},
	buttonText: {
		textAlign: "center",
		fontSize: 16,
		padding: 5,
		fontWeight: "bold",
		color: "#303030",
	},
});
