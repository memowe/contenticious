#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Test::More tests => 132;
use File::Path 'remove_tree';
use FindBin '$Bin';
use lib "$Bin/../lib";
use Contenticious::Generator;

# slurp helper
sub slurp {
    my $fn = shift;
    open my $fh, '<:encoding(UTF-8)', $fn or die "couldn't open $fn: $!";
    return do { local $/; <$fh> };
}

# prepare file system
chdir $Bin;
my $dd = "test_dump";
ok(! -d $dd, 'dump directory gone');

# prepare web app
ok(! -e 'webapp.pl', "webapp.pl doesn't exist");
my $gen = Contenticious::Generator->new(quiet => 1);
$gen->generate_web_app;
ok(  -e 'webapp.pl', 'webapp.pl exists');
$ENV{MOJO_LOG_LEVEL} = 'warn'; # silence!
$ENV{CONTENTICIOUS_CONFIG} = "$Bin/test_config";

# hardcode dumping acshun
unshift @ARGV, 'dump';
require("$Bin/webapp.pl");

# index
ok(-f -r "$dd/index.html", 'index found');
my $index = Mojo::DOM->new(slurp("$dd/index.html"));
is($index->at('title')->text, 'Shagadelic', 'right title');
is($index->at('h1')->text, 'Shagadelic', 'right headline');
is($index->at('#top a')->attr('href'), './', 'right top link');
is($index->at('#top a')->text, 'Shagadelic', 'right top text');
my $navi = $index->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
my $subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'baz%20quux/a.html', 'right ... a url');
is($subnavi->[0]->text, 'a', 'right ... a text');
is($subnavi->[1]->attr('href'), 'baz%20quux/b%20c.html', 'right ... b c url');
is($subnavi->[1]->text, 'b c', 'right ... b c text');
my $list = $index->find('#content_list a');
is($list->size, 3, '3 content list links');
is($list->[0]->attr('href'), 'foo%20oof.html', 'right foo oof url');
is($list->[0]->text, 'Simple foo file', 'right foo title');
is($list->[1]->attr('href'), 'bar.html', 'right bar url');
is($list->[1]->text, 'bar Title', 'right bar title');
is($list->[2]->attr('href'), 'baz%20quux.html', 'right baz quux url');
is($list->[2]->text, "Title of baz quux's index",
    'right baz quux title');
