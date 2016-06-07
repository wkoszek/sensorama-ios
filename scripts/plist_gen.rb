#!/usr/bin/env ruby

require 'plist'

cfg = {
	'Enabled'        => true,
	'Exporters'      => [
		'S3',
		'Email'
	]
}

print cfg.to_plist
