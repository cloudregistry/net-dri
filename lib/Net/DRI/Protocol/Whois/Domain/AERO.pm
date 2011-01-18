## Domain Registry Interface, Whois commands for .AERO (RFC3912)
##
## Copyright (c) 2007,2009 Patrick Mevzek <netdri@dotandco.com>. All rights reserved.
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

package Net::DRI::Protocol::Whois::Domain::AERO;

use strict;
use warnings;

use Net::DRI::Exception;
use Net::DRI::Util;
use Net::DRI::Protocol::Whois::Domain::common;
use Net::DRI::Data::Contact::AERO;

our $VERSION=do { my @r=(q$Revision: 1.3 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::Protocol::Whois::Domain::AERO - .AERO Whois commands (RFC3912) for Net::DRI

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

Copyright (c) 2007,2009 Patrick Mevzek <netdri@dotandco.com>.
All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

See the LICENSE file that comes with this distribution for more details.

=cut

####################################################################################################

sub register_commands
{
 my ($class,$version)=@_;
 return { 'domain' => { info   => [ \&info, \&info_parse ] } };
}

sub info
{
 my ($po,$domain,$rd)=@_;
 my $mes=$po->message();
 Net::DRI::Exception->die(1,'protocol/whois',10,'Invalid domain name: '.$domain) unless Net::DRI::Util::is_hostname($domain);
 $mes->command('domain '.lc($domain));
}

sub info_parse
{
 my ($po,$otype,$oaction,$oname,$rinfo)=@_;
 my $mes=$po->message();
 return unless $mes->is_success();

 my $rr=$mes->response();
 my $rd=$mes->response_raw();
 my ($domain,$exist)=parse_domain($po,$rr,$rd,$rinfo);
 $rinfo->{domain}->{$domain}->{exist}=$exist;
 $rinfo->{domain}->{$domain}->{action}='info';

 return unless $exist;

 Net::DRI::Protocol::Whois::Domain::common::epp_parse_registrars($po,$domain,$rr,$rinfo);
 Net::DRI::Protocol::Whois::Domain::common::epp_parse_dates($po,$domain,$rr,$rinfo);
 Net::DRI::Protocol::Whois::Domain::common::epp_parse_status($po,$domain,$rr,$rinfo);
 Net::DRI::Protocol::Whois::Domain::common::epp_parse_contacts($po,$domain,$rr,$rinfo,{registrant => 'Registrant',admin => 'Admin', billing => 'Billing', tech => 'Tech'});
 Net::DRI::Protocol::Whois::Domain::common::epp_parse_ns($po,$domain,$rr,$rinfo);
}

sub parse_domain
{
 my ($po,$rr,$rd,$rinfo)=@_;
 my ($dom,$e);
 if (exists($rr->{'Domain Name'}))
 {
  $e=1;
  $dom=lc($rr->{'Domain Name'}->[0]);
  $rinfo->{domain}->{$dom}->{ens}={auth_id => $rr->{'ENS_AuthId'}->[0] };
  $rinfo->{domain}->{$dom}->{clWebsite}=$rr->{'Maintainer'}->[0] ;
  $rinfo->{domain}->{$dom}->{roid}=$rr->{'Domain ID'}->[0];
 } else
 {
  $e=0;
  ($dom)=grep { m/^No match for domain "\S+"\./ } @$rd;
  $dom=~s/^.+"(\S+)".+$/$1/;
  $dom=lc($dom);
 }
 return ($dom,$e);
}

####################################################################################################
1;
