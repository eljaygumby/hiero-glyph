#!/usr/bin/perl

use Algorithm::Diff 'traverse_sequences';

while (<>) {
  chomp;

  @input = split(/:/, $_);

  $index = shift @input;
  $source = pop @input;

  $output{$index}{$source} = join(":", @input) . "\n";
}

foreach $index (sort keys %output) {
  $v4 = $output{$index}{v4};
  $v5ipd = $output{$index}{v5ipd};
  @v4 = split(/:/, $v4);
  @v5ipd = split(/:/, $v5ipd);
  ($v4id, $v4type) = splice(@v4, 0, 2);
  ($v5ipdid, $v5ipdtype) = splice(@v5ipd, 0, 2);

  $v4id ne "" ? print "$v4id:" : print "$v5ipdid:";
  $v4type ne "" ? print "$v4type:" : print "$v5ipdtype:";
  @a = split(//, join(":", @v4));
  @b = split(//, join(":", @v5ipd));

traverse_sequences(
  \@a,    # first sequence
  \@b,    # second sequence
  {
    MATCH     => \&match,    # callback on identical lines
    DISCARD_A => \&onlya,    # callback on A-only
    DISCARD_B => \&onlyb,    # callback on B-only
  }
);
print "\n" if scalar(@b) == 0 || scalar(@a) == 0;
}

sub match {
  my ($aidx, $bidx) = @_;
  print "$a[$aidx]";
}

sub onlya {
  my ($aidx, $bidx) = @_;
  if ($a[$aidx] ne "\n") {
    print "<del>$a[$aidx]</del>";
  }
}

sub onlyb {
  my ($aidx, $bidx) = @_;
  if ($b[$bidx] ne "\n") {
    print "<ins>$b[$bidx]</ins>";
  }
}

