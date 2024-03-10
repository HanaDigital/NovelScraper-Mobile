import { createStackNavigator } from "@react-navigation/stack"
import { NovelT } from "../../lib/types";
import LibraryScreen from "./LibraryScreen";
import NovelScreen from "../NovelScreen";

export type LibraryStackParamList = {
	Library: undefined;
	Novel: { novel: NovelT };
};

const Stack = createStackNavigator<LibraryStackParamList>();

export default function LibraryNavigator() {
	return (
		<Stack.Navigator initialRouteName="Library">
			<Stack.Screen name="Library" component={LibraryScreen} />
			<Stack.Screen name="Novel" component={NovelScreen} options={{ title: "Library" }} />
		</Stack.Navigator>
	)
}
