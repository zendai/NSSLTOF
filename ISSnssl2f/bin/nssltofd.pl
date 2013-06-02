#!/usr/bin/env perl


package nssl2f;

use diagnostics;
use warnings;
use strict;
use mods::params;

%::config;
$::configfile = "/opt/ISSnssl2f/etc/nssl2f.conf";

	Getopt::Long::Configure("bundling");
	GetOptions(\%::opts,'h','c=s'); 
	
	if (exists $::opts{h}) { printHelp(); exit(0); }
	if (exists $::opts{c}) { $::configfile = $::opts{c}; }
	loadConfig();
	exit(0); 
	
sub loadConfig
{
	open(my $HANDLER, "< " . $::configfile) or die "Unable to open config file " . $::configfile;
	while (my $line = <$HANDLER>)
	{
		chomp($line);
		my ($parameter, $value) = split('=', 2);
		trimWSP($parameter);
		trimWSP($value);
	}
	close($HANDLER);
}

sub trimWSP
{
	
}