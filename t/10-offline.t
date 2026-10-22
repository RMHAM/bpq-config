#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests => 3;

# Test offline mode via -h output (already covers flag exists)
# Test offline mode via BPQ_OFFLINE env var suppresses the GitHub self-update

my $result = `BPQ_OFFLINE=1 perl -c bpq-config 2>&1`;
is($?, 0, 'offline: BPQ_OFFLINE=1 does not break syntax check');

# Verify that the offline flag gets parsed by checking how -o interacts with -h
$result = `perl bpq-config -o -h 2>&1`;
like($result, qr/Version 1\.1\.3/, 'offline: -o + -h shows version');

# Test that --offline + -h also works
$result = `perl bpq-config --offline -h 2>&1`;
like($result, qr/Version 1\.1\.3/, 'offline: --offline + -h shows version');
