
package nsw::shadow;

use strict;
use warnings;
use base 'nsw::generic';

use constant BACKEND => "shadow";
use constant CACHE_FILE => "/etc/" . BACKEND . ".cache";

# Based on shadowAccount RFC 2307
my @ftol = ("uid", "{CONSTANT}NOP", "{CONSTANT}", "{CONSTANT}", "{CONSTANT}", "{CONSTANT}", "{CONSTANT}", "{CONSTANT}", "{CONSTANT}");

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	($self->{"log"}, $self->{"config"}) = @_; 

	$self->{uniqueid} = "uid";
	$self->{class} = $class;
	$class->SUPER::customAttributeMaps($self, BACKEND, \@ftol);
	
	return($self);
}

sub loadLDAP
{
	my $self = shift;
	
	my $l = $self->{"log"};
	$l->msg("Loading " . BACKEND . " objects from LDAP", "low");
	my $status = $self->{class}->SUPER::loadLDAP($self, BACKEND);
	$l->msg(@{$self->{nsw}} . " objects in buffer", "low");
	
	if (($status eq "SUCCESS") and (@{$self->{nsw}} == 0) and ($self->{config}->skipZeroUpdates()))
	{
		$l->msg("Zero update protection turned on, skipping updates", "low");
		$status = "SKIP";
	}
	
	return($status);
}

sub saveFILES
{
	my $self = shift;
	
	my $l = $self->{"log"};
	$l->msg("Saving " . BACKEND . " objects into files", "low");

	my @files;
	
	foreach my $record (@{$self->{nsw}})
	{
		push(@files, $self->{class}->SUPER::extractAttributes(\@ftol, \%{$record}));
	}
	
	open(my $HANDLER, ">" . CACHE_FILE) or die "Unable to open cache file " . CACHE_FILE;
	foreach my $line (@files)
	{
		printf($HANDLER "%s\n", $line);
	}
	close($HANDLER);
	
	$l->msg("Saved " . @files . " lines", "low");
}

1;