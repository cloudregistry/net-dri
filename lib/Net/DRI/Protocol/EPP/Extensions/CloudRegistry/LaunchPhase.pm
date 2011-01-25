## Domain Registry Interface, Cloud Registry LaunchPhase EPP Extension for managing Sunrise and Landrush 
##
## Copyright (c) 2009-2011 Cloud Registry Pty Ltd <http://www.cloudregistry.net>. All rights reserved.
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

package Net::DRI::Protocol::EPP::Extensions::CloudRegistry::LaunchPhase;

use strict;

use Net::DRI::Util;
use Net::DRI::Exception;

our $VERSION=do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::Protocol::EPP::Extensions::CloudRegistry::LaunchPhase - Cloud Registry LaunchPhase (Sunrise and Land Rush) EPP Extension for Net::DRI

=head1 DESCRIPTION

Please see the README file for details.

=head1 SUPPORT

Please use the issue tracker

E<lt>https://github.com/cloudregistry/net-dri/issuesE<gt>

Please also see the SUPPORT file in the distribution.

=head1 SEE ALSO

E<lt>http://www.cloudregistry.net/E<gt> and
E<lt>http://www.dotandco.com/services/software/Net-DRI/E<gt>

=head1 AUTHOR

Wil Tan E<lt>wil@cloudregistry.netE<gt>

=head1 COPYRIGHT

Copyright (c) 2009-2011 Cloud Registry Pty Ltd <http://www.cloudregistry.net>.
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
 my %tmp=(
           create => [ \&create, \&create_parse ],
           info => [ \&info, \&info_parse ],
         );

 return { 'domain' => \%tmp };
}

####################################################################################################


sub create
{
 my ($epp,$domain,$rd)=@_;
 my $mes=$epp->message();

 if (defined($rd) && (ref($rd) eq 'HASH') && exists($rd->{lp}))
 {
  my @lpdata;
  push(@lpdata, ['lp:trademark_name', $rd->{lp}->{trademark_name}])
	if (exists($rd->{lp}->{trademark_name}));
  push(@lpdata, ['lp:trademark_number', $rd->{lp}->{trademark_number}])
	if (exists($rd->{lp}->{trademark_number}));
  push(@lpdata, ['lp:trademark_locality', $rd->{lp}->{trademark_locality}])
	if (exists($rd->{lp}->{trademark_locality}));
  push(@lpdata, ['lp:trademark_entitlement', $rd->{lp}->{trademark_entitlement}])
	if (exists($rd->{lp}->{trademark_entitlement}));
  push(@lpdata, ['lp:pvrc', $rd->{lp}->{pvrc}])
	if (exists($rd->{lp}->{pvrc}));
  push(@lpdata, ['lp:phase', $rd->{lp}->{phase}])
	if (exists($rd->{lp}->{phase}));

  my $eid=$mes->command_extension_register('lp:create',sprintf('xmlns:lp="%s" xsi:schemaLocation="%s %s"',$mes->nsattrs('lp')));
  $mes->command_extension($eid,[@lpdata]);
 }
}


sub create_parse
{
 my ($po, $otype, $oaction, $oname, $rinfo) = @_;
 my $mes = $po->message();
 my $creData = $mes->get_extension('lp','creData');
 my $c;

 return unless ($creData);

 $c = $creData->getElementsByTagNameNS($mes->ns('lp'), 'application_id');
 $rinfo->{$otype}->{$oname}->{lp} = {application_id=>$c->shift()->getFirstChild()->getData()}
	if ($c);
}

sub info
{
 my ($epp,$domain,$rd)=@_;
 my $mes=$epp->message();

 if (defined($rd) && (ref($rd) eq 'HASH') && exists($rd->{lp}))
 {
  my @lpdata;
  push(@lpdata, ['lp:application_id', $rd->{lp}->{application_id}])
	if (exists($rd->{lp}->{application_id}));
  push(@lpdata, ['lp:phase', $rd->{lp}->{phase}])
	if (exists($rd->{lp}->{phase}));

  my $eid=$mes->command_extension_register('lp:info',sprintf('xmlns:lp="%s" xsi:schemaLocation="%s %s"',$mes->nsattrs('lp')));
  $mes->command_extension($eid,[@lpdata]);
 }
}


sub info_parse
{
 my ($po,$otype,$oaction,$oname,$rinfo)=@_;
 my $mes=$po->message();
 my $infdata=$mes->get_extension('lp','infData');
 my $lpdata = {};
 my $c;

 return unless ($infdata);
 my $pd=DateTime::Format::ISO8601->new();
 my $ns=$mes->ns('lp');
 $c = $infdata->getElementsByTagNameNS($ns, 'trademark_name');
 $lpdata->{trademark_name} = $c->shift()->getFirstChild()->getData() if ($c);
 $c = $infdata->getElementsByTagNameNS($ns, 'trademark_number');
 $lpdata->{trademark_number} = $c->shift()->getFirstChild()->getData() if ($c);
 $c = $infdata->getElementsByTagNameNS($ns, 'trademark_locality');
 $lpdata->{trademark_locality} = $c->shift()->getFirstChild()->getData() if ($c);
 $c = $infdata->getElementsByTagNameNS($ns, 'trademark_entitlement');
 $lpdata->{trademark_entitlement} = $c->shift()->getFirstChild()->getData() if ($c);
 $c = $infdata->getElementsByTagNameNS($ns, 'pvrc');
 $lpdata->{pvrc} = $c->shift()->getFirstChild()->getData() if ($c);
 $c = $infdata->getElementsByTagNameNS($ns, 'phase');
 $lpdata->{phase} = $c->shift()->getFirstChild()->getData() if ($c);
 $rinfo->{$otype}->{$oname}->{lp} = $lpdata;
}


####################################################################################################
1;
