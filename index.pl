#!/usr/bin/perl

print "Content-type: text/html\r\n\r\n";
print <<EOF
<!doctype html>
<html lang="en">
<head>
  <title>Hiero-Glyph</title>
</head>
<body>
 <a href="search.pl">Search IA controls from NIST SP 800-53 rev 4</a> <br/>
 <a href="search-v5.pl">Search IA controls from NIST SP 800-53 rev5 initial public draft</a> <br/>
 <a href="search-merged.pl">Search IA controls from NIST SP 800-53 rev4 and rev5 initial public draft</a> <br/>
 <a href="search-diffed.pl">Search IA control differences between NIST SP 800-53 rev4 and rev5 initial public draft</a> <br/>
</body>
</html>
EOF
