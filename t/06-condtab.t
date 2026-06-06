#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

use lib '.';
use t::helpers;

extract_subs(qw(condtab find));

# condtab filters items based on CONDITIONS

# Test: no COND fields — all items returned
my @in = (
   {ITEM=>'A', VALUE=>'x'},
   {ITEM=>'B', VALUE=>'y'},
);
my @out = condtab(@in);
is(scalar @out, 2, 'condtab: no COND returns all items');

# Test: COND item visible when condition true (value eq 'Yes')
@in = (
   {ITEM=>'Enable', VALUE=>'Yes'},
   {ITEM=>'Extra',  VALUE=>'z',   COND=>'Enable'},
);
@out = condtab(@in);
is(scalar @out, 2, 'condtab: condition met includes conditional item');

# Test: COND item hidden when condition false (value ne 'Yes')
@in = (
   {ITEM=>'Enable', VALUE=>'No'},
   {ITEM=>'Extra',  VALUE=>'z',   COND=>'Enable'},
);
@out = condtab(@in);
is(scalar @out, 1, 'condtab: condition not met excludes item');

# Test: COND=>undef items are always included
@in = (
   {ITEM=>'A', VALUE=>'1'},
   {ITEM=>'B', VALUE=>'2', COND=>undef},
);
@out = condtab(@in);
is(scalar @out, 2, 'condtab: COND=>undef always included');

# Test: COND=Item=Value where value is specific
@in = (
   {ITEM=>'Device', VALUE=>'USB'},
   {ITEM=>'Speed',  VALUE=>'9600', COND=>'Device=USB'},
);
@out = condtab(@in);
is(scalar @out, 2, 'condtab: COND=Device=USB shown when Device=USB');

@in = (
   {ITEM=>'Device', VALUE=>'Serial'},
   {ITEM=>'Speed',  VALUE=>'9600', COND=>'Device=USB'},
);
@out = condtab(@in);
is(scalar @out, 1, 'condtab: COND=Device=USB hidden when Device=Serial');
done_testing();
