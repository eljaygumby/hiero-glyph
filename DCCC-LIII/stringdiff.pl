#!/usr/bin/perl

use Algorithm::Diff 'traverse_sequences';

$a = $ARGV[0];
$b = $ARGV[1];

@a = split(//, $a);
@b = split(//, $b);

sub match {
  my ($aidx, $bidx) = @_;
  print "$a[$aidx]";
}

sub onlya {
  my ($aidx, $bidx) = @_;
  print "<del>$a[$aidx]</del>";
}

sub onlyb {
  my ($aidx, $bidx) = @_;
  print "<ins>$b[$bidx]</ins>";
}

traverse_sequences(
  \@a,    # first sequence
  \@b,    # second sequence
  {
    MATCH     => \&match,     # callback on identical lines
    DISCARD_A => \&onlya,    # callback on A-only
    DISCARD_B => \&onlyb,    # callback on B-only
  }
);
print;
