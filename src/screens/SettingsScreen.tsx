import { StyleSheet, Text, View } from "react-native";
import SafeLayout from "../components/SafeLayout";

export default function SettingsScreen() {
	return (
		<SafeLayout>
			<View style={styles.container}>
				<Text>Settings Screen</Text>
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
