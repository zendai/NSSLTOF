
package nsw::group;

use strict;
use warnings;
use base 'nsw::generic';

my @ftol = ("cn", "userPassword", "gidNumber", "memberUid");

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	($self->{"log"}) = @_; 
	
	$self->{class} = $class;
	
	use Data::Dumper;
	print "BEFORE\n";
	print Dumper(\@ftol);
	
	$class->SUPER::customAttributeMaps("group", \@ftol);
	print "AFTER\n";
	print Dumper(\@ftol);
	
	return($self);
}

sub loadLDAP
{
	my $self = shift;
	
	$self->{"log"}->msg("Loading group objects from LDAP", "high");
	$self->{class}->SUPER::loadLDAP($self, "group");
}

sub saveFILES
{
	my $self = shift;
	$self->{"log"}->msg("Saving group objects into files", "high");
	
}

1;