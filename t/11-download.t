#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use Cwd qw(getcwd);

use lib '.';
use t::helpers;

# fetch() refers to the file-scoped $failed counter
our $failed = 0;
our $offline;
extract_subs(qw(fetch starts samefile download extract selfupdate));

my $dir = tempdir(CLEANUP=>1);
my $bin = "$dir/bin";
mkdir $bin or die "Cannot create $bin: $!";

# Fake wget: behaviour selected by FAKE_WGET_MODE
my $wget = "$bin/wget";
open(my $fh,'>',$wget) or die "Cannot write $wget: $!";
print $fh <<'FAKE';
#!/usr/bin/perl
my ($out,$ua,$url);
while (@ARGV)
{
   my $arg = shift @ARGV;
   $out = shift @ARGV if ($arg eq '-O');
   $ua = shift @ARGV if ($arg eq '--user-agent');
   $url = $arg;
}
if (my $log = $ENV{FAKE_WGET_LOG})
{
   open(my $l,'>>',$log) or exit 1;
   print $l (($ua || '') . "\t" . ($url || '') . "\n");
   close($l);
}
my $mode = $ENV{FAKE_WGET_MODE} || 'ok';
exit 8 if ($mode eq '403');
exit 4 if ($mode eq 'network');
open(my $f,'>',$out) or exit 1;
binmode($f);
if ($mode eq 'html')
{
   print $f '<!DOCTYPE html><h1>403 Forbidden</h1>';
}
elsif ($mode ne 'empty')
{
   print $f (($url && $url =~ /\.zip$/) ? "PK\x03\x04" : "\x7fELF\x02\x01\x01");
}
close($f);
exit 0;
FAKE
close($fh);
chmod(0755,$wget);

local $ENV{PATH} = "$bin:$ENV{PATH}";

sub readfile
{
   my ($file) = @_;
   open(my $f,'<',$file) or return undef;
   binmode($f);
   local $/;
   my $data = <$f>;
   close($f);
   return $data;
}

my @warn;
local $SIG{__WARN__} = sub { push @warn, @_ };
sub reset_test { @warn = (); $failed = 0; }

# starts()
ok(starts($wget,'#!'), 'starts: detects script magic');
ok(!starts($wget,"\x7fELF"), 'starts: rejects wrong magic');

# samefile()
my $copy = "$dir/copy";
open(my $c,'>',$copy) or die $!;
print $c readfile($wget);
close($c);
ok(samefile($wget,$copy), 'samefile: identical files match');
open($c,'>>',$copy) or die $!;
print $c "\n";
close($c);
ok(!samefile($wget,$copy), 'samefile: different length does not match');
open($c,'>',$copy) or die $!;
print $c 'x' x (-s $wget);
close($c);
ok(!samefile($wget,$copy), 'samefile: same length, different content does not match');
ok(!samefile("$dir/nonexistent",$wget), 'samefile: missing file does not match');

# Successful download replaces the target
my $target = "$dir/pilinbpq";
open(my $t,'>',$target) or die $!;
print $t 'ORIGINAL';
close($t);
reset_test();
$ENV{FAKE_WGET_MODE} = 'ok';
ok(fetch('http://example.invalid/pilinbpq',$target,'test','elf'), 'fetch: success returns true');
like(readfile($target), qr/^\x7fELF/, 'fetch: success installs new content');
is($failed, 0, 'fetch: success is not counted');
is_deeply([glob("$target.download.*")], [], 'fetch: success leaves no temp file');

# A 403 keeps the existing file
open($t,'>',$target) or die $!;
print $t 'ORIGINAL';
close($t);
reset_test();
$ENV{FAKE_WGET_MODE} = '403';
ok(!fetch('http://example.invalid/pilinbpq',$target,'test','elf'), 'fetch: 403 returns false');
is(readfile($target), 'ORIGINAL', 'fetch: 403 keeps the existing file');
is($failed, 1, 'fetch: 403 is counted');
ok(scalar(grep { /403/ } @warn), 'fetch: 403 warning mentions the HTTP status');
ok(scalar(grep { /keeping existing/ } @warn), 'fetch: 403 warning says the old file is kept');
is_deeply([glob("$target.download.*")], [], 'fetch: 403 leaves no temp file');