like($index->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# foo
ok(-f -r "$dd/foo oof.html", 'foo oof found');
my $foo = Mojo::DOM->new(slurp("$dd/foo oof.html"));
is($foo->at('title')->text, 'Simple foo file - Shagadelic', 'right title');
is($foo->at('h1')->text, 'Hello wørld!', 'right headline');
is($foo->at('#top a')->attr('href'), './', 'right top link');
is($foo->at('#top a')->text, 'Shagadelic', 'right top text');
$navi = $foo->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'baz%20quux/a.html', 'right ... a url');
is($subnavi->[0]->text, 'a', 'right ... a text');
is($subnavi->[1]->attr('href'), 'baz%20quux/b%20c.html', 'right ... b c url');
is($subnavi->[1]->text, 'b c', 'right ... b c text');
my $active = $foo->at('body > .navi .active > a');
is($active->attr('href'), 'foo%20oof.html', 'correct active link');
like($foo->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# bar
ok(-f -r "$dd/bar.html", 'bar found');
my $bar = Mojo::DOM->new(slurp("$dd/bar.html"));
is($bar->at('title')->text, 'bar Title - Shagadelic', 'right title');
is($bar->at('h1')->text, 'bar Title', 'right headline');
is($bar->at('#top a')->attr('href'), './', 'right top link');
is($bar->at('#top a')->text, 'Shagadelic', 'right top text');
$navi = $bar->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'baz%20quux/a.html', 'right ... a url');
is($subnavi->[0]->text, 'a', 'right ... a text');
is($subnavi->[1]->attr('href'), 'baz%20quux/b%20c.html', 'right ... b c url');
is($subnavi->[1]->text, 'b c', 'right ... b c text');
$active = $bar->at('body > .navi .active > a');
is($active->attr('href'), 'bar.html', 'correct active link');
is($bar->find('#content_list li')->size, 0, 'empty listing');
like($bar->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# baz
ok(-f -r "$dd/baz quux.html", 'baz quux found');
my $baz = Mojo::DOM->new(slurp("$dd/baz quux.html"));
is($baz->at('title')->text, "Title of baz quux's index - Shagadelic",
    'right title');
is($baz->at('#top a')->attr('href'), './', 'right top link');
is($baz->at('#top a')->text, 'Shagadelic', 'right top text');
$navi = $baz->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'baz%20quux/a.html', 'right ... a url');
is($subnavi->[0]->text, 'a', 'right ... a text');
is($subnavi->[1]->attr('href'), 'baz%20quux/b%20c.html', 'right ... b c url');
is($subnavi->[1]->text, 'b c', 'right ... b c text');
$active = $baz->at('body > .navi .active > a');
is($active->attr('href'), 'baz%20quux.html', 'correct active link');
like($baz->at('#content p')->text, qr/I/, 'right content');
like($baz->at('#content p strong')->text, qr/has/, 'right content');
like($baz->at('#content p em')->text, qr/HTML/, 'right content');
like($baz->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# baz quux/a
ok(-f -r "$dd/baz quux/a.html", 'baz quux/a found');
my $baza = Mojo::DOM->new(slurp("$dd/baz quux/a.html"));
is($baza->at('title')->text, 'This is a - Shagadelic', 'right title');
is($baza->at('#top a')->attr('href'), '..', 'right top link');
is($baza->at('#top a')->text, 'Shagadelic', 'right top text');
$navi = $baza->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), '../foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), '../bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), '../baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'a.html', 'right baz quux/a url');
is($subnavi->[0]->text, 'a', 'right baz quux/a link text');
is($subnavi->[1]->attr('href'), 'b%20c.html', 'right baz quux/b c url');
is($subnavi->[1]->text, 'b c', 'right baz quux/b c link text');
$active = $baza->find('body > .navi .active > a');
is($active->size, 2, 'active second level link');
is($active->[0]->attr('href'), '../baz%20quux.html', 'correct first active');
is($active->[1]->attr('href'), 'a.html', 'correct second active');
is($baza->at('h1')->text, 'This is a', 'right content');
like($baza->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# baz/b: "deep" page
ok(-f -r "$dd/baz quux/b c.html", 'baz quux/b c found');
my $bazb = Mojo::DOM->new(slurp("$dd/baz quux/b c.html"));
is($bazb->at('title')->text, 'b c - Shagadelic', 'right title');
is($bazb->at('#top a')->attr('href'), '..', 'right top link');
is($bazb->at('#top a')->text, 'Shagadelic', 'right top text');
$navi = $bazb->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), '../foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), '../bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), '../baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'a.html', 'right baz quux/a url');
is($subnavi->[0]->text, 'a', 'right baz quux/a link text');
is($subnavi->[1]->attr('href'), 'b%20c.html', 'right baz quux/b c url');
is($subnavi->[1]->text, 'b c', 'right baz quux/b c link text');
$active = $bazb->find('body > .navi .active > a');
is($active->size, 2, 'active second level link');
is($active->[0]->attr('href'), '../baz%20quux.html', 'correct first active');
is($active->[1]->attr('href'), 'b%20c.html', 'correct second active');
is($bazb->at('#content p')->text, 'This is b c', 'right content');
like($bazb->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# cleanup
remove_tree($dd);
ok(! -d $dd, 'dump directory gone');
unlink('webapp.pl') or die "couldn't delete webapp.pl: $!";
ok(! -f 'webapp.pl', 'webapp.pl deleted');

__END__
