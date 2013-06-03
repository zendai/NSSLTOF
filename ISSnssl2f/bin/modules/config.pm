
package modules::config;

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
	
	open($HANDLER, "<" . $configfile) or die "Unable to open config file $configfile\n";
	
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

1;