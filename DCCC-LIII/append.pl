$x = shift;
while (<>) {
  chomp;
  print "$_$x\n";
}
