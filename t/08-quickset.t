#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use lib '.';
use t::helpers;

extract_subs(qw(quickset));

# quickset takes a hashref %quick and an array of items, sets missing values

# Test: values already set are left alone
my @items = (
   {ITEM=>'Callsign', VALUE=>'K0NTS', TEST=>'^[A-Z]+[0-9][A-Z]+$'},
);
my @result = quickset({}, @items);
is($result[0]{VALUE}, 'K0NTS', 'quickset: keeps existing value');

# Test: quickstart value fills empty
@items = (
   {ITEM=>'Callsign', VALUE=>'', TEST=>'^[A-Z]+[0-9][A-Z]+$'},
);
@result = quickset({'Callsign'=>'K0NTS'}, @items);
is($result[0]{VALUE}, 'K0NTS', 'quickset: fills from quick hash');

# Test: undef TEST means boolean — set to 'No'
@items = (
   {ITEM=>'EnableX', VALUE=>'', TEST=>undef},
);
@result = quickset({}, @items);
is($result[0]{VALUE}, 'No', 'quickset: undef TEST defaults to No');

# Test: ARRAY TEST picks first choice
@items = (
   {ITEM=>'Speed', VALUE=>'', TEST=>['1200','9600']},
);
@result = quickset({}, @items);
is($result[0]{VALUE}, '1200', 'quickset: array TEST picks first');

# Test: items with COND and no quick value stay empty
@items = (
   {ITEM=>'WinLink', VALUE=>'Yes', TEST=>undef},
   {ITEM=>'CMS Call', VALUE=>'',   TEST=>'^[\S]+$', COND=>'WinLink'},
);
@result = quickset({}, @items);
is($result[1]{VALUE}, '', 'quickset: COND item without value stays empty');

# Test: items with no COND and no value are fatal (if not caught)
@items = (
   {ITEM=>'Unknown', VALUE=>'', TEST=>'^[\S]+$'},
);
eval { quickset({}, @items) };
ok($@, 'quickset: dies on unknown item with no COND');

# Test: COND via quickstart value sets but empty
@items = (
   {ITEM=>'WinLink', VALUE=>'No',  TEST=>undef},
   {ITEM=>'CMS Call',VALUE=>'',    TEST=>'^[\S]+$', COND=>'WinLink'},
);
@result = quickset({'CMS Call'=>'K0NTS'}, @items);
is($result[1]{VALUE}, 'K0NTS', 'quickset: COND item can be set via quick hash');
done_testing();
