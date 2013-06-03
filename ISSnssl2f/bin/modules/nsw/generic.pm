
package nsw::generic;

use strict;
use warnings;
use constant LDAP_FILE_CRED => "/var/ldap/ldap_client_file2";

sub loadLDAP
{
	my $class = shift;
	my $self = shift;
	my ($database) = @_;
	
	my $l = $self->{"log"};
	my $cmd = "ldaplist -lv " . $database;
	$l->msg("Executing command $cmd", "high");
	
	open(my $HANDLER, $cmd . "|") or die "Unable to run ldaplist";
	
	my %record;
	undef(@{ $self->{nsw}});
	
	while (my $line = <$HANDLER>)
	{
		chomp($line);
		if ($line =~ /^dn:/)
		{
			if (keys(%record) != 0)
			{
				push( @{$self->{nsw}}, {%record });
			}
			%record = ();
		}
		if ($line !~ /^.*[^\s]+:.*[^\s]+\s*$/)
		{
			next;
		}		
		my ($attr, $value) = split(':', $line, 2);	
		trimWSP(\$attr, \$value);	
		push (@{$record{$attr}}, $value);
	}
	
	if (keys(%record) != 0)
	{
		push( @{$self->{nsw}}, {%record});
	}
	
	close($HANDLER);
}

sub customAttributeMaps
{
	my $class = shift;
	my $database = shift;
	my $attributes = shift;
	
	my %customMaps = loadAttributeMaps($database);
	foreach my $attr (@{$attributes})
	{
		
		print $attr . "XX\n";
	}
	print "AX\n";
	use Data::Dumper;
	print Dumper(\@_);
}

sub loadAttributeMaps
{
	my ($database) = @_;
	
	open(my $HANDLER, "<" . LDAP_FILE_CRED) or die "Unable to open " . LDAP_FILE_CRED;
	while (my $line = <$HANDLER>)
	{
		print $line;
		chomp($line);
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