
package nsw::generic;

use strict;
use warnings;
use constant LDAP_FILE_CRED => "/var/ldap/ldap_client_file";

sub loadLDAP
{
	my $class = shift;
	my $self = shift;
	my ($database) = @_;
	my $everyNFull = $self->{config}->getFullUpdateEveryNth();
	
	my $l = $self->{"log"};
	my $fullupdate = 1;
	
	my $cmd = buildLdaplistCommand($l, $everyNFull, $self, $database, \$fullupdate);
	$l->msg("Executing command $cmd", "high");
	
	open(my $HANDLER, $cmd . " 2>/dev/null |") or die "Unable to run ldaplist";
	
	my %record;
	if ($fullupdate) { 
		undef(@{ $self->{nsw}});
	}
	
	while (my $line = <$HANDLER>)
	{
		chomp($line);
		if ($line =~ /^dn:/)
		{
			if (keys(%record) != 0)
			{
				if ($fullupdate)
				{
					push( @{$self->{nsw}}, {%record });
				} else
				{
					updateEntry();
				}
				
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
		if ($fullupdate)
		{
			push( @{$self->{nsw}}, {%record});
		} else
		{
			updateEntry();
		}
	}
	
	my $status = close($HANDLER);
	
	if (! $status)
	{
		$l->msg("Command failed to run or object not found, return code " . $?, "low");
		return("ERROR");
	}
	
	return("SUCCESS");
}

sub buildLdaplistCommand
{
	my ($l, $everyNFull, $self, $database, $fullupdate) = @_;
	
	my $cmd;
	
	if ($everyNFull == -1)
	{
		$l->msg("Running in full update mode", "high");
		$cmd = "ldaplist -lv " . $database;
	}
	
	if ($everyNFull > -1)
	{
		if  (! exists $self->{nsw})
		{
			$l->msg("Running in incremental mode, init full update", "high");
			$cmd = "ldaplist -lv " . $database;
			$self->{incremental}{"timestamp"} = getLDAPTimestamp();
			$self->{incremental}{"count"} = 0;
		} else
		{
			if (($everyNFull == 0) or (($self->{incremental}{"count"} % $everyNFull) != 0))
			{
				$l->msg("Running in incremental mode, incremental update cycle #" . $self->{incremental}{"count"}, "high");
				$cmd = sprintf("ldaplist -lv %s \"modifyTimestamp>=%s\"",$database, $self->{incremental}{"timestamp"});
				$self->{incremental}{"timestamp"} = getLDAPTimestamp();
				$fullupdate = 0;
			} else
			{
				$l->msg("Running in incremental mode, full update, cycle #" . $self->{incremental}{"count"}, "high");
				$cmd = "ldaplist -lv " . $database;
			}
			$self->{incremental}{"count"}++;
		}		
	}
	return($cmd);
}

sub getLDAPTimestamp
{
	# Rewind the date by 24 hours to cover any possible timezone differences between localtime and LDAP server's localtime
	# If we wouldn't do that and localtime would be ahead of LDAP's localtime, that would punch a hole in the incremental update logic	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime((time - (3600 * 24)));
	my $ldaptstamp = sprintf("%.4d%.2d%.2d%.2d%.2d%.2dZ", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
		
	return($ldaptstamp);
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