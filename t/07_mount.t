#!/usr/bin/env perl

use Test::More skip_all => 'the mount test doesn\'t work at the moment. sorry!';
use Test::Mojo;
use Mojolicious::Lite;
use File::Path 'remove_tree';
use FindBin '$Bin';
use lib "$Bin/../lib";
use Contenticious::Generator;

# prepare test contenticious app
chdir $Bin;
ok(! -e 'webapp.pl', "webapp.pl doesn't exist");
ok(! -e 'public', "public directory doesn't exist");
my $gen = Contenticious::Generator->new(quiet => 1);
$gen->generate_web_app;
$gen->generate_public_directory;
ok(  -e 'webapp.pl', 'webapp.pl generated');
ok(  -e 'public/styles.css', 'stylesheet exists');
$ENV{CONTENTICIOUS_CONFIG} = "$Bin/test_config";

# web app

plugin Mount => {'/pages' => "$Bin/webapp.pl"};

get '/:thing', [thing => qr/foo+/] => sub {
    my $self = shift;
    $self->render_text(uc $self->param('thing'));
};

# test web app
my $t = Test::Mojo->new;

$t->get_ok('/fooo')->status_is(200)
  ->content_is('FOOO');
$t->get_ok('/pages')->status_is(200)
  ->text_is(title => 'Shagadelic')
  ->text_like('#copyright' => qr/Zaphod Beeblebrox/);
is(
    $t->tx->res->dom->at('#content_list li:nth-child(3) a')->attr('href'),
    'pages/baz.html',
    'right 3rd link',
);
$t->get_ok('/pages/baz/a.html')->status_is(200)
  ->text_is(title => "This is a - Shagadelic")
  ->text_is(h1 => 'This is a');
is($t->tx->res->dom->at('link')->attr('href'), '../../styles.css', 'css link');
is(
    $t->tx->res->dom->at('#top #name a')->attr('href'),
    '..',
    'right home link',
);

# cleanup
unlink('webapp.pl') or die "couldn't delete webapp.pl: $!";
ok(! -e 'webapp.pl', 'webapp.pl deleted');
remove_tree('public');
ok(! -e 'public', 'public directory deleted');

__END__
