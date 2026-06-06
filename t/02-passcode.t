#!/usr/bin/perl -w
use strict;
use warnings;

use Test::More tests => 2;

my $passcode;
{
   local $/;
   open(my $fh, '<', 'bpq-config') or die "Cannot open bpq-config: $!";
   my $code = <$fh>;
   close($fh);
   $code =~ s/^.*?sub PassCode/\nsub PassCode/ms;
   $code =~ s/sub confwrite.*//ms;
   eval $code;
   die "Cannot compile PassCode: $@" if $@;
}

is(PassCode("N0CALL"), 13023, 'PassCode for N0CALL matches known value');
ok(PassCode("K0NTS") > 0, 'PassCode for K0NTS is positive');
