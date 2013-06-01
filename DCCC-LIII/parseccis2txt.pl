#!/usr/bin/perl

# parseccis2txt.pl [-x] <filename>
#  convert 800-53rev4 pseudo-XML to text

$xml = 0;
if ($ARGV[0] eq '-x') {
  shift;
  $xml = 1;
}

$slash = $/;

undef $/;

$file = <>;

$/ = $slash;

$file =~ s/\r//g;

@iacontrols = split(/<H1[^>]*>([A-Z][A-Z]-[0-9]+)\s+(.*?)\s*<\/H1>\s*\n/, $file);

if ($xml == 1) {
  print qq(<?xml version="1.0" ?>\n);
  print qq(<IAcontrols>\n);
}

# remove initial trash
splice(@iacontrols, 0, 7);

while (($id, $title, $iacontrol) = splice(@iacontrols, 0, 3)) {

# start a new iacontrol
  if ($xml == 1) {
    print qq(<IAcontrol id="$id" title="$title");
  } else {
    print "$id:title:$title\n";
  }

# clean up iacontrol text
  $iacontrol =~ s#</?[^>]*>##gm;  # remove all X/HTML tags
  $iacontrol =~ s#^\s+##gm;  # remove all leading whitespace

#  dissect control
  if (@controlpieces = split(/Control:\s+(.*?)\s*\nSupplemental Guidance:\s+(.*?)\s*\n(Control Enhancements:\s+.*?\s*\n)?References:\s+(.*?)\.\s*?\n/s, $iacontrol)) {

    ($cruft, $control, $supplement, $enhancements, $references) = @controlpieces;

# is it withdrawn?
    if ($cruft =~ /\[Withdrawn:/) {
      if ($xml == 1) {
        print qq( status="Withdrawn"/>\n);
      } else {
        print "$id:withdrawn\n";
      }
      next;
    }

    if ($xml == 1) {
      print qq(>\n);
    }
    printcontrol($id, $control);
    printelement($id, 'supplement', $supplement, $supplement);
    printenhancements($id, $enhancements);
    printelement($id, references, $references, $references);


# complain if it is anything else
  } else {
    die "What's wrong with $bit?\n";
  }

  if ($xml == 1) {
    print "</IAcontrol>\n";
  }
}

if ($xml == 1) {
  print "</IAcontrols>\n";
}

sub printcontrol {
  my ($controlid, $control) = @_;
  my ($id, $text);
  my (@subcontrols) = split(/\n([a-z]+)\.\s+/s, $control);

  printelement($controlid, 'text', $subcontrols[0], $subcontrols[0]);
  my $controltext = shift @subcontrols;

  if (@subcontrols > 1) {
    while (($id, $text) = splice(@subcontrols, 0, 2)) {
      if ($xml == 1) {
        print qq(<control id="$id">\n);
      }
      printsubcontrol("$controlid $id", $text, $controltext);
      if ($xml == 1) {
        print qq(</control>\n);
      }
    }
  }
}

sub printsubcontrol {
  my ($controlid, $control, $supercontrol) = @_;
  my ($id, $text);
  my (@subcontrols) = split(/([0-9]+)\.\s+/s, $control);

  if ($xml == 1) {
    printelement($controlid, 'text', $subcontrols[0], $subcontrols[0]);
  } else {
    printelement("$controlid", 'text', $subcontrols[0], "$supercontrol $subcontrols[0]");
  }
  my $controltext = shift @subcontrols;

  if (@subcontrols > 1) {
    while (($id, $text) = splice(@subcontrols, 0, 2)) {
      if ($xml == 1) {
        print qq(<control id="$id">\n);
        printelement($id, 'text', $text, $text);
        print qq(</control>\n);
      } else {
        printelement("$controlid $id", 'text', $text, "$supercontrol $controltext $text");
      }
    }
  }
}

sub printelement {
  my ($id, $element, $text, $fulltext) = @_;

  $text =~ s/(\n|\s+)/ /gs;  # remove unnecessary newlines and extra spaces
  $text =~ s/\s+$//gs;  # remove trailing spaces
  $fulltext =~ s/(\n|\s+)/ /gs;  # remove unnecessary newlines and extra spaces
  $fulltext =~ s/\s+$//gs;  # remove trailing spaces
  if ($xml == 1) {
    print qq(<$element>$text</$element>\n);
  } else {
    print qq($id:$element:$fulltext\n);
  } 
}

sub printenhancements {
  my ($controlid, $enhancement) = @_;
  my (@enhancements);
  my ($id, $title, $text, $supplement);

  $enhancement =~ s/^Control Enhancements:\s+//;
#  @enhancements = split(/(\([0-9]+\))\s+([A-Z \/-]{2,})\s*\n(.*?)\n(Supplemental Guidance:\s+.*?\n)?\s*/s, $enhancement);
  @enhancements = split(/(\([0-9]+\))\s+?([A-Z \/_|,-]{2,}?)\s*\n/s, $enhancement);
  if ($enhancements[0] !~ /^\s*None\.\s*$/) {
    shift @enhancements;
    while (($id, $title, $text) = splice(@enhancements, 0, 3)) {
      if ($xml == 1) {
        print qq(<control id="$id" title="$title");
      } else {
        print qq($controlid $id:title:$title\n);
      }
      printsubenhancements("$controlid $id", $text);
      if ($xml == 1) {
        print qq(</control>\n);
      }
    }
  }
}


sub printsubenhancements {
  my ($controlid, $subenhancement) = @_;
  my (@subenhancements);
  my ($id, $text);
  my ($control, $supplement);
  my ($super);

  ($control, $supplement) = split(/\s*Supplemental Guidance:\s+/, $subenhancement);
  if ($control =~ /\[Withdrawn:/) {
    if ($xml == 1) {
      print qq( status="withdrawn">\n);
    } else {
      print qq($controlid:withdrawn\n);
    }
  } else {
    if ($xml == 1) {
      print qq(>\n);
    }
    @subenhancements = split(/(\([a-z]+\))\s+/, $control);
    $super = splice(@subenhancements, 0, 1);
    printelement("$controlid", 'text', $super, $super);
    while (($seid, $text) = splice(@subenhancements, 0, 2)) {
      if ($xml == 1) {
        print qq(<control id="$seid">\n);
      }
      printsubsubenhancements("$controlid $seid", $text, $super);
      if ($xml == 1) {
        print qq(</control>\n);
      }
    }
    if ($supplement !~ /^\s*$/s) {
      printelement($controlid, 'supplement', $supplement, $supplement);
    }
  }
}

sub printsubsubenhancements {
  my ($controlid, $subenhancement, $superenhancement) = @_;
  my (@subenhancements);
  my ($id, $text, $main);

  @subenhancements = split(/(\([0-9]+\))\s+/, $subenhancement);
  $main = splice(@subenhancements, 0, 1);
  printelement($controlid, 'text', $main, "$superenhancement $main");
  while (($id, $text) = splice(@subenhancements, 0, 2)) {
    if ($xml == 1) {
      print qq(<control id="$id">\n);
    }
    printelement("$controlid $id", 'text', $text, "$superenhancement $main $text");
    if ($xml == 1) {
      print qq(</control>\n);
    }
  }
}
