#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use FindBin qw($RealBin);
use lib "$RealBin/..";
use t::helpers;
use File::Temp qw(tempdir);

chdir "$RealBin/.." or die "Cannot chdir to repo root: $!";

my $tmp = tempdir(CLEANUP => 1);

extract_subs(qw(readlist setval));

# Simulate what confwrite does for .bpqconfig save/load

my @sys = (
   {ITEM=>'Node Callsign',VALUE=>'K0NTS',TEST=>'^[A-Za-z]+[0-9]+[A-Za-z]+$'},
   {ITEM=>'Owner Acronym',VALUE=>'CTN',  TEST=>'^[\S]+$'},
   {ITEM=>'Grid Square',  VALUE=>'DM79gr',TEST=>'^[A-Z][A-Z][0-9][0-9][a-z][a-z]$'},
);

my %port;
$port{'Port 1'} = [
   {ITEM=>'Type',        VALUE=>'Packet', TEST=>['Packet','APRS']},
   {ITEM=>'Device Type', VALUE=>'USB',    TEST=>['Serial','I2C','USB']},
   {ITEM=>'Device Number',VALUE=>'0',    TEST=>'^[0-9]+$'},
];

my %readlist_tpl;
$readlist_tpl{'K0NTS-1'} = [
   {ITEM=>'Callsign',VALUE=>'K0NTS-1',TEST=>'^[A-Za-z]+[0-9]+[A-Za-z]+(-\d+)?$'},
   {ITEM=>'Address', VALUE=>'10.0.0.1',TEST=>'^(\d+\.\d+\.\d+.\d+|[\S]+)$'},
   {ITEM=>'Port',    VALUE=>'10093',   TEST=>'^[1-9][0-9]+$'},
];

my %readalias_tpl;
$readalias_tpl{'CTN'} = [
   {ITEM=>'Alias',   VALUE=>'CTN', TEST=>'^[A-Za-z]+[0-9A-Za-z]*$'},
   {ITEM=>'Callsign',VALUE=>'K0NTS',TEST=>'^[A-Za-z]+[0-9]+[A-Za-z]+(-\d+)?$'},
   {ITEM=>'Quality', VALUE=>'220',  TEST=>'^[0-9]+$'},
];

my $CFG;
open($CFG, '>', "$tmp/.bpqconfig") or die "Cannot write: $!";
printf $CFG "CRC16\t%d\n", 12345;
for my $item (@sys) {
   printf $CFG "%s\t%s\n", $item->{ITEM}, $item->{VALUE};
}
for my $name (sort keys %port) {
   printf $CFG "[%s]\n", $name;
   for my $item (@{$port{$name}}) {
      printf $CFG "%s\t%s\n", $item->{ITEM}, $item->{VALUE};
   }
}
for my $name (sort keys %readlist_tpl) {
   printf $CFG "<%s>\n", join("\t", map {$_->{VALUE}} @{$readlist_tpl{$name}});
}
for my $name (sort keys %readalias_tpl) {
   printf $CFG "(%s)\n", join("\t", map {$_->{VALUE}} @{$readalias_tpl{$name}});
}
close($CFG);

ok(-e "$tmp/.bpqconfig", 'roundtrip: .bpqconfig was written');

# Now read it back
my $CRC16;
my %read_port;
my %read_user;
my %read_map;
my %read_alias;
my @read_sys = (
   {ITEM=>'Node Callsign',VALUE=>'',TEST=>'^[A-Za-z]+[0-9]+[A-Za-z]+$'},
   {ITEM=>'Owner Acronym',VALUE=>'',TEST=>'^[\S]+$'},
   {ITEM=>'Grid Square',  VALUE=>'',TEST=>'^[A-Z][A-Z][0-9][0-9][a-z][a-z]$'},
);

open(my $cfg, '<', "$tmp/.bpqconfig") or die "Cannot read: $!";
my $tab = \@read_sys;
while (my $line = <$cfg>) {
   chomp $line;
   if ($line =~ /^\[(.*)\]$/) {
      my $pn = $1;
      $read_port{$pn} = [
         {ITEM=>'Type',VALUE=>'',TEST=>['Packet','APRS']},
         {ITEM=>'Device Type',VALUE=>'',TEST=>['Serial','I2C','USB']},
         {ITEM=>'Device Number',VALUE=>'',TEST=>'^[0-9]+$'},
      ];
      $tab = $read_port{$pn};
   }
   elsif ($line =~ /^<(.*)>$/) { readlist($1,\%read_map,\%readlist_tpl); }
   elsif ($line =~ /^\((.*)\)$/) { readlist($1,\%read_alias,\%readalias_tpl); }
   elsif ($line =~ /^CRC16\t(\d+)$/) { $CRC16 = $1; }
   else {
      my ($key,$val) = split("\t",$line);
      setval($key,$val,$tab);
   }
}
close($cfg);

is($read_sys[0]{VALUE}, 'K0NTS',  'roundtrip: sys Callsign matches');
is($read_sys[1]{VALUE}, 'CTN',    'roundtrip: sys Acronym matches');
is($read_sys[2]{VALUE}, 'DM79gr', 'roundtrip: sys Grid matches');
is($read_port{'Port 1'}[0]{VALUE}, 'Packet', 'roundtrip: port Type matches');
is($read_port{'Port 1'}[1]{VALUE}, 'USB',    'roundtrip: port Device matches');
is($CRC16, 12345, 'roundtrip: CRC16 matches');

done_testing();
