#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

# Lint bpq-config with Perl::Critic using the repo profile.
# Plain `prove t/` skips when perlcritic is not installed; the pre-commit hook
# sets BPQ_REQUIRE_LINT=1 so a missing linter blocks the commit.

sub find_critic
{
   my $env = $ENV{PERLCRITIC};
   return $env if ($env && -x $env);
   foreach my $dir (split(/:/,$ENV{PATH} || ''))
   {
      return "$dir/perlcritic" if (-x "$dir/perlcritic");
   }
   my $local = "$ENV{HOME}/perl5/bin/perlcritic";
   return $local if (-x $local);
   return;
}

my $critic = find_critic();
if (!$critic)
{
   my $msg = 'perlcritic not installed - run: cpanm --with-develop --installdeps .';
   BAIL_OUT($msg) if ($ENV{BPQ_REQUIRE_LINT});
   plan skip_all => $msg;
}

# A local::lib install needs its lib directory on PERL5LIB
if ($critic eq "$ENV{HOME}/perl5/bin/perlcritic")
{
   $ENV{PERL5LIB} = "$ENV{HOME}/perl5/lib/perl5" .
      (defined($ENV{PERL5LIB}) && $ENV{PERL5LIB} ne '' ? ":$ENV{PERL5LIB}" : '');
}

my $cmd = $critic;
$cmd =~ s/'/'\\''/g;
my $out = `'$cmd' --profile .perlcriticrc bpq-config 2>&1`;
is($?, 0, 'perlcritic: bpq-config passes the profile') or diag($out);
done_testing();
