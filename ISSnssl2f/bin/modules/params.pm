
package modules::params;

use strict;
use warnings;
use Getopt::Long;

my $configfile = "/opt/ISSnssl2f/etc/nssl2f.conf";

sub new
{
	my $class = shift;
	my $self = { configfile => $configfile };
	
	bless $self, $class;
	
	umask(0022);
	$self->initParams();
			
	return $self;
}

sub initParams
{
	my $self = shift;
		
	Getopt::Long::Configure("bundling");
	GetOptions('h|help' => \&printHelp,'c|config=s' => \$self->{configfile}, 'v|version' => \&printVersion, 's' => \$self->{nodaemon}); 
}

sub printVersion
{
	my $self = shift;
	print $0 . " version " . $::VERSION . ", sendai 2013\n";
}

sub getConfigFilename
{
	my $self = shift;
	return($self ->{configfile});
}

sub startDaemon
{
	my $self = shift;
	
	if (defined $self->{nodaemon})
	{
		return(0);
	}
	return(1);
}

sub printHelp
{
	print <<EOHELP;
$0 [-hcv]
	-h	print help
	-v	print version
	-c 	specify configuration file [default: $configfile]
	-s	standalone mode, don't send process into background
	
Any questions or comments please concact sendai (106003902)
EOHELP

	exit(0);
}

1;