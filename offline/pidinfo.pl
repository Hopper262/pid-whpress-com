#!/usr/bin/env perl
use strict;
use warnings 'FATAL' => 'all';
use XML::Simple ();
use FindBin ();
use Carp ();
use Data::Dumper ();

$ENV{'USEROOT'} = $FindBin::Bin . '/..';
require '../modules/pid.ph';
$SIG{__DIE__} = \&Carp::confess;

our $ro = DBObject();

our $leveltype_override = ''; # use for building demos

my $usage = "Usage: $0 [full11|full20|demo20|demoA1] < <strings.xml>\n";

our $version = $ARGV[0] || 'full20';
die $usage unless $version =~ /^(full11|full20|demo20|demoA1)$/;

my $xml = XML::Simple::XMLin('-', 'KeyAttr' => [], 'ForceArray' => 1);
die $usage unless $xml;
our $stringsets = $xml->{'stringset'};
die $usage unless $stringsets;

# get dpins
our $dpin = [];
{
  my $slotid = $ro->select(<<END, $version);
SELECT slot_id
  FROM defaultslot
 WHERE game = ?
END
  while (1)
  {
    my $dat = LoadLState($slotid, scalar @$dpin);
    last unless $dat;
    push(@$dpin, $dat);
  }
}

# get maps
our $map = [];
while (1)
{
  my $dat = LoadMap($version, scalar @$map);
  last unless $dat;
  push(@$map, $dat);
}


our @leveltypes;
if ($version eq 'demoA1')
{
  push(@leveltypes, ('Demo A1') x 3);
}
elsif ($version eq 'demo20')
{
  push(@leveltypes, ('Demo 2.0') x 3);
}
else
{
  push(@leveltypes, ('The Pyramid') x 7);
  push(@leveltypes, ('The Catacombs') x 9);
  push(@leveltypes, ('The Pit') x 4);
  push(@leveltypes, ('The Hole') x 5);
}

our @levelinfo;
for my $idx (0..(scalar(@$map) - 1))
{
  my $mp = $map->[$idx];
  die "No map at index $idx" unless $mp;
  
  my $name = $mp ? $mp->{'name'} : '(unknown)';
  if ($version eq 'demo20')
  {
    $name = String(2021, $idx, $name);
  }
  elsif ($version eq 'full20')
  {
    $name = String(2018, $idx, $name);
  }
    
  push(@levelinfo, {
    'name' => $name,
    'elevation' => $mp->{'height'},
    'section' => $leveltypes[$idx],
    });
}

our @levelsections;
if ($version eq 'demoA1' || $version eq 'demo20')
{
  push(@levelsections, [ $leveltypes[0], [ 0, 1, 2 ] ]);
}
else
{
  push(@levelsections, [ $leveltypes[0], [ 0, 1, 2, 3, 4, 5, 6 ] ]);
  push(@levelsections, [ $leveltypes[7], [ 7, 8, 9, 14, 10, 11, 12, 13, 15 ] ]);
  push(@levelsections, [ $leveltypes[16], [ 16, 17, 18, 19 ] ]);
  push(@levelsections, [ $leveltypes[20], [ 20, 21, 22, 23, 24 ] ]);
}

our @monsternames = (
  'Nightmare', 'Headless', 'Phantasm', 'Ghoul', 'Zombie',
  'Ooze', 'Invisible Wraith', 'Shocking Sphere', 'Pain', 'Malice',
  'Skitter', 'Sentinel', 'Ghast', 'Green Ooze', 'Stalker',
  'Greater Nightmare', 'Venemous Skitter' );
our @monstercolors = (
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0,
  0, 0, 1, 1, 2,
  1, 1 );

