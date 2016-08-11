node {
	stage 'Get Sensorama-iOS source code'
	timestamps {
		git url: "https://github.com/wkoszek/sensorama-ios.git"
	}

	stage 'Build normal'
	timestamps {
		sh './build.sh normal'
	}

	stage 'Test normal'
	timestamps {
		sh './build.sh test_normal'
	}

	stage 'Build fastlane'
	timestamps {
		sh './build.sh fastlane'
	}

	stage 'Test fastlane'
	timestamps {
		sh './build.sh test_fastlane'
	}
}
