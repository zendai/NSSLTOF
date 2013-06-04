
package modules::service;

use strict;
use warnings;

use nsw::passwd;
use nsw::group;
use nsw::shadow;

$::running = 1;
$SIG{'INT'} = sub { $::running = 0; };

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	$ENV{PATH} = "/bin:/usr/bin:/sbin:/usr/sbin";
	($self->{"log"}, $self->{config}) = @_;
	
	$self->initService();
	return($self);
}

sub initService
{
	my $self = shift;
	
	my $l = $self->{"log"};
	$l->msg("Initializing NSW databases","low");
	foreach my $nsw ($self->{config}->getArrayNSWs())
	{
		$l->msg("Initializing $nsw database", "high");
		if ($nsw eq "passwd")
		{
			push (@{$self->{nsw}}, nsw::passwd->new($self->{"log"}, $self->{"config"}));
		}
		if ($nsw eq "group")
		{
			push (@{$self->{nsw}}, nsw::group->new($self->{"log"}, $self->{"config"}));
		}
		if ($nsw eq "shadow")
		{
			push (@{$self->{nsw}}, nsw::shadow->new($self->{"log"}, $self->{"config"}));
		}
	}
}

sub run
{
	my $self = shift;
	
	my $l = $self->{"log"};	
	while ($::running)
	{
		foreach my $nsw (@{$self->{nsw}})
		{
			if ($nsw->loadLDAP() ne "SUCCESS")
			{
				$l->msg("Error while loading objects from LDAP or zero objects found, skipping files update", "low");
				next;
			}
			$nsw->saveFILES();
		}
		my $randomWindow = int(rand($self->{config}->getRandomWindow()));
		$l->msg("Sleeping " . $self->{config}->getSleepTime() . " + " . $randomWindow . " seconds", "high");
		sleep ($self->{config}->getSleepTime() + $randomWindow);
	}
}

1;	
	