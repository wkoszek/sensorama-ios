node {
	stage 'Get Sensorama-iOS source code'
	timestamps {
		git url: "https://github.com/wkoszek/sensorama-ios.git"
	}

	stage 'Build'
	timestamps {
		sh './build.sh normal'
	}
}
