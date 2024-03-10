import { ReactNode } from "react";
import { View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";


type SafeLayoutProps = {
	children: ReactNode;
};
export default function SafeLayout({ children }: SafeLayoutProps) {
	const insets = useSafeAreaInsets();
	return (
		<View style={{
			flex: 1,
			paddingTop: insets.top,
			paddingBottom: insets.bottom,
			paddingLeft: insets.left,
			paddingRight: insets.right,
		}}>
			{children}
		</View>
	);
}
