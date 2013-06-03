
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
	
	$self->initParams();
			
	return $self;
}

sub initParams
{
	my $self = shift;
		
	Getopt::Long::Configure("bundling");
	GetOptions('h|help' => \&printHelp,'c|config=s' => \$self->{configfile}, 'v|version' => \&printVersion); 
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

sub printHelp
{
	print <<EOHELP
$0 [-hcv]
	-h	print help
	-v	print version
	-c 	specify configuration file [default: $configfile]
	
Any questions or comments please concact sendai (106003902)
EOHELP
}

1;