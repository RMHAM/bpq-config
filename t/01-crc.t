#!/usr/bin/perl -w
use strict;
use warnings;

use Test::More tests => 3;

# Load crc16 sub from main script
my $crc;
{
   local $/;
   open(my $fh, '<', 'bpq-config') or die "Cannot open bpq-config: $!";
   my $code = <$fh>;
   close($fh);
   $code =~ s/^.*?sub crc16/\nsub crc16/ms;
   $code =~ s/sub filehash.*//ms;
   eval $code;
   die "Cannot compile crc16: $@" if $@;
}

# Test known CRC16 values
is(crc16(""), 0, 'CRC16 of empty string is 0');
isnt(crc16("hello"), 0, 'CRC16 of "hello" is non-zero');
my $crc_hello = crc16("hello");
is(crc16("hello"), $crc_hello, 'CRC16 is deterministic');
