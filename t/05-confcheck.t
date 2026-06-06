#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use lib '.';
use t::helpers;

extract_subs(qw(confcheck condtab find));

# Test table with simple items (no COND fields)
my @complete = (
   {ITEM=>'Callsign', VALUE=>'K0NTS', TEST=>'^[A-Z]+[0-9][A-Z]+$'},
   {ITEM=>'SSID',     VALUE=>'7',     TEST=>'^[0-9]+$'},
);
my ($key, %conf) = confcheck(@complete);
is($key, undef, 'confcheck: complete table returns undef');
is($conf{Callsign}, 'K0NTS', 'confcheck: returns values');

# Test table with missing required values
my @missing = (
   {ITEM=>'Callsign', VALUE=>'', TEST=>'^[A-Z]+[0-9][A-Z]+$'},
   {ITEM=>'SSID',     VALUE=>'7', TEST=>'^[0-9]+$'},
);
($key) = confcheck(@missing);
is($key, 'Callsign', 'confcheck: missing required returns key');

# Test COND=>undef items are NOT required
my @cond_undef = (
   {ITEM=>'Callsign', VALUE=>'', TEST=>'^[\S]+$', COND=>undef},
);
($key) = confcheck(@cond_undef);
is($key, undef, 'confcheck: COND=>undef is not required');

# Test COND=SomeItem items are required when condition is met
my @cond_met = (
   {ITEM=>'EnableFoo', VALUE=>'Yes', TEST=>undef},
   {ITEM=>'FooField',  VALUE=>'',    TEST=>'^[\S]+$', COND=>'EnableFoo'},
);
($key) = confcheck(@cond_met);
is($key, 'FooField', 'confcheck: COND item required when condition met');

# Test COND items are NOT required when condition NOT met
my @cond_not = (
   {ITEM=>'EnableFoo', VALUE=>'No',  TEST=>undef},
   {ITEM=>'FooField',  VALUE=>'',    TEST=>'^[\S]+$', COND=>'EnableFoo'},
);
($key) = confcheck(@cond_not);
is($key, undef, 'confcheck: COND item not required when condition not met');

# Test COND=SomeItem=SomeValue
my @cond_eq = (
   {ITEM=>'Device', VALUE=>'USB', TEST=>['Serial','USB']},
   {ITEM=>'Speed',  VALUE=>'',    TEST=>'^[0-9]+$', COND=>'Device=USB'},
);
($key) = confcheck(@cond_eq);
is($key, 'Speed', 'confcheck: COND=Item=Value condition met');

($key) = confcheck(
   {ITEM=>'Device', VALUE=>'Serial', TEST=>['Serial','USB']},
   {ITEM=>'Speed',  VALUE=>'',       TEST=>'^[0-9]+$', COND=>'Device=USB'},
);
is($key, undef, 'confcheck: COND=Item=Value condition not met');
done_testing();
