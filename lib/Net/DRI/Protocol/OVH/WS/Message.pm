## Domain Registry Interface, OVH Web Services Message
##
## Copyright (c) 2008,2009 Patrick Mevzek <netdri@dotandco.com>. All rights reserved.
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

package Net::DRI::Protocol::OVH::WS::Message;

use strict;
use warnings;

use Carp;
use Net::DRI::Protocol::ResultStatus;

use base qw(Class::Accessor::Chained::Fast Net::DRI::Protocol::Message);
__PACKAGE__->mk_accessors(qw(version method params result errcode errmsg));

our $VERSION=do { my @r=(q$Revision: 1.5 $=~/\d+/g); sprintf("%d".".%02d" x $#r, @r); };

=pod

=head1 NAME

Net::DRI::Protocol::OVH::WS::Message - OVH Web Services Message for Net::DRI

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

Copyright (c) 2008,2009 Patrick Mevzek <netdri@dotandco.com>.
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
 my $self={errcode => undef, errmsg => undef};
 bless($self,$class);
 my ($trid,$otype,$oaction)=@_;

 $self->params([]); ## default
 return $self;
}

sub as_string
{
 my ($self)=@_;
 my @p=@{$self->params()};
 my @pr;
 foreach my $i (0..$#p)
 {
  push @pr,sprintf 'PARAM%d=%s',$i+1,$p[$i];
 }
 return sprintf "METHOD=%s\n%s\n",$self->method(),join("\n",@pr);
}

sub add_session
{
 my ($self,$sd)=@_;
 my $rp=$self->params();
 unshift @$rp,$sd->{id};
}

sub parse
{
 my ($self,$dr,$rinfo,$otype,$oaction,$sent)=@_; ## $sent is the original message, we could copy its method/params value into this new message
 my ($res)=@{$dr->data()}; ## $dr is a Data::Raw object, type=1
 if (ref($res) eq 'HASH')
 {
  $self->result($res->{value});
  $self->errcode($res->{status});
  $self->errmsg($res->{msg});
 } else
 {
  $self->result($res);
  $self->errcode(100); ## probably success
  $self->errmsg('No status/msg given');
 }
}

## See http://guides.ovh.com/ManagerV3Status and http://wikikillers.eu/index.php?title=Codes_d%27erreurs
my %CODES=( 	201 => 2003,# parametre(s) manquant(s)
		202 => 2005,# parametre(s) invalide(s)
		203 => 2306,# parametres incompatibles
		210 => 2306,# donn�e inconnue
		211 => 2306,# donn�e deja existante
		212 => 2308,# l'action n'a affect�e aucune donn�e
		213 => 2306,# donn�e en doublon
		214 => 2308,# l'action a affect�e trop de donn�es
		220 => 2304,# donn�e en cours de traitement
		230 => 2101,# fonction inactive
		240 => 2304,# action en cours de traitement
		241 => 2308,# action impossible
		250 => 2101,# fonction non impl�ment�
		251 => 2000,# fonction obsol�te
		252 => 2308,# fonction innaccessible
		260 => 2400,# erreur, pas d'info supplementaire
		266 => 2400,# toutes les fonctions du merge ont �chou�: pas de resultat
		267 => 2400,# certaines fonctions ont �chou�s: l'action devra etre entreprise de nouveau plus tard
		280 => 2400,# erreur interne
		281 => 2400,# traitement �chou�
		299 => 2005,# parametres excedentaires
		301 => 2200,# session expir�e ## should trigger a new login
		302 => 2200,# session inexistante ## should trigger a new login
		303 => 2200,# session corrompue ## should trigger a new login
		304 => 2502,# trop de sessions actives ## should trigger a call to ClearNicSessions and a retry
		310 => 2200,# erreur login
		320 => 2200,# burst
		401 => 2201,# pas de droit d'acces
		402 => 2201,# droits insuffisants
		403 => 2200,# session en lecture seule
		451 => 2400,# quota d�pass�
		461 => 2400,# hack�
		501 => 2400,# probleme connexion base de donn�es
		502 => 2400,# donn�e erron�e au sein du serveur
		503 => 2400,# probleme connexion
		504 => 2400,# probleme connexion dns
		505 => 2400,# probleme interne au serveur
		506 => 2400,# parametre interne invalide
		510 => 2308,# donn�es introuvable
		601 => 2400,# parametres mysql corrompus
		701 => 2304,# domaine dans un etat incompatible
		702 => 2307,# fonction non support�e par le domaine (ex:multidomain sur un gp)
		703 => 2304,# objet dans un �tat incompatible
		704 => 2305,# un processus bloquant interdit la cr�ation de l'objet
		705 => 2002,# plus de donn�es a trait�.
		706 => 2400,# impossible d'obtenir le lock
		777 => 2400,# pas de numero d'erreur donne
	);

sub is_success { return (shift->errcode()==100)? 1 : 0; }

sub result_status
{
 my $self=shift;
 my $code=$self->errcode();
 my $msg=$self->errmsg() || '';
 my $ok=$self->is_success();

 if ($code >= 101 && $code <=199)
 {
  carp('Got a "warning" error code, please report: '.$code.' '.$msg);
  $ok=1;
 }

 my $eppcode=(defined($code) && exists($CODES{$code}))? $CODES{$code} : 'GENERIC_ERROR';
 return Net::DRI::Protocol::ResultStatus->new('ovh_ws',$code,$ok? 'COMMAND_SUCCESSFUL' : $eppcode,$ok,$msg,'en');
}

####################################################################################################
1;
