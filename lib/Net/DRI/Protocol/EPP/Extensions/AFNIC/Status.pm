## Domain Registry Interface, EPP Status for AFNIC (.FR/.RE)
##
## Copyright (c) 2008 Patrick Mevzek <netdri@dotandco.com>. All rights reserved.
##
## This file is part of Net::DRI
##
## Net::DRI is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## See the LICENSE file that comes with this distribution for more details.
#
# 
#
####################################################################################################

package Net::DRI::Protocol::EPP::Extensions::AFNIC::Status;

use base qw/Net::DRI::Protocol::EPP::Core::Status/;

use strict;

our $VERSION=do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::Protocol::EPP::Extensions::AFNIC::Status - AFNIC (.FR/.RE) EPP Status for Net::DRI

=head1 DESCRIPTION

Please see the README file for details.

=head1 SUPPORT

For now, support questions should be sent to:

E<lt>netdri@dotandco.comE<gt>

Please also see the SUPPORT file in the distribution.

=head1 SEE ALSO

E<lt>http://www.dotandco.com/services/software/Net-DRI/E<gt>

=head1 AUTHOR

Patrick Mevzek, E<lt>netdri@dotandco.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2008 Patrick Mevzek <netdri@dotandco.com>.
All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

See the LICENSE file that comes with this distribution for more details.

=cut

####################################################################################################

sub new
{
 my $class=shift;
 my $self=$class->SUPER::new(shift);

 ## Overwrite, as only clientHold is available
  my %s=(
        'publish'  => 'clientHold',
        );
 $self->_register_pno(\%s);

 return $self;
}

sub is_pending  { return shift->has_any('pendingCreate','pendingDelete','pendingRenew','pendingTransfer','pendingUpdate','pendingRestore'); }
sub can_trade   { return shift->has_not('serverTradeProhibited'); }
sub can_recover { return shift->has_not('serverRecoverProhibited'); }

####################################################################################################
1;
