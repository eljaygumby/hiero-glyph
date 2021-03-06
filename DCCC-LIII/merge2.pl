#!/usr/bin/perl
#
# merge.pl - merge two 800-53 streams by control identifier
#

# text types

$texttype{title} = -1;
$texttype{withdrawn} = 0;
$texttype{text} = 1;
$texttype{supplement} = 2;
$texttype{references} = 3;
$texttype{priority} = 4;
$texttype{low} = 5;
$texttype{mod} = 6;
$texttype{high} = 7;

# compare control identifiers

sub compem {
  my @a, @b;
  my $aenhancement = 0;				# enhancements?
  my $benhancement = 0;

  @a = split(/[:-]/, $a, 4);			# (control family, "number, etc.", type, text)
  @aa = split(/ /, @a[1], 2);			# (number within control family, the rest of the identifier)
  $aenhancement = 1 if ($aa[1] =~ /^[(]/);	# control enhancement?
  $aenhancement = 2 if ($texttype{$a[2]} > 2);	# extra stuff goes after enhancements
  @b = split(/[:-]/, $b, 4);
  @bb = split(/ /, @b[1], 2);
  $benhancement = 1 if ($bb[1] =~ /^[(]/);
  $benhancement = 2 if ($texttype{$a[2]} > 2);
#print "a is $a control family is $a[0], number is $aa[0], enhancement is $aenhancement, type is $a[2]/$texttype{$a[2]}, the rest is x$aa[1]x\n";
#print "b is $b control family is $b[0], number is $bb[0], enhancement is $benhancement, type is $b[2]/$texttype{$b[2]}, the rest is x$bb[1]x\n";
  if ($a[0] eq $b[0]) {					# control family
    if ($aa[0] == $bb[0]) {				# control family number
      if ($aenhancement == $benhancement) {		# enhancement?
        if ($aenhancement == 1) {			# comparing enhancements
          @aaa = split(/[()]/, $aa[1], 3);		# enhancement number, the rest of the identifier
          @bbb = split(/[()]/, $bb[1], 3);		# enhancement number, the rest of the identifier
#print "aenhancement number is $aaa[1]\n";
#print "benhancement number is $bbb[1]\n";
          if ($aaa[1] == $bbb[1]) {
            if ($texttype{$a[2]} == $texttype{$b[2]}) {	# type
              return $aa[1] cmp $bb[1];			# the rest of the ID
            } else {
              return $texttype{$a[2]} <=> $texttype{$b[2]};
            }
          } else {
            return $aaa[1] <=> $bbb[1];
          } 
        } else {
          if ($texttype{$a[2]} == $texttype{$b[2]}) {	# type
            return $aa[1] cmp $bb[1];			# the rest of the ID
          } else {
            return $texttype{$a[2]} <=> $texttype{$b[2]};
          }
        }
      } else {
        return $aenhancement <=> $benancement;
      }
    } else {
      return $aa[0] <=> $bb[0];
    }
  } else {
    return $a[0] cmp $b[0];
  }
}

die "merge.pl file1 file2" if (@ARGV != 2);

open(FILE1, $ARGV[0]);
@file1 = <FILE1>;
close FILE1;
open(FILE2, $ARGV[1]);
@file2 = <FILE2>;
close FILE2;

push @file1, @file2;
#print @file1;
print $_ for sort compem @file1;

