
package nsw::group;

use strict;
use warnings;
use base 'nsw::generic';

use constant BACKEND => "group";
use constant GROUP_CACHE => "/etc/" . BACKEND . ".cache";

my @ftol = ("cn", "userPassword", "gidNumber", "memberUid");

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	($self->{"log"}, $self->{"config"}) = @_; 

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
	$l->msg("Loaded " . @{$self->{nsw}} . " objects", "low");
	
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
	
	open(my $HANDLER, ">" . GROUP_CACHE) or die "Unable to open cache file " . GROUP_CACHE;
	foreach my $line (@files)
	{
		printf($HANDLER "%s\n", $line);
	}
	close($HANDLER);
	
	$l->msg("Saved " . @files . " lines", "low");
}

1;