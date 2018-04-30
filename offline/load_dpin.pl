#!/usr/bin/env perl
use strict;
use warnings 'FATAL' => 'all';
use XML::Writer ();
use XML::Simple ();
use Encode ();
use FindBin ();
use String::CRC32 ();
use Carp ();

$ENV{'USEROOT'} = $FindBin::Bin . '/..';
require '../modules/pid.ph';
$SIG{__DIE__} = \&Carp::confess;

require '../modules/parse.subs';


my ($vers, $dpinfile) = @ARGV;
die "Usage: $0 <version> < <dpin_128.rsrc>\n"
  unless ($vers =~ /^(full11|full20|demoA1|demo20)$/);
my $a1demo = ($vers eq 'demoA1');

# read dpin
my ($pstate, @lstates);
binmode STDIN;
read(STDIN, $pstate, $a1demo ? 1716 : 2876);
while (!eof(STDIN))
{
  my $data;
  my $dsize = $a1demo ? 7512 : 9112;
  last unless read(STDIN, $data, $dsize) == $dsize;
  push(@lstates, $data);
}

my $player_id = StorePState($pstate, $vers);
my (@level_ids);
for (my $level_idx = 0; $level_idx < scalar(@lstates); $level_idx++)
{
  my $level_id = StoreLState($lstates[$level_idx], $vers, $level_idx);
  print STDERR "Stored state for level $level_idx as ID $level_id.\n";
  push(@level_ids, $level_id);
}

my %names = (
  'full11' => 'Pathways 1.1 New Game',
  'full20' => 'Pathways 2.0 New Game',
  'demoA1' => 'Demo A1 New Game',
  'demo20' => 'Demo 2.0 New Game',
  );
my $name = $names{$vers};
my $author = 'Bungie';

my $id = StoreSlot($name, $author, $vers, $player_id, @level_ids);

my $rw = DBObjectRW();
$rw->do(<<END, $vers, $id);
UPDATE slot
   SET display_id = ?
 WHERE id = ?
END
$rw->do(<<END, $vers, $id);
INSERT INTO defaultslot
       (game, slot_id)
VALUES (?, ?)
END

print STDERR "Loaded default game for $vers as ID $id.\n";

exit 0;
