
package modules::service;

use strict;
use warnings;
use POSIX 'setsid';

use nsw::passwd;
use nsw::group;
use nsw::shadow;

$::running = 1;
$SIG{'INT'} = sub { $::running = 0; };
$SIG{'TERM'} = sub { $::running = 0; };
use constant PID_FILE => "/var/run/nssltofd.pid";

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	$ENV{PATH} = "/bin:/usr/bin:/sbin:/usr/sbin";
	($self->{"log"}, $self->{config}, $self->{params}) = @_;
	
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
	
	if ($self->instanceFound())
	{
		$l->msg("Previous instance found, exiting. If you are sure nssl2f is not running, remove the pid file " . PID_FILE);
		print "Previous instance found, exiting. If you are sure nssl2f is not running, remove the pid file " . PID_FILE . "\n";
		exit(1);
	};
	
	if ($self->{params}->startDaemon())
	{
		$self->Daemonize();
	}
	
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
	
	$l->msg("Received signal, exiting.", "low");
}

sub instanceFound
{
	if (! -f PID_FILE)
	{
		return(0);
	}
	
	open(my $HANDLER, "<" . PID_FILE) or die "Unable to open PID file " . PID_FILE;
	my $pid = <$HANDLER>;
	chomp($pid);
	close($HANDLER);
	
	my $status = kill(0, $pid);
	return($status);
}

sub Daemonize
{
	my $self = shift;
	my $l = $self->{"log"};
	
	chdir('/');
	open(STDIN, "</dev/null") or die "Unable to read /dev/null";
	open(STDOUT, "> /dev/null") or die "Unable to write /dev/null";
	defined(my $pid = fork()) or die "Unable to fork";
	if ($pid){ exit(0); };
	(setsid() != -1) or die "Unable to start a new session";
	open(STDERR, ">&STDOUT") or die "Unable to dup stdout";
	
	$l->msg("Daemon started", "low");
	open(my $HANDLER, ">" . PID_FILE) or die "Unable to open PID file " . PID_FILE;
	print $HANDLER $$ . "\n";
	close($HANDLER);
}

1;	
	