# A 200 response that is really an HTML error page is rejected
reset_test();
$ENV{FAKE_WGET_MODE} = 'html';
ok(!fetch('http://example.invalid/pilinbpq',$target,'test','elf'), 'fetch: HTML error page returns false');
is(readfile($target), 'ORIGINAL', 'fetch: HTML error page keeps the existing file');
ok(scalar(grep { /not a valid elf/ } @warn), 'fetch: HTML error page is rejected as invalid content');

# An empty response is rejected
reset_test();
$ENV{FAKE_WGET_MODE} = 'empty';
ok(!fetch('http://example.invalid/pilinbpq',$target,'test','elf'), 'fetch: empty response returns false');
is(readfile($target), 'ORIGINAL', 'fetch: empty response keeps the existing file');
ok(scalar(grep { /empty response/ } @warn), 'fetch: empty response is reported');

# A missing destination is not created on failure
my $fresh = "$dir/piBPQAPRS";
reset_test();
$ENV{FAKE_WGET_MODE} = '403';
ok(!fetch('http://example.invalid/piBPQAPRS',$fresh,'test','elf'), 'fetch: failure with no existing file returns false');
ok(!-e $fresh, 'fetch: failure does not create the destination');
is($failed, 1, 'fetch: failure without existing file is counted');

# Network failure is reported distinctly
reset_test();
$ENV{FAKE_WGET_MODE} = 'network';
ok(!fetch('http://example.invalid/piBPQAPRS',$fresh,'test','elf'), 'fetch: network failure returns false');
ok(scalar(grep { /wget exit 4/ } @warn), 'fetch: network failure reports wget exit code');
is_deeply([glob("$dir/*.download.*")], [], 'fetch: failures leave no temp files');

# The User-Agent is sent with every request
open(my $log,'>',"$dir/wget.log") or die $!;
close($log);
$ENV{FAKE_WGET_LOG} = "$dir/wget.log";
$ENV{FAKE_WGET_MODE} = 'ok';
reset_test();
ok(fetch('http://example.invalid/pilinbpq',"$dir/ua-test",'test','elf'), 'fetch: success with UA logging');
my @logged = do { open(my $l,'<',"$dir/wget.log"); <$l> };
like($logged[0] // '', qr/^bpq-config .*\thttp:/, 'fetch: sends a bpq-config User-Agent');

# download() honours BPQ_MIRROR and requests every file from it
my $unzip = "$bin/unzip";
open(my $uz,'>',$unzip) or die $!;
print $uz "#!/bin/sh\nexit 0\n";
close($uz);
chmod(0755,$unzip);

my $work = "$dir/work";
mkdir $work or die $!;
my $origin = getcwd();
chdir $work or die $!;
open($log,'>',"$dir/mirror.log") or die $!;
close($log);
$ENV{FAKE_WGET_LOG} = "$dir/mirror.log";
$ENV{FAKE_WGET_MODE} = 'ok';
$ENV{BPQ_MIRROR} = 'http://mirror.example/bpq';
$offline = 1;
reset_test();
my $dl = download();
my @urls = map { chomp; (split /\t/)[1] } do { open(my $l,'<',"$dir/mirror.log"); <$l> };
is($dl, 1, 'download: succeeds against the mirror');
is(scalar(@urls), 6, 'download: requests all six items');
is(scalar(grep { m{^http://mirror\.example/bpq/} } @urls), 6, 'download: every request uses BPQ_MIRROR');
ok(!(grep { /cantab\.net/ } @urls), 'download: no request goes to cantab.net');
ok((-e 'pilinbpq'), 'download: installs pilinbpq from the mirror');
chdir $origin or die $!;

done_testing();
