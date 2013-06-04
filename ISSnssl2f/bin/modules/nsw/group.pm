
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
	
	($self->{"log"}) = @_; 

	$self->{class} = $class;
	$class->SUPER::customAttributeMaps($self, BACKEND, \@ftol);	
	
	return($self);
}

sub loadLDAP
{
	my $self = shift;
	
	$self->{"log"}->msg("Loading " . BACKEND . " objects from LDAP", "high");
	$self->{class}->SUPER::loadLDAP($self, BACKEND);
}

sub saveFILES
{
	my $self = shift;
	$self->{"log"}->msg("Saving " . BACKEND . " objects into files", "high");

	my @files;
	
	foreach my $record (@{$self->{nsw}})
	{
		push(@files, $self->{class}->SUPER::extractAttributes(\@ftol, \%{$record}));
	}
	
	print "FILES\n";
	use Data::Dumper;
	print Dumper(\@files);
	
}

1;