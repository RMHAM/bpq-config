#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests => 6;

# Test -h flag
my $help = `perl bpq-config -h 2>&1`;
like($help, qr/Version 1\.1\.0/, '-h shows version');
like($help, qr/offline/,        '-h mentions --offline');
is($?, 0, '-h exits successfully');

# Test -o/--offline flags by checking help output mentions it
my $off = `perl bpq-config --offline -h 2>&1`;
like($off, qr/offline/, '--offline + -h works');

# Test invalid flag shows error
my $bad = `perl bpq-config --bogus 2>&1`;
ok($? != 0, '--bogus exits with error');

# Test BPQ_OFFLINE env var
my $env = `BPQ_OFFLINE=1 perl bpq-config -h 2>&1`;
like($env, qr/offline/, 'BPQ_OFFLINE=1 does not break -h');
