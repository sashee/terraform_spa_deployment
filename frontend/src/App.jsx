import React from "react";

const param = PARAM; // eslint-disable-line

class App extends React.Component {
	render() {
		return (
			<div>
				This is a React app! And this came from Terraform: {param}
			</div>
		);
	}
}

export default App;
