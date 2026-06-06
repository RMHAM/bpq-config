#!/usr/bin/perl -w
use strict;
use warnings;

use Test::More tests => 1;

my $output = `perl -c bpq-config 2>&1`;
like($output, qr/syntax OK/, 'bpq-config compiles without errors');
