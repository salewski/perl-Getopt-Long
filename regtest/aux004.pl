#!/usr/bin/perl -w

use Getopt::Long 2.3203 qw(:config help);

eval { require Pod::Usage };
warn("Skipped: No Pod::Usage\n"), exit 1 if $@;

if ( pipe_from_fork('FH') ) {
    # parent
    my $res = <FH>;
    die("res1 = $res, should be Usage:\n")
      unless $res eq "Usage:\n";
    $res = <FH>;
    die("res2 = $res, should be This is a test message.\n")
      unless $res eq "    This is a test message.\n";
    $res = <FH>;
    die("res3 = $res, should be \n")
      unless $res eq "\n";
}
else {
    # child
    @ARGV = qw(--help);
    GetOptions("foo");
}

=head1 SYNOPSIS

This is a test message.

=cut

#### SUBs

# simulate open(FH, "-|") ## from "perldoc perlfork"
sub pipe_from_fork ## ($FH_NAME): $CHILD_PID
{
    use open IO => ':crlf';
    my $parent = shift;
    pipe $parent, my $child or die;
    my $pid = fork();
    die "fork() failed: $!" unless defined $pid;
    if ($pid) {
        close $child;
    }
    else {
        close $parent;
        open(STDOUT, ">&=" . fileno($child)) or die;
    }
    $pid;
}
