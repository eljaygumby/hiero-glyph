#!/usr/bin/perl


$srcfile = "$ENV{DOCUMENT_ROOT}/DCCC-LIII/800-53v4v5diffed.txt";

# What are we looking for?
$qstring = $ENV{QUERY_STRING};
$qstring =~ s/find=//;
$qstring =~ s/[+]/ /g;
$qstring =~ s/%([0-9A-Fa-f]{2})/pack("H2", $1)/ge;

open($fh, "<", $srcfile) or die "cannot open $srcfile";

$error = "";
eval {'xxxx' =~ /$qstring/};
$error = $@ if $@;

sub clicketysplit {
  my ($id) = @_;
  my (@headers, $i, $rebuild, $returned);

  $returned = "";
  @headers = split(/ /, $id);
  for ($i=0;$i<scalar(@headers);$i++) {
    if ($i == 0) {
      $rebuild = $headers[$i];
    } else {
      $rebuild = qq($rebuild $headers[$i]);
    }
    $rebuilt = $rebuild;
    $rebuilt =~ s/\(/\\(/g;
    $rebuilt =~ s/\)/\\)/g;
    $returned = qq($returned <a href="search-diffed.pl?find=^$rebuilt\[ :]">$headers[$i]</a>);
  }
  return $returned;
}

$found = 0;
$results = qq(<table border="2">\n);
$results .= qq(<tr><th>Section</th><th>Type</th><th>Split</th><th>Full-Text</th></tr>\n);
if ($qstring ne "" && $error eq "") {
  foreach $line (<$fh>) {
    if ($line =~ /$qstring/i) {
      chomp $line;
      $found += 1;
      ($section, $type, $text) = split(/:/, $line, 3);

      # make section numbers clickable in section column
      $escaped = $section;
      $escaped =~ s/\(/\\(/g;
      $escaped =~ s/\)/\\)/g;
      $linkbait = $escaped; # save to link to split 
      $escaped = &clicketysplit($section);

      # make enhancements in withdrawn controls clickable
      if ($type eq 'withdrawn') {
        $text =~ s#([A-Z]{2}-[0-9]+ \([0-9]+\))#<a href="search-diffed.pl?find=^$1\[ :\]">$1</a>#g; 
        # escape parens in the regex
        $text =~ s/(\))\[/\\$1\[/g; # escape closing parens, identified by open square bracket
        $text =~ s/(\([0-9]+)\\\)\[/\\$1\\\)\[/g; # escape opening parens, identified by previous regex
      }

      # make related controls (but not enhancements) clickable in the text
      $text =~ s# ([A-Z]{2}-[0-9]+)# <a href="search-diffed.pl?find=^$1\[ :\]">$1</a>#g;

      # make baseline selections clickable
      if ($type =~ /^(low|mod|high)$/) {
        # main control
        $text =~ s#([A-Z]{2}-[0-9]+)# <a href="search-diffed.pl?find=^$1\[ :\]">$1</a>#g;
        # enhancements
        $text =~ s# \(([0-9]+)\)# <a href="search-diffed.pl?find=^$section \\($1\\)\[ :\]">($1)</a>#g;
      }

      # highlight text that matches the search string, outside HTML elements
      $text =~ s#(?!<[^>]*)($qstring)(?![^<]*>)#<b>$1</b>#gi;

      $results .= qq(<tr><td valign="top" nowrap>$escaped</td><td valign="top">$type</td><td valign="top"><a href="search-merged.pl?find=^$linkbait:$type:">Split</a></td><td valign="top">$text</td></tr>\n);
    }
  }
}
if ($found == 0) {
  $results .= qq(<tr><td colspan="4">No results found</td></tr>\n);
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
  <title>DCCC-LIII revision IV/V diffed</title>
  <style>
    ins { color:green; }
    del { color:red; } 
  </style>
</head>
<body>
  <h1>
    Welcome to DCCC-LIII revision IV/V diffed 
  </h1>
  <form action="search-diffed.pl" method="GET">
    New search:  <input type="text" name="find">
  </form>
  <p>
    Search string: <b>$qstring</b>
  </p>
  <p>
    Result count:  $found<br>
    $results
  </p>
  <p>
    <a href="/">Home</a>
  </p>
</body>
</html>
EOF

