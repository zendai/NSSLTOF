
package modules::config;

use strict;
use warnings;

sub new
{
	my $class = shift;
	my $filename = shift;
	my $self = {};
	
	bless $self, $class;
	
	$self->loadConfig($filename);
	
	return $self;
}

sub loadConfig
{
	my $self = shift;
	my $configfile = shift;
	
	open(my $HANDLER, "<" . $configfile) or die "Unable to open config file $configfile\n";
	
	while (my $line = <$HANDLER>)
	{
		chomp($line);
		my ($parameter, $value) = split('=', $line, 2);
		if (! defined $value) { next; } 
		trimWSP(\$parameter, \$value);
		$self->{config}{$parameter} = $value;
	}	
	close($HANDLER);
}

sub trimWSP
{
	foreach my $param (@_)
	{
		$$param =~ s/^\s*//g;
		$$param =~ s/\s*$//g;
	}	
}

sub getLogFilename
{
	my $self = shift;
	
	if (! exists $self->{config}{"Log.Filename"})
	{
		return("/dev/null");
	}
	
	if ($self->{config}{"Log.Filename"} !~ /\.log$/) 
	{
		print STDERR "Log file must end with .log, disabling logs\n";
		return("/dev/null");
	}
			
	return($self->{config}{"Log.Filename"});
}

sub getLogLevel
{
	my $self = shift;
	
	my %levels = ("none" => 0, "low" => 1, "high" =>2);
	
	if ((! exists $self->{config}{"Log.Level"}) or (! exists $levels{$self->{config}{"Log.Level"}}))
	{
		return("low")
	}
	return( $self->{config}{"Log.Level"});
}

sub getLogLimit
{
	my $self = shift;
	
	if (! exists $self->{config}{"Log.LimitSize"})
	{
		return(0);
	}
	return($self->{config}{"Log.LimitSize"});
}

sub getArrayNSWs
{
	my $self = shift;
	
	my %validNSWs = ("passwd" => "valid", "group" => "valid", "shadow" => "valid");

	my @nsws;
	
	if (! exists $self->{config}{"Sync.NSW"})
	{
		return(@nsws);
	}
	
	foreach my $nsw (split(',', $self->{config}{"Sync.NSW"}))
	{
		trimWSP(\$nsw);
		push(@nsws, $nsw);
	}
	return(@nsws);
}

1;