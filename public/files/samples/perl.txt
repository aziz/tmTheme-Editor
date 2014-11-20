use strict;

#
# This script also prints the contents of all the listed files, but
# it first scans through the list to check that each file exists and
# is readable.  It will stop if there are any errors.
#

my $bad = 0;
foreach my $fn (@ARGV) {
    if(! -r $fn) {
        # File cannot be read.  See if it exists or not for a better
        # error message.
        if(-e $fn) {
            print STDERR "You do not have permission to read $fn.\n";
        } else {
            print STDERR "File $fn does not exist.\n";
        }

        # One way or the other, it's bad.
        $bad = 1;
    }
}

# If there was a problem, bail out.
if($bad) { exit 2; }

# Copy all the files.
while(my $fn = shift @ARGV) {

    # Open the file.
    if(!open(INFILE, $fn)) {
        # We know the file is readable, but sometimes something else goes
        # wrong.  It's safer to check.
        print STDERR "Cannot open $fn: $!\n";
        next;
    }

    # Copy it.
    while(my $l = <INFILE>) {
        print $l;
    }

    close INFILE;
}
