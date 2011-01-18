#!/usr/bin/perl -w

use Net::DRI;
use Net::DRI::Data::Raw;

use Test::More tests => 12;
eval { no warnings; require Test::LongString; Test::LongString->import(max => 100); $Test::LongString::Context=50; };
*{'main::is_string'}=\&main::is if $@;

our $E1='<?xml version="1.0" encoding="UTF-8" standalone="no"?><epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">';
our $E2='</epp>';
our $TRID='<trID><clTRID>ABC-12345</clTRID><svTRID>54322-XYZ</svTRID></trID>';

our $R1;
sub mysend
{
 my ($transport,$count,$msg)=@_;
 $R1=$msg->as_string();
 return 1;
}

our $R2;
sub myrecv
{
 return Net::DRI::Data::Raw->new_from_string($R2? $R2 : $E1.'<response>'.r().$TRID.'</response>'.$E2);
}

my $dri=Net::DRI::TrapExceptions->new(10);
$dri->{trid_factory}=sub { return 'ABC-12345'; };
$dri->add_registry('VNDS');


$dri->target('VNDS')->add_current_profile('p1','test=epp',{f_send=>\&mysend,f_recv=>\&myrecv},{default_product=>'dotNET'});

#########################################################################################################
## Example taken from EPP-NameStoreExt-Mapping.pdf

$R2=$E1.'<response>'.r().'<resData><domain:chkData xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:cd><domain:name avail="1">example22.com</domain:name></domain:cd><domain:cd><domain:name avail="0">example2.net</domain:name><domain:reason>In use</domain:reason></domain:cd></domain:chkData></resData><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotCC</namestoreExt:subProduct></namestoreExt:namestoreExt></extension>'.$TRID.'</response>'.$E2;
my $rc=$dri->domain_check_multi('example22.com','example2.net');
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example22.com</domain:name><domain:name>example2.net</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotNET</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check_multi build with namestore fixed in add_current_profile()');
is($rc->is_success(),1,'domain_check_multi is_success');
is($dri->get_info('exist','domain','example22.com'),0,'domain_check_multi get_info(exist) 1/2');
is($dri->get_info('exist','domain','example2.net'),1,'domain_check_multi get_info(exist) 2/2');
is($dri->get_info('exist_reason','domain','example2.net'),'In use','domain_check_multi get_info(exist_reason)');
is($dri->get_info('subproductid'),'dotCC','domain_check_multi get_info(subproductid)');


## if _auto_ it will be computed from first domain
$dri->target('VNDS')->add_current_profile('p2','test=epp',{f_send=>\&mysend,f_recv=>\&myrecv},{default_product=>'_auto_'});
$rc=$dri->domain_check_multi('example22.com','example2.net');
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example22.com</domain:name><domain:name>example2.net</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotCOM</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check_multi build with namestore=_auto_');

## you can always pass it explicitely, which will override the default set in add_current_profile only for the given call
$dri->target('VNDS')->add_current_profile('p3','test=epp',{f_send=>\&mysend,f_recv=>\&myrecv},{default_product=>'_auto_'});
$rc=$dri->domain_check_multi('example22.com','example2.net',{subproductid=>'dotAA'});
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example22.com</domain:name><domain:name>example2.net</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotAA</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check_multi build with namestore given in call');

## Check some more namestores
$rc=$dri->domain_check('example4.cc');
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example4.cc</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotCC</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check build with namestore=_auto_ for .cc');

$rc=$dri->domain_check('example4.tv');
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example4.tv</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotTV</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check build with namestore=_auto_ for .tv');

$rc=$dri->domain_check('example4.bz');
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example4.bz</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotBZ</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check build with namestore=_auto_ for .bz');

$rc=$dri->domain_check('example4.jobs');
is_string($R1,$E1.'<command><check><domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd"><domain:name>example4.jobs</domain:name></domain:check></check><extension><namestoreExt:namestoreExt xmlns:namestoreExt="http://www.verisign-grs.com/epp/namestoreExt-1.1" xsi:schemaLocation="http://www.verisign-grs.com/epp/namestoreExt-1.1 namestoreExt-1.1.xsd"><namestoreExt:subProduct>dotJOBS</namestoreExt:subProduct></namestoreExt:namestoreExt></extension><clTRID>ABC-12345</clTRID></command>'.$E2,'domain_check build with namestore=_auto_ for .jobs');

exit 0;

sub r
{
 my ($c,$m)=@_;
 return '<result code="'.($c || 1000).'"><msg>'.($m || 'Command completed successfully').'</msg></result>';
}
