
package nsw::shadow;

use strict;
use warnings;

sub new
{
	my $class = shift;
	
	my $self = {};
	bless $self, $class;
	
	($self->{"log"}) = @_; 
	
	return($self);
}

sub loadLDAP
{
	my $self = shift;
	
}

1;