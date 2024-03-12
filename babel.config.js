module.exports = function (api) {
	api.cache(false);

	const presets = ["module:@react-native/babel-preset"];
	const plugins = [];

	console.log("NODE_ENV", process.env["NODE_ENV"])
	if (!!process.env["NODE_ENV"] && process.env["NODE_ENV"] !== "development") {
		console.log("NOT IN DEV")
		plugins.push("transform-remove-console");
	}

	return {
		presets,
		plugins
	}
}
