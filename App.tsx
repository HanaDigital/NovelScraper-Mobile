import 'react-native-gesture-handler';
import { StyleSheet, Text, View } from "react-native";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { NavigationContainer, NavigatorScreenParams } from "@react-navigation/native";
import LibraryNavigator, { LibraryStackParamList } from './src/screens/library/LibraryNavigator';
import { createMaterialBottomTabNavigator } from "@react-navigation/material-bottom-tabs";
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import MaterialIcons from 'react-native-vector-icons/MaterialIcons';
import HomeScreen from "./src/screens/HomeScreen";
import SettingsScreen from "./src/screens/SettingsScreen";
import SourcesNavigator, { SourcesStackParamList } from './src/screens/sources/SourcesNavigator';
import { DatabaseProvider } from './src/contexts/DatabaseContext';

export type RootTabParamList = {
	Home: undefined;
	SourcesNavigator: NavigatorScreenParams<SourcesStackParamList>;
	LibraryNavigator: NavigatorScreenParams<LibraryStackParamList>;
	Settings: undefined;
};

const Tab = createMaterialBottomTabNavigator<RootTabParamList>();

export default function App() {
	return (
		<DatabaseProvider>
			<GestureHandlerRootView style={{ flex: 1 }}>
				<SafeAreaProvider>
					<NavigationContainer>
						<Tab.Navigator
							initialRouteName="Home"
							activeColor="#ffffff"
							labeled={false}
							barStyle={{ backgroundColor: '#4B7288' }}
						>
							<Tab.Screen name="Home" component={HomeScreen} options={{
								tabBarIcon: ({ focused }) => (
									<MaterialIcons name="home" color={focused ? "#4B7288" : "white"} size={28} />
								),
							}} />
							<Tab.Screen name="SourcesNavigator" component={SourcesNavigator} options={{
								tabBarIcon: ({ focused }) => (
									<MaterialIcons name="search" color={focused ? "#4B7288" : "white"} size={28} />
								),
							}} />
							<Tab.Screen name="LibraryNavigator" component={LibraryNavigator} options={{
								tabBarIcon: ({ focused }) => (
									<MaterialIcons name="book" color={focused ? "#4B7288" : "white"} size={28} />
								),
							}} />
							<Tab.Screen name="Settings" component={SettingsScreen} options={{
								tabBarIcon: ({ focused }) => (
									<MaterialIcons name="settings" color={focused ? "#4B7288" : "white"} size={28} />
								),
							}} />
						</Tab.Navigator>
					</NavigationContainer>
				</SafeAreaProvider>
			</GestureHandlerRootView>
		</DatabaseProvider>
	);
}

const styles = StyleSheet.create({
	container: {},
});
