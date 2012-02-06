#!/usr/bin/env perl
use Mojo::Base -strict;

# use local lib (if Contenticious isn't installed)
use FindBin '$Bin'; use lib "$Bin/../lib";
use Contenticious;
use Contenticious::Commands;
use Mojolicious::Commands;
use File::Basename 'dirname';

# use Contenticious
$ENV{MOJO_HOME} = dirname(__FILE__);
my $app = Contenticious->new;

# Contenticious dump command
if (defined $ARGV[0] and $command eq 'dump') {
    Contenticious::Commands->new(app => $app)->dump;
}

# use Contenticious as mojo app
else {
    $ENV{MOJO_HOME} = dirname(__FILE__);
    $ENV{MOJO_APP}  = $app;
    Mojolicious::Commands->start;
}