our @monsterinfo;
for my $idx (0..(scalar(@monsternames) - 1))
{
  my $name = String(2001, $idx, $monsternames[$idx]);
  my $death = String(1003, $idx);
  my $ctab = $monstercolors[$idx];
  
  if ($version eq 'full11' || $version eq 'full20')
  {
    if ($idx == 14)
    {
      $name = 'Deceit';
      $death = '';
      $ctab = 0;
    }
  }
  
  # find sprite in dpin
  my $image = '';
  OUTER:
  for my $level (@$dpin)
  {
    for my $mon (@{ $level->{'monsters'}[0]{'monster'} })
    {
      if ($mon->{'type'} == $idx)
      {
        my $item = IndexOf($level->{'items'}[0]{'item'}, $mon->{'item'});
        next unless $item->{'asleep'};
        
        my $coll = $item->{'collection'};
        my $frame = $item->{'frame'};
        if ($idx == 4 || $idx == 12) { $frame = 8; }
        
        $image = sprintf('images/%d/%d/frame%03d.png', $coll, $ctab, $frame);
        last OUTER;
      }
    }
  }
  if ($image eq '' && $idx == 7)
  {
    $image = sprintf('images/%d/%d/frame%03d.png', 134, $ctab, 0);
  }
  
  push(@monsterinfo, {
    'name' => $name,
    'death' => $death,
    'image' => $image,
    });
}
if ($version eq 'full20' || $version eq 'full11')
{
  for my $i (8, 9, 14)
  {
    $monsterinfo[$i]{'skip_carnage'} = 1;
  }
}

our @itemnames = (
  "Map", "Digital Watch", "Flashlight", "Infra-Red Goggles", "Gas Mask",
  "Unknown 5", "Canvas Bag", "Unknown 7", "Cedar Box", "Red Velvet Bag",
  "Lead Box", "Unknown 11", "Ornate Glass Vial", "Unknown 13", "Red Cloak",
  "Unknown 15", "Nuclear Device", "Radio Beacon", "Clear Blue Potion", "Bubbling Red Potion",
  "Thick Brown Potion", "Pale Violet Potion", "Copy of Mein Kampf", "Nazi Propaganda", "Easter Egg",
  "Broken M-16", "Melted AK-47", "Rusted MP-41", "Rusted Walther P4", "Ruby Ring",
  "Amethyst Ring", "Diamond Necklace", "Alien Gemstone", "Alien Pipes", "Silver Key",
  "Silver Bowl", "Gold Key", "Gold Ingot", "Sapphire", "Unknown 39",
  "Emerald", "Large Pearl", "Unknown 42", "Unknown 43", "Unknown 44",
  "Survival Knife", "Walther P4 Pistol", "Colt .45 Pistol", "MP-41 Submachine Gun", "AK-47 Assault Rifle",
  "M-79 Grenade Launcher", "Walther P4 Magazine", "MP-41 Magazine", "AK-47 Magazine", "AK-47 HE Magazine",
  "AK-47 SABOT Magazine", "M-16 Magazine", "Colt .45 Magazine", "40mm HE Cartridge", "40mm Fragmentation Cartridge",
  "40mm Projectile Cartridge", "Silver Medal", "Note", "Bungie Propaganda", "Yellow Crystal",
  "Blue Crystal", "Orange Crystal", "Unknown 67", "Violet Crystal", "Green Crystal",
  "Black Crystal",
  );
our @itemcats = ('standard') x scalar(@itemnames);
for my $i (6..11, 25..28, 46..50)
{
  $itemcats[$i] = 'container';
}
for my $i (51..57)
{
  $itemcats[$i] = 'ammo';
}
for my $i (58..60)
{
  $itemcats[$i] = 'ammo2';
}
for my $i (64..70)
{
  $itemcats[$i] = 'crystal';
}
our @itemactive = (String(2008, 4, ' (worn)')) x scalar(@itemnames);
$itemactive[1] = String(2008, 5, ' (on wrist)');
$itemactive[2] = String(2008, 1, ' (on)');
for my $i (45..50)
{
  $itemactive[$i] = String(2008, 2, ' (in hand)');
}
for my $i (64..70)
{
  $itemactive[$i] = String(2008, 3, ' (ready)');
}

