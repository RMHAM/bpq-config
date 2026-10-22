#!/usr/bin/perl -w
use strict;
use warnings;

use Test::More tests => 4;

my $help = `perl bpq-config -h 2>&1`;
like($help, qr/Version 1\.1\.3/,  'Help shows version 1.1.3');
like($help, qr/offline/,          'Help shows --offline option');
like($help, qr/Interactive/,      'Help says Interactive program');
like($help, qr/AC0KQ/,            'Help credits original author');
