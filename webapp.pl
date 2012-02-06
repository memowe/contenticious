#!/usr/bin/env perl
use Mojo::Base -strict;

use Mojolicious::Commands;
use File::Basename 'dirname';
use File::Spec;

# use local lib (if Contenticious isn't installed)
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';
use Contenticious::Commands;

# make sure Contenticious is installed
eval { use Contenticious };
die "Whoops: Contenticious not accessible!\n" if $@;

# use Contenticious
$ENV{MOJO_HOME} = dirname(__FILE__);
my $app = Contenticious->new;

# contenticious commands
if (defined $ARGV[0] and $ARGV[0] ~~ [qw( dump init )]) {

    # init
    my $commands = Contenticious::Commands->new(app => $app);

    # execute
    my $command = shift @ARGV;
    $commands->$command;
}

# Mojolicious command system
else {
    $ENV{MOJO_APP} = $app;
    Mojolicious::Commands->start;
}