our @iteminfo;
for my $idx (0..(scalar(@itemnames) - 1))
{
  my $name = String(2000, $idx, $itemnames[$idx]);
  my $desc = String(1001, $idx);
  my $cat = $itemcats[$idx];
  my $active = $itemactive[$idx];
  
  # find sprite in dpin
  my $image = '';
  OUTER:
  for my $level (@$dpin)
  {
    for my $assign (@{ $level->{'assigns'}[0]{'assign'} })
    {
      my $pickup = IndexOf($level->{'pickups'}[0]{'pickup'}, $assign->{'pickup'});
      next unless $pickup;
      if ($pickup->{'type'} == $idx)
      {
        my $item = IndexOf($level->{'items'}[0]{'item'}, $assign->{'item'});
        next unless $item;
        
        my $coll = $item->{'collection'};
        my $frame = $item->{'frame'};
        $image = sprintf('images/%d/%d/frame%03d.png', $coll, 0, $frame);
        last OUTER;
      }
    }
  }
  
  my $crystal_inc = 0;
  my $crystal_max = 300;
  if    ($idx == 65) { $crystal_inc =  2; $crystal_max = 180; }
  elsif ($idx == 66) { $crystal_inc =  7; $crystal_max = 410; }
  elsif ($idx == 68) { $crystal_inc = 15; $crystal_max = 660; }
  elsif ($idx == 69) { $crystal_inc = 15; $crystal_max = 810; }
  elsif ($idx == 70) { $crystal_inc =  1; $crystal_max =  20; }
  
  push(@iteminfo, {
    'name' => $name,
    'desc' => $desc,
    'image' => $image,
    'category' => $cat,
    'active' => $active,
    'increment' => $crystal_inc,
    'maximum' => $crystal_max,
    });
}

our %weaponinfo = (
  'train_levels' => [
      '',
      String(2007, 0, 'Beginner'),
      String(2007, 1, 'Novice'),
      String(2007, 2, 'Expert'),
      ],
  'train_weapons' => [
      String(2006, 0, 'Melee Combat'),
      String(2006, 1, 'Colt .45 Pistol'),
      String(2006, 2, 'Walther P4 Pistol'),
      String(2006, 3, 'MP-41 Submachine Gun'),
      String(2006, 4, 'M-16 Rifle'),
      String(2006, 5, 'AK-47 Assault Rifle'),
      String(2006, 6, 'M-79 Grenade Launcher'),
      ],
  'used_weapons' => [
      $iteminfo[45]{'name'},
      $iteminfo[46]{'name'},
      $iteminfo[48]{'name'},
      $iteminfo[49]{'name'},
      $iteminfo[50]{'name'},
      ],
  );

our @corpsenames = (
 "Anonymous German", "Anonymous German", "Gunther", "Anonymous German", "Hans",
 "Anonymous German", "Claude", "Joachim", "Behrens", "Anonymous German",
 "Anonymous German", "Walter", "Anonymous German", "Anonymous German", "Anonymous German",
 "Friedrich", "Muller", "Thomas", "John", "Ed",
 "Darren", "Sean", "Jason", "Steven", "Greg",
 "Pedro", "Juan", "Javier", "Carlos",
  );
our @corpseinfo = ();
for my $idx (0..(scalar(@corpsenames) - 1))
{
  # find sprite
  my $image = '';
  my ($levnum, $x, $y) = (-1, 0, 0);
  
  my $mapextra = $idx;
  $mapextra = 200 if $idx == 28;  # Carlos
  # find instance in map
  OUTER:
  for my $mlev (@$map)
  {
    for my $sec (@{ $mlev->{'sectors'}[0]{'sector'} })
    {
      next unless $sec->{'type'} == 6;
      next unless $sec->{'extra'} == $mapextra;
      
      $levnum = $mlev->{'index'};
      $x = $sec->{'col'};
      $y = $sec->{'row'};
      last OUTER;
    }
  }
  if ($levnum >= 0)
  {
    my $dlev = $dpin->[$levnum];
    for my $item (@{ $dlev->{'items'}[0]{'item'} })
    {
      my $coll = $item->{'collection'};
      next unless ($coll == 156 || $coll == 160 || $coll == 161 || $coll == 165);
      next unless int($item->{'x'}) == $x;
      next unless int($item->{'y'}) == $y;
      
      $image = sprintf('images/%d/%d/frame%03d.png', $coll, 0, $item->{'frame'});
    }
  }
  push(@corpseinfo, {
    'name' => $corpsenames[$idx],
    'image' => $image,
    });
}


our @sectornames = ( 'Void', 'Normal', 'Door', 'Ladder', 'Door trigger',
                     'False wall', 'Corpse', 'Pillar', 'Unknown', 'Save rune' );
