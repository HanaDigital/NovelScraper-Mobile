import { createStackNavigator } from "@react-navigation/stack"
import SourcesScreen from "./SourcesScreen";
import SourceScreen from "./SourceScreen";
import { NovelT, SourceT } from "../../lib/types";
import NovelScreen from "../NovelScreen";

export type SourcesStackParamList = {
	Sources: undefined;
	Source: { source: SourceT };
	Novel: { novel: NovelT };
};

const Stack = createStackNavigator<SourcesStackParamList>();

export default function SourcesNavigator() {
	return (
		<Stack.Navigator initialRouteName="Sources" screenOptions={{
			// header: ({ navigation, route, options, back }) => {
			// 	const title = getHeaderTitle(options, route.name);
			// 	console.log(route.name, title);
			// 	return (<Text>{title}</Text>);
			// }
		}}>
			<Stack.Screen name="Sources" component={SourcesScreen} />
			<Stack.Screen name="Source" component={SourceScreen} options={({ route }) => ({ title: route.params.source.name })} />
			<Stack.Screen name="Novel" component={NovelScreen} options={({ route }) => ({ title: route.params.novel.source })} />
		</Stack.Navigator>
	)
}
