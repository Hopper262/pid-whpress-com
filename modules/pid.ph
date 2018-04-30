use strict;

# Bootstrapping die message, in case requires fail
sub early_die
{
  print <<END;
Content-type: text/plain

Died: $_[0]

END
#   for my $var (sort keys %ENV)
#   {
#     print "$var = $ENV{$var}\n";
#   }
}
# this doesn't work on some machines, due to Net::SSLeay brokenness
# $SIG{__DIE__} = \&early_die;


# figure out root
our $ROOT = $ENV{'USEROOT'} || $0 || '';
$ROOT =~ s/^$ENV{'DOCUMENT_ROOT'}//;
$ROOT =~ s|/[^/]+$||;
{
  my $foo = __FILE__;
  while ($foo =~ /^\.\./) {
    $foo =~ s|^\.\./||;
    $ROOT =~ s|/[^/]+$||;
  }
}
our $FILEROOT = $ENV{'DOCUMENT_ROOT'} . $ROOT;

# constant strings
our $STYLE = $ROOT . '/style';

#scripts
our $HOME_URL = "$ROOT/psi/";
our $UPLOAD_URL = "$ROOT/upload";
our $INSPECT_URL = "$ROOT/inspect";
our $DOWNLOAD_URL = "$ROOT/download";
our $ARCHIVE_URL = "$ROOT/archive";
our $MAP_URL = "$ROOT/map";

# ph/subs files
require "$FILEROOT/modules/db.ph";
require "$FILEROOT/modules/db.subs";
require "$FILEROOT/modules/pid.subs";
require "$FILEROOT/modules/page.subs";

require "$FILEROOT/full11/info.ph" if -s "$FILEROOT/full11/info.ph";
require "$FILEROOT/full20/info.ph" if -s "$FILEROOT/full20/info.ph";
require "$FILEROOT/demoA1/info.ph" if -s "$FILEROOT/demoA1/info.ph";
require "$FILEROOT/demo20/info.ph" if -s "$FILEROOT/demo20/info.ph";

# end file
1;
