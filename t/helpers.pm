package t::helpers;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw(extract_subs);

# Extract named subs from bpq-config and compile them into the caller's package
# Caller must specify ALL needed subs (including transitive deps).
sub extract_subs
{
   my @wanted = @_;
   my $fh;
   open($fh, '<', 'bpq-config') or die "Cannot open bpq-config: $!";
   local $/;
   my $code = <$fh>;
   close($fh);

   # Strip shebang
   $code =~ s/^#!.*\n//;

   # Strip POD at the end
   $code =~ s/=head1.*//ms;

   # Build a hash of all sub definitions
   my %subs;
   while ($code =~ /^(sub\s+\w+\s*\{.*?^\})/msg)
   {
      my $sub = $1;
      $sub =~ /^sub\s+(\w+)/ or next;
      $subs{$1} = $sub;
   }

   # Check all wanted subs exist
   for my $name (@wanted)
   {
      die "Sub '$name' not found in bpq-config\n" unless exists $subs{$name};
   }

   # Compile into caller's package
   my $caller = caller;
   my $compiled = "package $caller;\nuse strict;\nuse warnings;\nno warnings 'redefine';\n";
   for my $name (@wanted)
   {
      $compiled .= $subs{$name} . "\n\n";
   }
   $compiled .= "1;\n";

   my $result = eval $compiled;
   die "Cannot compile subs (@wanted): $@" if $@;
   1;
}

1;
