## Domain Registry Interface, EPP Protocol (STD 69)
##
## Copyright (c) 2005,2006,2007,2008,2009 Patrick Mevzek <netdri@dotandco.com>. All rights reserved.
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

package Net::DRI::Protocol::EPP;

use strict;
use warnings;

use base qw(Net::DRI::Protocol);

use Net::DRI::Util;
use Net::DRI::Protocol::EPP::Message;
use Net::DRI::Protocol::EPP::Core::Status;

our $VERSION=do { my @r=(q$Revision: 1.14 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::Protocol::EPP - EPP Protocol (STD 69 aka RFC 5730,5731,5732,5733,5734 obsoleting RFC 3730,3731,3732,3733,3734 and RFC 3735) for Net::DRI

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

Copyright (c) 2005,2006,2007,2008,2009 Patrick Mevzek <netdri@dotandco.com>.
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
 $self->name('EPP');
 my $version=Net::DRI::Util::check_equal($rp->{version},['1.0'],'1.0');
 $self->version($version);

 foreach my $o (qw/ip status/) { $self->capabilities('host_update',$o,['add','del']); }
 $self->capabilities('host_update','name',['set']);
 $self->capabilities('contact_update','status',['add','del']);
 $self->capabilities('contact_update','info',['set']);
 foreach my $o (qw/ns status contact/) { $self->capabilities('domain_update',$o,['add','del']); }
 foreach my $o (qw/registrant auth/)   { $self->capabilities('domain_update',$o,['set']); }

 $self->{hostasattr}=$drd->info('host_as_attr') || 0;
 $self->{contacti18n}=$drd->info('contact_i18n') || 7; ## bitwise OR with 1=LOC only, 2=INT only, 4=LOC+INT only
 $self->{defaulti18ntype}=undef; ## only needed for registries not following truely EPP standard, like .CZ
 $self->{usenullauth}=$drd->info('use_null_auth') || 0; ## See RFC4931 �3.2.5
 $self->ns({ _main   => ['urn:ietf:params:xml:ns:epp-1.0','epp-1.0.xsd'],
             domain  => ['urn:ietf:params:xml:ns:domain-1.0','domain-1.0.xsd'],
             host    => ['urn:ietf:params:xml:ns:host-1.0','host-1.0.xsd'],
             contact => ['urn:ietf:params:xml:ns:contact-1.0','contact-1.0.xsd'],
           });

 $drd->set_factories($self) if $drd->can('set_factories');
 $self->factories('message',sub { my $m=Net::DRI::Protocol::EPP::Message->new(@_); $m->ns($self->ns()); $m->version($version); return $m; });
 $self->factories('status',sub { return Net::DRI::Protocol::EPP::Core::Status->new(); });

 $self->_load($rp);
 $self->setup($rp);
 return $self;
}

sub _load
{
 my ($self,$rp)=@_;
 my $extramods=$rp->{extensions};
 my @class=$self->core_modules($rp);
 push @class,map { 'Net::DRI::Protocol::EPP::Extensions::'.$_; } $self->default_extensions($rp) if $self->can('default_extensions');
 push @class,map { my $f=$_; $f='Net::DRI::Protocol::EPP::Extensions::'.$f unless $f=~m/::/; $f=~s!/!::!g; $f; } (ref($extramods)? @$extramods : ($extramods)) if defined $extramods && $extramods;

 $self->SUPER::_load(@class);
}

sub setup {} ## subclass as needed

sub core_modules
{
 my ($self,$rp)=@_;
 my @core=qw/Session RegistryMessage Domain Contact/;
 push @core,'Host' unless $self->{hostasattr};
 return map { 'Net::DRI::Protocol::EPP::Core::'.$_ } @core;
}

sub server_greeting { my ($self,$v)=@_; $self->{server_greeting}=$v if $v; return $self->{server_greeting}; }

sub core_contact_types { return ('admin','tech','billing'); }

sub ns
{
 my ($self,$add)=@_;
 $self->{ns}={ ref($self->{ns})? %{$self->{ns}} : (), %$add } if (defined($add) && ref($add) eq 'HASH');
 return $self->{ns};
}

sub transport_default
{
 my ($self)=@_;
 return (protocol_connection => 'Net::DRI::Protocol::EPP::Connection', protocol_version => 1);
}

####################################################################################################
1;
