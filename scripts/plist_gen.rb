#!/usr/bin/env ruby

require 'plist'

cfg = {
#	'Enabled'        => true,
#	'Exporters'      => [
#		'S3',
#		'Email'
#	]
	'Frequency' => 100,
	'developerMode' => 0,
	'exportEmail' => 1,
	'exportS3' => 1,
	'sensorAccelerometer' => 1,
	'sensorGyroscope' => 1,
	'sensorMagnetometer' => 1,
	'sensorPedometer' => 1,
}

print cfg.to_plist
