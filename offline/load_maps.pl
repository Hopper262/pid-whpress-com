#!/usr/bin/env perl
use strict;
use warnings 'FATAL' => 'all';
use XML::Writer ();
use XML::Simple ();
use Encode ();
use FindBin ();
use JSON ();
use String::CRC32 ();
use Carp ();

$ENV{'USEROOT'} = $FindBin::Bin . '/..';
require '../modules/pid.ph';
$SIG{__DIE__} = \&Carp::confess;

require '../modules/io.subs';


my ($vers, $mapfile) = @ARGV;
die "Usage: $0 <version> < <mapfile>\n"
  unless ($vers =~ /^(full11|full20|demoA1|demo20)$/);

# read map
my (@leveldata);
binmode STDIN;
while (!eof(STDIN))
{
  my $data;
  read(STDIN, $data, 16834);
  push(@leveldata, $data);
}

# generate XML - yeah, I don't feel like rewriting this
my $xmldata;
my $out = XML::Writer->new('OUTPUT' => \$xmldata, 'DATA_MODE' => 1, 'DATA_INDENT' => '  ', 'ENCODING' => 'us-ascii');
$out->startTag('pid_map');

for (my $level_idx = 0; $level_idx < scalar @leveldata; $level_idx++)
{
  SetReadSource($leveldata[$level_idx]);
  
  my $namesize = ReadUint8();
  my $name = Encode::decode("MacRoman", ReadRaw($namesize));
  ReadPadding(127 - $namesize);
  
  my $levelnum = ReadSint32();
  warn "Level mismatch: $levelnum vs. $level_idx\n" if ($levelnum != $level_idx);
  
  my $height = ReadSint16() / 10;
  
  my $startx = ReadSint32();
  my $starty = ReadSint32();
  
  $out->startTag('level', 'index' => $level_idx, 'name' => $name, 'height' => $height);
  
  # textures
  $out->startTag('load_collections');
  for my $ltex_idx (0..7)
  {
    my $tdesc = ReadUint16();
    next if $tdesc == 0xFFFF;
    my $var = ($tdesc >> 12);
    my $set = ($tdesc & 0x0FFF);
    $out->emptyTag('load_collection', 'index' => $ltex_idx, 'collection' => $set, 'color_table' => $var);
  }
  $out->endTag('load_collections');
  
  $out->startTag('doors');
  for my $door_idx (0..14)
  {
    my $x = ReadSint16();
    my $y = ReadSint16();
    my $dir = ReadSint16();
    my $tex = ReadSint16();
    
    next if $dir < 0;
    $out->emptyTag('door', 'index' => $door_idx, 'direction' => $dir, 'x' => $x, 'y' => $y, 'texture' => $tex);
  }
  $out->endTag('doors');
  
  $out->startTag('level_changes');
  for my $change_idx (0..19)
  {
    my $type = ReadSint16();
    my $lev = ReadSint16();
    my $x = ReadSint16();
    my $y = ReadSint16();
    
    next if $type < 0;
    $out->emptyTag('level_change', 'index' => $change_idx, 'type' => $type, 'level' => $lev, 'x' => $x, 'y' => $y);
  }
  $out->endTag('level_changes');
  
  $out->startTag('monsters');
  for my $mon_idx (0..2)
  {
    # tbd - PID_Monster
    my $type = ReadSint16();
    my $freq = ReadSint16();
    
    next if $type < 0;
    $out->emptyTag('monster', 'index' => $mon_idx, 'type' => $type, 'frequency' => $freq);
  }
  $out->endTag('monsters');
  
  $out->startTag('sectors');
  for my $row (0..31)
  {
    for my $col (0..31)
    {
      
      my @wattrs;
      for my $wtype (qw(bottom left corner_br corner_bl corner_tr corner_tl))
      {
        my $type = ReadUint8();
        my $tex = ReadUint8();
        push(@wattrs, $wtype . '_type' => $type) if ($type != 0);
        push(@wattrs, $wtype . '_texture' => $tex) if ($tex != 0);
      }
      
      my $item = ReadSint16();
      my $type = ReadUint8();
      my $addl = ReadUint8();
      
      next if ($type < 1 && !scalar(@wattrs)); # skip void, so our file isn't so huge
     
     $out->emptyTag('sector', 'col' => $col, 'row' => $row, 'type' => $type, 'extra' => $addl, 'item' => $item, @wattrs);
    }
  }
  $out->endTag('sectors');
  
  $out->endTag('level');
}
$out->endTag('pid_map');
$out->end();

# create Perl from XML
my $xml = XML::Simple::XMLin($xmldata, 'KeyAttr' => [], 'ForceArray' => 1);
our $map = $xml->{'level'};

my (@levelparsed);
for my $struct (@$map)
{
  push(@levelparsed, JSON->new->ascii(1)->pretty(0)->canonical(1)->encode($struct));
}

# load into database
my $db = DBObjectRW();
for my $level_idx (0..(scalar(@leveldata)-1))
{
  my $crc = String::CRC32::crc32($leveldata[$level_idx]);
  
  $db->do(<<END, $vers, $level_idx);
DELETE FROM map
 WHERE game = ?
   AND level = ?
END

  my $mapname = $map->[$level_idx]{'name'};
  my $elev = $map->[$level_idx]{'height'};
  my $id = $db->do(<<END, $crc, $vers, $level_idx, $mapname, $elev);
INSERT INTO map
       (crc, game, level, name, elevation)
VALUES (?, ?, ?, ?, ?)
END
  $db->do(<<END, $leveldata[$level_idx], $id);
UPDATE map
   SET data = ?
 WHERE id = ?
END
  $db->do(<<END, $levelparsed[$level_idx], $id);
UPDATE map
   SET perl = ?
 WHERE id = ?
END
  print STDERR "Added level $level_idx as ID $id.\n";
}


exit;