our @laddernames = ( 'Ladder up', 'Ladder down', 'Teleporter', 'Teleporter' );
our @dtriggernames;
{
  $dtriggernames[6] = "Unknown 6 trigger";
  $dtriggernames[7] = "Left chain";
  $dtriggernames[8] = "Right chain";
  
  $dtriggernames[12] = "Circle of green arrows (door opener)";
  $dtriggernames[13] = "Circle of yellow arrows (door opener)";
  $dtriggernames[14] = "Single-use (type 14) door closer";
  $dtriggernames[15] = "Corpse info message";
  $dtriggernames[16] = "Item-found info message";
  $dtriggernames[17] = "Single-use (flag 17) door closer";
  $dtriggernames[18] = "Ladder-guarding lizard trigger";
  $dtriggernames[19] = "Bomb-guarding lizard trigger";
  $dtriggernames[20] = "Crystal-guarding lizard trigger";
  $dtriggernames[21] = "Crossing-guard lizard trigger";
  $dtriggernames[22] = "Exploding pod hiding nuclear device";
  $dtriggernames[23] = "Suffocation room trigger";
  $dtriggernames[24] = "End-game trigger";
  
  $dtriggernames[128] = "Door closer";
  $dtriggernames[129] = "Door opener";
  $dtriggernames[130] = "Alien Pipes-operated door opener";
  $dtriggernames[131] = "Silver key-operated door opener";
  $dtriggernames[132] = "Gold key-operated door opener";
  
  $dtriggernames[134] = "Unknown 134 trigger";
  $dtriggernames[135] = "Unknown 135 trigger";
  $dtriggernames[136] = "West-facing Sentinel barrier";
  $dtriggernames[137] = "South-facing Sentinel barrier";
  $dtriggernames[138] = "East-facing Sentinel barrier";
  $dtriggernames[139] = "North-facing Sentinel barrier";
  $dtriggernames[140] = "Exploding pod";
  $dtriggernames[141] = "Alien Gemstone-operated door opener";
}

our @sectorinfo;
for my $i (0..9)
{
  $sectorinfo[$i] = { 'name' => $sectornames[$i] };
  if ($i == 3)
  {
    $sectorinfo[$i]{'sub'} = [];
    for my $j (0..3)
    {
      $sectorinfo[$i]{'sub'}[$j] = { 'name' => $laddernames[$j] };
    }
  }
  elsif ($i == 4)
  {
    $sectorinfo[$i]{'sub'} = [];
    for my $j (0..255)
    {
      $sectorinfo[$i]{'sub'}[$j] = { 'name' => ($dtriggernames[$j] || "Unknown $j trigger") };
    }
  }
}

our @directions = qw(west south east north);

our %plurals = (
    "Headless" => "Headless",
    "Infra-Red Goggles" => "Pair Infra-Red Goggles",
    "Cedar Box" => "Cedar Boxes",
    "Lead Box" => "Lead Boxes",
    "Copy of Mein Kampf" => "Copies of Mein Kampf",
    "Nazi Propaganda" => "Copies of Nazi Propaganda",
    "Bungie Propaganda" => "Copies of Bungie Propaganda",
    "Alien Pipes" => "Alien Pipes",
    "Survival Knife" => "Survival Knives",
    "Circle of green arrows (door opener)" => "Circles of green arrows (door openers)",
    "Circle of yellow arrows (door opener)" => "Circles of yellow arrows (door openers)",
  );

my %all = (
  'levelinfo' => \@levelinfo,
  'levelsections' => \@levelsections,
  'monsterinfo' => \@monsterinfo,
  'iteminfo' => \@iteminfo,
  'weaponinfo' => \%weaponinfo,
  'corpseinfo' => \@corpseinfo,
  'sectorinfo' => \@sectorinfo,
  'directions' => \@directions,
  'plurals' => \%plurals,
  );

my $d = Data::Dumper->new([ \%all ], [ 'INFO' ]);
$d->Indent(1)->Sortkeys(1);
my $infodump = $d->Dump();
$infodump =~ s/^\$INFO//s;

print 'our %INFO;' . "\n" . q($INFO{') . $version . q('}) .
      $infodump . "\n1;\n";
exit;

sub IndexOf
{
  my ($ref, $idx) = @_;
  
  for my $r (@$ref)
  {
    if ($r->{'index'} == $idx)
    {
      return $r;
    }
  }
  return undef;
}

sub String
{
  my ($id, $index, $fallback) = @_;
  $fallback = '' unless defined $fallback;
  
  my $set = IndexOf($stringsets, $id);
  return $fallback unless $set;
  my $stri = IndexOf($set->{'string'}, $index);
  return $fallback unless $stri;
  my $str = $stri->{'content'};
  return $fallback unless $str;
  
  return $str;
}
