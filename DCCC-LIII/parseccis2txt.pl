$slash = $/;

undef $/;

$file = <>;

$/ = $slash;

$file =~ s/\r//g;

@iacontrols = split(/<H1[^>]*>([A-Z][A-Z]-[0-9]+)\s+(.*?)\s*<\/H1>\s*\n/, $file);

# remove initial trash
splice(@iacontrols, 0, 7);

while (($id, $title, $iacontrol) = splice(@iacontrols, 0, 3)) {

# start a new iacontrol
  print "$id:title:$title\n";

# clean up iacontrol text
  $iacontrol =~ s#</?[^>]*>##gm;  # remove all X/HTML tags
  $iacontrol =~ s#^\s+##gm;  # remove all leading whitespace

#  dissect control
  if (@controlpieces = split(/Control:\s+(.*?)\s*\nSupplemental Guidance:\s+(.*?)\s*\n(Control Enhancements:\s+.*?\s*\n)?References:\s+(.*?)\.\s*?\n/s, $iacontrol)) {

    ($cruft, $control, $supplement, $enhancements, $references) = @controlpieces;

# is it withdrawn?
    if ($cruft =~ /\[Withdrawn:/) {
#      print qq( status="Withdrawn"/>\n);
      print "$id:withdrawn\n";
      next;
    }

    printcontrol($id, $control);
    printelement($id, 'supplement', $supplement);
    printenhancements($id, $enhancements);
    printelement($id, references, $references);


# complain if it is anything else
  } else {
    die "What's wrong with $bit?\n";
  }
}

sub printcontrol {
  my ($controlid, $control) = @_;
  my ($id, $text);
  my (@subcontrols) = split(/([a-z]+)\.\s+/s, $control);

  printelement($controlid, 'text', $subcontrols[0]);
  my $controltext = shift @subcontrols;

  if (@subcontrols > 1) {
    while (($id, $text) = splice(@subcontrols, 0, 2)) {
#      print qq(<control id="$id">\n);
      printsubcontrol("$controlid $id", $text, $controltext);
    }
  }
}

sub printsubcontrol {
  my ($controlid, $control, $supercontrol) = @_;
  my ($id, $text);
  my (@subcontrols) = split(/([0-9]+)\.\s+/s, $control);

#  print qq(<text>$subcontrols[0]</text>\n);
  printelement("$controlid", 'text', "$supercontrol $subcontrols[0]");
  my $controltext = shift @subcontrols;

  if (@subcontrols > 1) {
    while (($id, $text) = splice(@subcontrols, 0, 2)) {
#      print qq(<control id="$id">\n);
      printelement("$controlid $id", 'text', "$supercontrol $controltext $text");
    }
  }
}

sub printelement {
  my ($id, $element, $text) = @_;

  $text =~ s/(\n|\s+)/ /gs;  # remove unnecessary newlines and extra spaces
  $text =~ s/\s+$//gs;  # remove trailing spaces
#print qq(id is "$id"\nelement is "$element"\ntext is "$text"\n);
  print qq($id:$element:$text\n);
 
}

sub printenhancements {
  my ($controlid, $enhancement) = @_;
  my (@enhancements);
  my ($id, $title, $text, $supplement);

  $enhancement =~ s/^Control Enhancements:\s+//;
#  @enhancements = split(/(\([0-9]+\))\s+([A-Z \/-]{2,})\s*\n(.*?)\n(Supplemental Guidance:\s+.*?\n)?\s*/s, $enhancement);
  @enhancements = split(/(\([0-9]+\))\s+?([A-Z \/_|-]{2,}?)\s*\n/s, $enhancement);
  if ($enhancements[0] !~ /^\s*None\.\s*$/) {
    shift @enhancements;
    while (($id, $title, $text) = splice(@enhancements, 0, 3)) {
      print qq($controlid $id:title:$title\n);
      printsubenhancements("$controlid $id", $text);
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
    print qq($controlid:withdrawn\n);
  } else {
    @subenhancements = split(/(\([a-z]+\))\s+/, $control);
    $super = splice(@subenhancements, 0, 1);
    printelement("$controlid", 'text', $super);
    while (($seid, $text) = splice(@subenhancements, 0, 2)) {
#      print qq(<control id="$id">\n);
      printsubsubenhancements("$controlid $seid", $text, $super);
    }
    if ($supplement !~ /^\s*$/s) {
      printelement($controlid, 'supplement', $supplement);
    }
  }
}

sub printsubsubenhancements {
  my ($controlid, $subenhancement, $superenhancement) = @_;
  my (@subenhancements);
  my ($id, $text, $main);

  @subenhancements = split(/(\([0-9]+\))\s+/, $subenhancement);
  $main = splice(@subenhancements, 0, 1);
  printelement($controlid, 'text', "$superenhancement $main");
  while (($id, $text) = splice(@subenhancements, 0, 2)) {
#    print qq(<control id="$id">\n);
    printelement("$controlid $id", 'text', "$superenhancement $main $text");
  }
}
