const webpack = require("webpack");
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");

module.exports = (env) => {
	return {
		entry: "./src/index.js",
		output: {
			filename: "main.[hash].js",
			path: path.resolve(__dirname, "dist")
		},
		plugins: [
			new webpack.DefinePlugin({
				PARAM: env !== undefined ? JSON.stringify(env.PARAM) : undefined,
			}),
			new CleanWebpackPlugin(),
			new HtmlWebpackPlugin({
				template: "./src/index.html",
			}),
		],
		module: {
			rules: [
				{
					test: /\.(js|jsx)$/,
					exclude: /node_modules/,
					use: {
						loader: "babel-loader"
					}
				},
			],
		},
		devServer: {
			compress: true,
		},
	};
};
