
package nsw::generic;

use strict;
use warnings;
use constant LDAP_FILE_CRED => "/var/ldap/ldap_client_file";

sub loadLDAP
{
	my $class = shift;
	my $self = shift;
	my ($database) = @_;
	
	my $l = $self->{"log"};
	my $cmd = "ldaplist -lv " . $database;
	$l->msg("Executing command $cmd", "high");
	
	open(my $HANDLER, $cmd . " 2>/dev/null |") or die "Unable to run ldaplist";
	
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
	
	my $status = close($HANDLER);
	
	if (! $status)
	{
		$l->msg("WARNING: command failed to run, error code " . $?, "low");
		return("ERROR");
	}
	return("SUCCESS");
}

sub customAttributeMaps
{
	my $class = shift;
	my $self = shift;
	my $database = shift;
	my $attributes = shift;
	
	my $l = $self->{"log"};
	
	my %customMaps;
	loadAttributeMaps($database, \%customMaps);
	while (my ($oldattr, $newattr) = each(%customMaps))
	{
		$l->msg("Custom attribute found for database $database, $oldattr => $newattr", "high");
	}
	
	foreach my $attr (@{$attributes})
	{
		if (exists $customMaps{$attr})
		{
			$l->msg("Rewrite $attr to $customMaps{$attr}", "high");
			$attr = $customMaps{$attr};
		}
	}
}

sub loadAttributeMaps
{
	my ($database, $customMaps) = @_;
	
	open(my $HANDLER, "<" . LDAP_FILE_CRED) or die "Unable to open " . LDAP_FILE_CRED;
	while (my $line = <$HANDLER>)
	{
		chomp($line);
		if ($line !~ /^NS_LDAP_ATTRIBUTEMAP=/)
		{
			next;
		}
		my $mapdetail = $line;
		$mapdetail =~ s/^NS_LDAP_ATTRIBUTEMAP=//;
		if ($mapdetail =~ /^\s+$database:/)
		{
			my ($database, $conversion) = split(':', $mapdetail, 2);
			my ($defattr, $custattr) = split('=', $conversion, 2);
			
			$$customMaps{$defattr} = $custattr;
		}
	}
	close($HANDLER);	
}

sub extractAttributes
{
	my $class = shift;
	my ($attributes, $ldapobject) = @_;
	
	my @linedb;
	
	foreach my $attribute (@{$attributes})
	{
		if (ref($$ldapobject{lc($attribute)}) eq 'ARRAY')
		{
			push(@linedb, join(',', @{$$ldapobject{lc($attribute)}}));
		} else
		{
			push(@linedb, "");
		}
	}
	return(join(':',@linedb));
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