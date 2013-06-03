#!/usr/bin/env perl

package nssl2f;

use strict;
use diagnostics;
use warnings;

use modules::log;
use modules::params;
use modules::config;
use modules::nsw::passwd;
use modules::nsw::group;
use modules::nsw::shadow;
use Data::Dumper; 

$::VERSION = 0.1;

	my $params = modules::params->new();
	my $log = modules::log->new($params->getLogFilename, $params->getLogLevel, $params->getLogLimit);
	my $config = modules::config->new($params->getConfigFilename);
	
	foreach my $nsw ($params->getArrayNSWs())
	{
		my $nsw = modules::$nsw->new();
	}
	exit(0); 
