#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

# Test all validation regexes from @sys/@quick/@radio/@user/@map

# Node Callsign: ^[A-Za-z]+[0-9]+[A-Za-z]+$
my $callsign = qr/^[A-Za-z]+[0-9]+[A-Za-z]+$/;
ok('K0NTS'   =~ $callsign, 'callsign: K0NTS valid');
ok('N0CALL'  =~ $callsign, 'callsign: N0CALL valid');
ok('AC0KQ'   =~ $callsign, 'callsign: AC0KQ valid');
ok('K0NTS-1' !~ $callsign, 'callsign: K0NTS-1 invalid (no dash)');
ok(''        !~ $callsign, 'callsign: empty invalid');
ok('123'     !~ $callsign, 'callsign: digits only invalid');

# Node Callsign with SSID: ^[A-Za-z]+[0-9]+[A-Za-z]+(-\d+)?$
my $callssid = qr/^[A-Za-z]+[0-9]+[A-Za-z]+(-\d+)?$/;
ok('K0NTS'    =~ $callssid, 'call+ssid: K0NTS valid');
ok('K0NTS-1'  =~ $callssid, 'call+ssid: K0NTS-1 valid');
ok('K0NTS-10' =~ $callssid, 'call+ssid: K0NTS-10 valid');

# Owner Acronym: ^[\S]+$
ok('CTN'  =~ /^[\S]+$/, 'acronym: CTN valid');
ok(''     !~ /^[\S]+$/, 'acronym: empty invalid');

# Grid Square: ^[A-Z][A-Z][0-9][0-9][a-z][a-z]$
my $grid = qr/^[A-Z][A-Z][0-9][0-9][a-z][a-z]$/;
ok('DM79gr' =~ $grid, 'grid: DM79gr valid');
ok('DM799r' !~ $grid, 'grid: DM799r invalid (digit in 5th)');
ok(''       !~ $grid, 'grid: empty invalid');

# Frequency: ^[1-9][0-9][0-9][0-9][0-9][0-9]$
my $freq = qr/^[1-9][0-9][0-9][0-9][0-9][0-9]$/;
ok('145050' =~ $freq, 'freq: 145050 valid');
ok('14505'  !~ $freq, 'freq: 14505 invalid (5 digits)');
ok('045050' !~ $freq, 'freq: 045050 invalid (starts with 0)');

# CMS Callsign: ^(-|[A-Za-z]+[0-9]+[A-Za-z]+)$
my $cmscall = qr/^(-|[A-Za-z]+[0-9]+[A-Za-z]+)$/;
ok('K0NTS' =~ $cmscall, 'cms: K0NTS valid');
ok('-'     =~ $cmscall, 'cms: dash (none) valid');
ok(''      !~ $cmscall, 'cms: empty invalid');

# CMS Password: ^[\S]*$
ok('abc'  =~ /^[\S]*$/, 'cms pass: abc valid');
ok(''     =~ /^[\S]*$/, 'cms pass: empty valid (allows empty)');
ok('a b'  !~ /^[\S]*$/, 'cms pass: space invalid');

# APRS SSID: ^[0-9]+$
ok('11' =~ /^[0-9]+$/, 'aprs ssid: 11 valid');
ok(''   !~ /^[0-9]+$/, 'aprs ssid: empty invalid');

# APRS Symset/Symbol: ^[A-Za-z0-9]$
ok('B' =~ /^[A-Za-z0-9]$/, 'symset: B valid');
ok('a' =~ /^[A-Za-z0-9]$/, 'symset: a valid');
ok(''  !~ /^[A-Za-z0-9]$/, 'symset: empty invalid');

# Latitude: ^[1-9][0-9][0-9][0-9]\.[0-9][0-9][NS]$
my $lat = qr/^[1-9][0-9][0-9][0-9]\.[0-9][0-9][NS]$/;
ok('3903.35N' =~ $lat, 'lat: 3903.35N valid');
ok(''         !~ $lat, 'lat: empty invalid');

# Longitude: ^[0-9][0-9][0-9][0-9][0-9]\.[0-9][0-9][EW]$
my $lon = qr/^[0-9][0-9][0-9][0-9][0-9]\.[0-9][0-9][EW]$/;
ok('10515.23W' =~ $lon, 'lon: 10515.23W valid');
ok(''          !~ $lon, 'lon: empty invalid');

# Power/Height/Gain: ^[0-9]+(\.[0-9]*)?$
my $numeric = qr/^[0-9]+(\.[0-9]*)?$/;
ok('50'   =~ $numeric, 'numeric: 50 valid');
ok('12.5' =~ $numeric, 'numeric: 12.5 valid');
ok(''     !~ $numeric, 'numeric: empty invalid');

# Address (IP or DNS): ^(\d+\.\d+\.\d+.\d+|[\S]+)$
my $addr = qr/^(\d+\.\d+\.\d+.\d+|[\S]+)$/;
ok('10.0.0.1'  =~ $addr, 'addr: IPv4 valid');
ok('node.local' =~ $addr, 'addr: DNS valid');
ok(''           !~ $addr, 'addr: empty invalid');

# Port number: ^[1-9][0-9]+$
my $port = qr/^[1-9][0-9]+$/;
ok('10093' =~ $port, 'port: 10093 valid');
ok(''      !~ $port, 'port: empty invalid');
ok('0'     !~ $port, 'port: 0 invalid (starts with 0)');
done_testing();
