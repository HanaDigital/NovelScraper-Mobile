import { StyleSheet, Text, View } from "react-native";
import SafeLayout from "../components/SafeLayout";
import { useEffect } from "react";

export default function HomeScreen() {
	return (
		<SafeLayout>
			<View style={styles.container}>
				<Text>Home Screen</Text>
			</View>
		</SafeLayout>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		justifyContent: "center",
		alignItems: "center",
	},
});
