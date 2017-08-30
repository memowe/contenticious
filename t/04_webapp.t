#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 146;
use Test::Mojo;
use File::Copy;
use File::Path 'remove_tree';
use FindBin '$Bin';
use lib "$Bin/../lib";
use Contenticious::Generator;
use utf8;
use Mojo::Log;

my $log = Mojo::Log->new;

# prepare web app
$log->debug("Bin: $Bin\n");
chdir $Bin;
ok(! -d 'public', "public directory doesn't exist");
my $gen = Contenticious::Generator->new;
$gen->generate_file('public/js/jquery.js');
ok(  -e 'public/js/jquery.js', 'jquery exists');
$ENV{CONTENTICIOUS_CONFIG} = "$Bin/test_config";

# build web app tester
$ENV{MOJO_HOME} = $Bin;
my $t = Test::Mojo->new('Contenticious');

$t->app->log->level('debug');

# home page: listing of foo, bar, baz
$t->get_ok('/')->status_is(200)
  ->text_is(title => 'Shagadelic')
  ->text_is(h1 => 'Shagadelic');
my $top_link = $t->tx->res->dom->at('#top a');
is $top_link->attr('href') => './', 'right top link';
is $top_link->text => 'Shagadelic', 'right top link text';
my $navi = $t->tx->res->dom->find('body > .navi > li > a');
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
my $list = $t->tx->res->dom->find('#content_list a');
is($list->size, 3, '3 content list links');
is($list->[0]->attr('href'), 'foo%20oof.html', 'right foo oof url');
is($list->[0]->text, 'Simple foo file', 'right foo title');
is($list->[1]->attr('href'), 'bar.html', 'right bar url');
is($list->[1]->text, 'bar Title', 'right bar title');
is($list->[2]->attr('href'), 'baz%20quux.html', 'right baz quux url');
is($list->[2]->text, "Title of baz quux's index",
    'right baz title');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# foo: single page with ø
$t->get_ok('/foo%20oof')->status_is(200)
  ->text_is(title => 'Simple foo file - Shagadelic')
  ->text_is(h1 => 'Hello wørld!');
$top_link = $t->tx->res->dom->at('#top a');
is $top_link->attr('href') => './', 'right top link';
is $top_link->text => 'Shagadelic', 'right top link text';
$navi = $t->tx->res->dom->find('body > .navi > li > a');
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
my $active = $t->tx->res->dom->at('body > .navi .active > a');
is $active->attr('href') => 'foo%20oof.html', 'correct active link';
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# bar: empty listing
$t->get_ok('/bar')->status_is(200)
  ->text_is(title => 'bar Title - Shagadelic')
  ->text_is(h1 => 'bar Title');
$top_link = $t->tx->res->dom->at('#top a');
is $top_link->attr('href') => './', 'right top link';
is $top_link->text => 'Shagadelic', 'right top link text';
$navi = $t->tx->res->dom->find('body > .navi > li > a');
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
$active = $t->tx->res->dom->at('body > .navi .active > a');
is $active->attr('href') => 'bar.html', 'correct active link';
is($t->tx->res->dom->find('#content_list li')->size, 0, 'empty listing');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# baz: directory with index page
$t->get_ok('/baz%20quux')->status_is(200)
  ->text_is(title => "Title of baz quux's index - Shagadelic")
  ->text_like('#content p'          => qr/I/)
  ->text_like('#content p strong'   => qr/has/)
  ->text_like('#content p em'       => qr/HTML/);
$top_link = $t->tx->res->dom->at('#top a');
is $top_link->attr('href') => './', 'right top link';
is $top_link->text => 'Shagadelic', 'right top link text';
$navi = $t->tx->res->dom->find('body > .navi > li > a');
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
$active = $t->tx->res->dom->at('body > .navi .active > a');
is $active->attr('href') => 'baz%20quux.html', 'correct active link';
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# baz/a: "deep" page
$t->get_ok('/baz%20quux/a')->status_is(200)
  ->text_is(title => 'This is a - Shagadelic')
  ->text_is(h1 => 'This is a');
$top_link = $t->tx->res->dom->at('#top a');
is $top_link->attr('href') => '..', 'right top link';
is $top_link->text => 'Shagadelic', 'right top link text';
$navi = $t->tx->res->dom->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), '../foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), '../bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), '../baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'a.html', 'right ... a url');
is($subnavi->[0]->text, 'a', 'right ... a text');
is($subnavi->[1]->attr('href'), 'b%20c.html', 'right ... b c url');
is($subnavi->[1]->text, 'b c', 'right ... b c text');
$active = $t->tx->res->dom->find('body > .navi .active > a');
is $active->size, 2, 'active second level link';
is $active->[0]->attr('href') => '../baz%20quux.html', 'correct first active';
is $active->[1]->attr('href') => 'a.html', 'correct second active';
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# baz/b: "deep" page
$t->get_ok('/baz%20quux/b%20c')->status_is(200)
  ->text_is(title => 'b c - Shagadelic')
  ->text_is('#content p' => 'This is b c');
$top_link = $t->tx->res->dom->at('#top a');
is $top_link->attr('href') => '..', 'right top link';
is $top_link->text => 'Shagadelic', 'right top link text';
$navi = $t->tx->res->dom->find('body > .navi > li > a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), '../foo%20oof.html', 'right foo oof url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), '../bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), '../baz%20quux.html', 'right baz quux url');
is($navi->[2]->text, 'Baaaz Quuux', 'right baz quux link text');
$subnavi = $navi->[2]->parent->find('.navi > li > a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'a.html', 'right ... a url');
is($subnavi->[0]->text, 'a', 'right ... a text');
is($subnavi->[1]->attr('href'), 'b%20c.html', 'right ... b c url');
is($subnavi->[1]->text, 'b c', 'right ... b c text');
$active = $t->tx->res->dom->find('body > .navi .active > a');
is $active->size, 2, 'active second level link';
is $active->[0]->attr('href') => '../baz%20quux.html', 'correct first active';
is $active->[1]->attr('href') => 'b%20c.html', 'correct second active';
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# 404
$t->get_ok('/foomatic')->status_is(404)
  ->text_is(title => 'File not found! - Shagadelic')
  ->text_is(h1 => 'File not found!')
  ->text_like('#content p' => qr/I'm sorry/)
  ->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# perldoc
$t->get_ok('/perldoc/Contenticious')->status_is(200)
  ->text_is(title => 'Contenticious - build web sites from markdown files')
  ->text_is('li a[href="#NAME"]' => 'NAME');

# done
remove_tree('public');
ok(! -d 'public', 'public directory deleted');

__END__
