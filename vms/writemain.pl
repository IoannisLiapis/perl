#!./miniperl
#
# Create perlmain.c from miniperlmain.c, adding code to boot the
# extensions listed on the command line.  In addition, create a
# linker options file which causes the bootstrap routines for
# these extension to be universal symbols in PerlShr.Exe.
#
# Last modified 29-Nov-1994 by Charles Bailey  bailey@genetics.upenn.edu
#

if (-f 'miniperlmain.c') { $dir = ''; }
elsif (-f '../miniperlmain.c') { $dir = '../'; }
else { die "$0: Can't find miniperlmain.c\n"; }

open (IN,"${dir}miniperlmain.c")
  || die "$0: Can't open ${dir}miniperlmain.c: $!\n";
open (OUT,">${dir}perlmain.c")
  || die "$0: Can't open ${dir}perlmain.c: $!\n";

while (<IN>) {
  s/INTERN\.h/EXTERN\.h/;
  print OUT;
  last if /Do not delete this line--writemain depends on it/;
}
$ok = !eof(IN);
close IN;

if (!$ok) {
  close OUT;
  unlink "${dir}perlmain.c";
  die "$0: Can't find marker line in ${dir}miniperlmain.c - aborting\n";
}


if (@ARGV) {
  # Allow for multiple names in one quoted group
  @exts = split(/\s+/, join(' ',@ARGV));
}

if (@exts) {
  print OUT "    char *file = __FILE__;\n";
  foreach $ext (@exts) {
    my($subname) = $ext;
    $subname =~ s/::/__/g;
    print OUT "extern void	boot_${subname} _((CV* cv));\n"
  }
  foreach $ext (@exts) {
    my($subname) = $ext;
    $subname =~ s/::/__/g;
    print "Adding $ext . . .\n";
    if ($ext eq 'DynaLoader') {
      # Must NOT install 'DynaLoader::boot_DynaLoader' as 'bootstrap'!
      # boot_DynaLoader is called directly in DynaLoader.pm
      print OUT "    newXS(\"${ext}::boot_${ext}\", boot_${subname}, file);\n"
    }
    else {
      print OUT "    newXS(\"${ext}::bootstrap\", boot_${subname}, file);\n"
    }
  }
}

print OUT "}\n";
close OUT;
