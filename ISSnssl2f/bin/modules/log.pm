
package modules::log;

use strict;
use warnings;

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	($self->{filename}, $self->{loglevel}, $self->{limit}) = @_;
	
	return $self;
}

sub msg
{
	my $self = shift;

	my %level2n = ("none" => 0, "low" => 1, "high" => 2);
		
	my ($msg, $level) = @_;
	
	if (! defined $level) 
	{
		$level = "low";
	}

	if ($level2n{$level} <= $level2n{$self->{loglevel}})
	{
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		my $ltime = sprintf("%d/%.2d/%.2d %.2d:%.2d:%.2d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
		my $HANDLER;
		
		if ($self->getLogfileSize() >= ($self->{limit} * 1024))
		{
			open($HANDLER, ">" . $self->{filename}) or die "Unable to open logfile $self->{filename}";	
		} else
		{
			open($HANDLER, ">>" . $self->{filename}) or die "Unable to open logfile $self->{filename}";
		}
		
		printf($HANDLER "%s %s\n", $ltime, $msg);
		close($HANDLER);
	}
}

sub getLogfileSize
{
	my $self = shift;
	
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($self->{filename});
	if (! defined $size)
	{
		$size = 0;
	}
	return($size);
}

1;