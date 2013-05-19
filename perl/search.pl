#!/usr/bin/perl

$srcfile = "$ENV{DOCUMENT_ROOT}/../DCCC-LIII/800-53rev4controls-20130518.txt";

# What are we looking for?
$qstring = $ENV{QUERY_STRING};
$qstring =~ s/find=//;
$qstring =~ s/+/ /g;
$qstring =~ s/%([0-9A-Fa-f]{2})/pack("H2", $1)/ge;

open($fh, "<", $srcfile) or die "cannot open $srcfile";

$found = 0;
$results = qq(<table border="2">\n);
$results .= qq(<tr><th>Section</th><th>Type</th><th>Full-Text</th></tr>\n);
foreach $line (<$fh>) {
  if ($line =~ /$qstring/i) {
    $found += 1;
    ($section, $type, $text) = split(/:/, $line, 3);
    $text =~ s#($qstring)#<b>$1</b>#gi;
    $results .= qq(<tr><td valign="top">$section</td><td valign="top">$type</td><td valign="top">$text</td></tr>\n);
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
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <title>DCCC-LIII revision IV</title>
  <style>
  html { 
  background: black; 
  }
  body {
    background: #333;
    background: -webkit-linear-gradient(top, black, #666);
    background: -o-linear-gradient(top, black, #666);
    background: -moz-linear-gradient(top, black, #666);
    background: linear-gradient(top, black, #666);
    color: white;
    font-family: "Helvetica Neue",Helvetica,"Liberation Sans",Arial,sans-serif;
    width: 40em;
    margin: 0 auto;
    padding: 3em;
  }
  a {
    color: white;
  }

  h1 {
    text-transform: capitalize;
    -moz-text-shadow: -1px -1px 0 black;
    -webkit-text-shadow: 2px 2px 2px black;
    text-shadow: -1px -1px 0 black;
    box-shadow: 1px 2px 2px rgba(0, 0, 0, 0.5);
    background: #CC0000;
    width: 22.5em;
    margin: 1em -2em;
    padding: .3em 0 .3em 1.5em;
    position: relative;
  }
  h1:before {
    content: '';
    width: 0;
    height: 0;
    border: .5em solid #91010B;
    border-left-color: transparent;
    border-bottom-color: transparent;
    position: absolute;
    bottom: -1em;
    left: 0;
    z-index: -1000;
  }
  h1:after {
    content: '';
    width: 0;
    height: 0;
    border: .5em solid #91010B;
    border-right-color: transparent;
    border-bottom-color: transparent;
    position: absolute;
    bottom: -1em;
    right: 0;
    z-index: -1000;
  }
  h2 { 
    margin: 2em 0 .5em;
    border-bottom: 1px solid #999;
  }

  pre {
    background: black;
    padding: 1em 0 0;
    -webkit-border-radius: 1em;
    -moz-border-radius: 1em;
    border-radius: 1em;
    color: #9cf;
  }

  ul { 
    margin: 0; 
    padding: 0;
  }
  li {
    list-style-type: none;
    padding: .5em 0;
  }

  .brand {
    display: block;
    text-decoration: none;
  }
  .brand .brand-image {
    float: left;
    border:none;
  }
  .brand .brand-text {
    float: left;
    font-size: 24px;
    line-height: 24px;
    padding: 4px 0;
    color: white;
    text-transform: uppercase;
  }
  .brand:hover,
  .brand:active {
    text-decoration: underline;
  }

  .brand:before,
  .brand:after {
    content: ' ';
    display: table;
  }
  .brand:after {
    clear: both;
  }
  </style>
</head>
<body>
  <h1>
    Welcome to DCCC-VIII revision IV
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
