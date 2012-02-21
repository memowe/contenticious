#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 18;
use File::Path 'remove_tree';
use FindBin '$Bin';
use lib "$Bin/../lib";
use Contenticious;
use Mojolicious;

# call script helper (returns STDOUT output)
sub call_script {
    my $command = shift // '';
    die "suspicious command: '$command'" unless $command =~ /^\w*$/;
    open my $script, '-|', "$Bin/../contenticious $command"
        or die "couldn't call contenticious script with command '$command': $!";
    return do { local $/; <$script> };
}

# slurp helper
sub slurp {
    my $fn = shift;
    open my $fh, '<:encoding(UTF-8)', $fn or die "couldn't open $fn: $!";
    return do { local $/; <$fh> };
}

# help message
my $help = call_script('help');
like($help, qr/^USAGE: contenticious COMMAND/, 'right help message');
is(call_script(), $help, 'right help message without any command');

# version
my $cv = $Contenticious::VERSION;
my $mv = $Mojolicious::VERSION;
my $pv = $^V;
like(
    call_script('version'),
    qr/^This is Contenticious $cv using Mojolicious $mv on perl $pv$/,
    'right version',
);

# boilerplate
my $init_dir = "$Bin/test_init";
ok(! -d $init_dir, "init directory doesn't exist");
mkdir $init_dir or die "couldn't create directory '$init_dir': $!";
chdir $init_dir;
call_script('init');
ok(-f "$init_dir/config", 'config file exists');
like(slurp("$init_dir/config"), qr/pages_dir *=> app->home/, 'right config');
ok(-f "$init_dir/webapp.pl", 'web app exists');
ok(-x "$init_dir/webapp.pl", 'web app is executable');
like(slurp("$init_dir/webapp.pl"), qr/use Contenticious;/, 'right web app');
ok(-f "$init_dir/pages/index.md", 'pages/index.md exists');
like(slurp("$init_dir/pages/index.md"), qr/Title: Welcome/, 'right index page');
ok(-f "$init_dir/pages/01_Perldoc.md", 'perldoc page exists');
like(
    slurp("$init_dir/pages/01_Perldoc.md"),
    qr/perldocs\n=============/,
    'right perldoc page',
);
ok(-f "$init_dir/pages/02_About.md", 'About page exists');
like(
    slurp("$init_dir/pages/02_About.md"),
    qr/Copyright \(c\) Mirko Westermeier, <mail\@memowe.de>/,
    'right About page',
);
ok(-f "$init_dir/public/styles.css", 'public/styles.css exists');
like(slurp("$init_dir/public/styles.css"), qr/html, body {/, 'right css');

# cleanup
chdir $Bin or die "W00T! $!";
remove_tree($init_dir);
ok(! -d $init_dir, 'init directory deleted');

__END__
