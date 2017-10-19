$types{title} = 1;
$types{withdrawn} = 2;
$types{text} = 3;
$types{supplement} = 4;
$types{references} = 5;
$types{priority} = 6;
$types{low} = 7;
$types{mod} = 8;
$types{high} = 9;

while (<>) {
  ($id, $type) = split(/:/);
  chomp $type;

  if ($id !~ /[()]/) { # not an enhancement
    $enhno = 0;
    ($family, $familyindex, $section, $sub) = split(/[ ()-]/, $id);
    if ($types{$type} < 5) {
      $area = 1;
    } elsif ($types{$type} > 4) {
      $area = 3;
    }
    $section = '~' if $type eq "supplement" && $area == 1; # put supplements after sections in main controls
  } else { # an enhancement
    ($family, $familyindex, $enhno, $section, $sub) = split(/[ ()-]+/, $id);
    $area = 2;
  }

  printf "$family";
  printf "%02d", $familyindex;
  printf "$area";
  printf "%02d", $enhno;
  printf "%d", $types{$type};
  printf "%03d", ord($section);
  printf "%03d", ord($sub);
  print ":::$_";
}
