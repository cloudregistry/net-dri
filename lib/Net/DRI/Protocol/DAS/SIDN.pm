## Domain Registry Interface, DAS Protocol for .NL
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
####################################################################################################

package Net::DRI::Protocol::DAS::SIDN;

use strict;
use warnings;

use base qw(Net::DRI::Protocol);

use Net::DRI::Util;
use Net::DRI::Protocol::DAS::SIDN::Message;

our $VERSION=do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::Protocol::DAS::SIDN - .NL DAS Protocol (Domain Availability Service) for Net::DRI

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

Copyright (c) 2009 Patrick Mevzek <netdri@dotandco.com>.
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
 my ($c,$drd,$rp)=@_;
 my $self=$c->SUPER::new();
 $self->name('DAS');
 my $version=Net::DRI::Util::check_equal($rp->{version},['1.0'],'1.0');
 $self->version($version);
 $self->factories('message',sub { return Net::DRI::Protocol::DAS::SIDN::Message->new(@_)->version($version); });
 $self->_load($rp);
 return $self;
}

sub _load
{
 my ($self,$rp)=@_;
 $self->SUPER::_load('Net::DRI::Protocol::DAS::SIDN::Domain');
}

sub transport_default
{
 my ($self)=@_;
 return (protocol_connection => 'Net::DRI::Protocol::DAS::SIDN::Connection', protocol_version => 1);
}

####################################################################################################
1;
