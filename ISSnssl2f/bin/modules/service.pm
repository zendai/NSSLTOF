
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
	($self->{handler}{"log"}, $self->{handler}{"config"}) = @_;
	
	$self->initService();
	return($self);
}

sub initService
{
	my $self = shift;
	
	my $l = $self->{handler}{"log"};
	$l->msg("Initializing NSW databases","low");
	foreach my $nsw ($self->{handler}{config}->getArrayNSWs())
	{
		$l->msg("Initializing $nsw database", "high");
		if ($nsw eq "passwd")
		{
			push (@{$self->{nsw}}, nsw::passwd->new($self->{handler}{"log"}));
		}
		if ($nsw eq "group")
		{
			push (@{$self->{nsw}}, nsw::group->new($self->{handler}{"log"}));
		}
		if ($nsw eq "shadow")
		{
			push (@{$self->{nsw}}, nsw::shadow->new($self->{handler}{"log"}));
		}
	}
}

sub run
{
	my $self = shift;
	
	my $l = $self->{handler}{"log"};	
	while ($::running)
	{
		foreach my $nsw (@{$self->{nsw}})
		{
			$nsw->loadLDAP();
			$nsw->saveFILES();
		}
		$l->msg("Sleeping..", "high");
		sleep 1;
	}
}

1;	
	