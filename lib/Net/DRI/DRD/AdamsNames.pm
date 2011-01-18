## Domain Registry Interface, AdamsNames Registry Driver
##
## Copyright (c) 2009 Patrick Mevzek <netdri@dotandco.com>. All rights reserved.
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
#########################################################################################

package Net::DRI::DRD::AdamsNames;

use strict;
use warnings;

use base qw/Net::DRI::DRD/;

our $VERSION=do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::DRD::AdamsNames - AdamsNames (.TC .VG .GD) Registry driver for Net::DRI

=head1 DESCRIPTION

Please see the README file for details.

=head1 CURRENT LIMITATIONS

Only domain_info and account_list_domains are implemented for now

=head1 SUPPORT

For now, support questions should be sent to:

E<lt>netdri@dotandco.comE<gt>

Please also see the SUPPORT file in the distribution.

=head1 SEE ALSO

E<lt>http://www.dotandco.com/services/software/Net-DRI/E<gt>

=head1 AUTHOR

Patrick Mevzek, E<lt>netdri@dotandco.comE<gt>

=head1 COPYRIGHT

Copyright (c) 2009 Patrick Mevzek <netdri@dotandco.com>.
All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

See the LICENSE file that comes with this distribution for more details.

=cut

####################################################################################################

sub name          { return 'AdamsNames'; }
sub tlds          { return (qw/tc vg gd/); }
sub object_types  { return ('domain','contact'); }
sub profile_types { return qw/ws das/; }

sub transport_protocol_default
{
 my ($self,$type)=@_;

 return ('Net::DRI::Transport::HTTP::XMLRPCLite',{proxy_uri=>'http://www.adamsnames.tc/api/xmlrpc'},'Net::DRI::Protocol::AdamsNames::WS',{}) if $type eq 'ws';
 return ('Net::DRI::Transport::Socket',{},'Net::DRI::Protocol::DAS::AdamsNames',{})                                                          if $type eq 'das';
 return;
}

####################################################################################################

sub domain_operation_needs_is_mine
{
 my ($self,$ndr,$domain,$op)=@_;
 return;
}

####################################################################################################
1;
