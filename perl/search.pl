#!/usr/bin/perl

$srcfile = "$ENV{DOCUMENT_ROOT}/../DCCC-LIII/800-53rev4controls.txt";

# What are we looking for?
$qstring = $ENV{QUERY_STRING};
$qstring =~ s/find=//;
$qstring =~ s/[+]/ /g;
$qstring =~ s/%([0-9A-Fa-f]{2})/pack("H2", $1)/ge;

open($fh, "<", $srcfile) or die "cannot open $srcfile";

$found = 0;
$results = qq(<table border="2">\n);
$results .= qq(<tr><th>Section</th><th>Type</th><th>Full-Text</th></tr>\n);
if ($qstring ne "") {
  foreach $line (<$fh>) {
    if ($line =~ /$qstring/i) {
      $found += 1;
      ($section, $type, $text) = split(/:/, $line, 3);
      $escaped = $section;
      $escaped =~ s/\(/\\(/g;
      $escaped =~ s/\)/\\)/g;
      $text =~ s#($qstring)#<b>$1</b>#gi;
      $results .= qq(<tr><td valign="top" nowrap><a href="search.pl?find=^$escaped">$section</a></td><td valign="top">$type</td><td valign="top">$text</td></tr>\n);
    }
  }
}
if ($found == 0) {
  $results .= qq(<tr><td colspan="3">No results found</td></tr>\n);
}
$results .= qq(</table>\n);

# defuse any entities or markup
$qstring =~ s/&/&amp;/g;
$qstring =~ s/</&lt;/g;

print "Content-type: text/html\r\n\r\n";
print <<EOF
<!doctype html>
<html lang="en">
<head>
  <title>DCCC-LIII revision IV</title>
</head>
<body>
  <h1>
    Welcome to DCCC-LIII revision IV
  </h1>
  <form action="search.pl" method="GET">
    New search:  <input type="text" name="find">
  </form>
  <p>
    Search string: <b>$qstring</b>
  </p>
  <p>
    Result count:  $found<br>
    $results
  </p>
</body>
</html>
EOF
