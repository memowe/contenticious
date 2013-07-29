#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 132;
use Test::Mojo;
use File::Path 'remove_tree';
use FindBin '$Bin';
use lib "$Bin/../lib";
use Contenticious::Generator;
use utf8;

# prepare web app
chdir $Bin;
ok(! -d 'public', "public directory doesn't exist");
my $gen = Contenticious::Generator->new(quiet => 1);
$gen->generate_public_directory;
ok(  -e 'public/styles.css', 'stylesheet exists');
$ENV{CONTENTICIOUS_CONFIG} = "$Bin/test_config";

# build web app tester
$ENV{MOJO_HOME} = $Bin;
my $t = Test::Mojo->new('Contenticious');

# home page: listing of foo, bar, baz
$t->get_ok('/')->status_is(200)
  ->text_is(title => 'Shagadelic')
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_is(h1 => '');
is($t->tx->res->dom->at('link')->attr('href'), 'styles.css', 'right css');
my $navi = $t->tx->res->dom->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
my $list = $t->tx->res->dom->find('#content_list a');
is($list->size, 3, '3 content list links');
is($list->[0]->attr('href'), 'foo.html', 'right foo url');
is($list->[0]->at('strong')->text, 'Simple foo file', 'right foo title');
is($list->[1]->attr('href'), 'bar.html', 'right bar url');
is($list->[1]->at('strong')->text, 'bar Title', 'right bar title');
is($list->[2]->attr('href'), 'baz.html', 'right baz url');
is($list->[2]->at('strong')->text, "Title of baz's index", 'right baz title');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# foo: single page with ø
$t->get_ok('/foo')->status_is(200)
  ->text_is(title => 'Simple foo file - Shagadelic')
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_is(h1 => 'Hello wørld!');
is($t->tx->res->dom->at('link')->attr('href'), 'styles.css', 'right css');
$navi = $t->tx->res->dom->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($t->tx->res->dom->find('#navi li')->[0]->attr('class'), 'active', 'active');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# bar: empty listing
$t->get_ok('/bar')->status_is(200)
  ->text_is(title => 'bar Title - Shagadelic')
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_is(h1 => 'bar Title');
is($t->tx->res->dom->at('link')->attr('href'), 'styles.css', 'right css');
$navi = $t->tx->res->dom->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($t->tx->res->dom->find('#navi li')->[1]->attr('class'), 'active', 'active');
is($navi->[2]->attr('href'), 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($t->tx->res->dom->find('#content_list li')->size, 0, 'empty listing');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# baz: directory with index page
$t->get_ok('/baz')->status_is(200)
  ->text_is(title => "Title of baz's index - Shagadelic")
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_like('#content p'          => qr/I/)
  ->text_like('#content p strong'   => qr/has/)
  ->text_like('#content p em'       => qr/HTML/);
is($t->tx->res->dom->at('link')->attr('href'), 'styles.css', 'right css');
$navi = $t->tx->res->dom->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attr('href'), 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($t->tx->res->dom->find('#navi li')->[2]->attr('class'), 'active', 'active');
my $subnavi = $t->tx->res->dom->find('#subnavi a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'baz/a.html', 'right baz/a url');
is($subnavi->[0]->text, 'a', 'right baz/a link text');
is($subnavi->[1]->attr('href'), 'baz/b.html', 'right baz/b url');
is($subnavi->[1]->text, 'b', 'right baz/b link text');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# baz/a: "deep" page
$t->get_ok('/baz/a')->status_is(200)
  ->text_is(title => 'This is a - Shagadelic')
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_is(h1 => 'This is a');
is($t->tx->res->dom->at('link')->attr('href'), '../styles.css', 'right css');
$navi = $t->tx->res->dom->find('#navi li a');
is($navi->[0]->attr('href'), '../foo.html', 'right foo link');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), '../bar.html', 'right bar link');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), '../baz.html', 'right baz link');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($t->tx->res->dom->find('#navi li')->[2]->attr('class'), 'active', 'active');
$subnavi = $t->tx->res->dom->find('#subnavi a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'a.html', 'right baz/a link');
is($subnavi->[0]->text, 'a', 'right baz/a link text');
is($t->tx->res->dom->find('#subnavi li')->[0]->attr('class'), 'active', 'ac.');
is($subnavi->[1]->attr('href'), 'b.html', 'right baz/b link');
is($subnavi->[1]->text, 'b', 'right baz/b link text');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# baz/b: "deep" page
$t->get_ok('/baz/b')->status_is(200)
  ->text_is(title => 'b - Shagadelic')
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_is('#content p' => 'This is b');
is($t->tx->res->dom->at('link')->attr('href'), '../styles.css', 'right css');
$navi = $t->tx->res->dom->find('#navi li a');
is($navi->[0]->attr('href'), '../foo.html', 'right foo link');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attr('href'), '../bar.html', 'right bar link');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attr('href'), '../baz.html', 'right baz link');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($t->tx->res->dom->find('#navi li')->[2]->attr('class'), 'active', 'active');
$subnavi = $t->tx->res->dom->find('#subnavi a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attr('href'), 'a.html', 'right baz/a link');
is($subnavi->[0]->text, 'a', 'right baz/a link text');
is($subnavi->[1]->attr('href'), 'b.html', 'right baz/b link');
is($subnavi->[1]->text, 'b', 'right baz/b link text');
is($t->tx->res->dom->find('#subnavi li')->[1]->attr('class'), 'active', 'ac.');
$t->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# styles.css: stylesheet
$t->get_ok('/styles.css')->status_is(200)
  ->content_type_is('text/css')
  ->content_like(qr/^html, body {/);

# 404
$t->get_ok('/foomatic')->status_is(404)
  ->text_is(title => 'File not found! - Shagadelic')
  ->text_is('#top #name a' => 'Shagadelic')
  ->text_is(h1 => 'File not found!')
  ->text_like('#content p' => qr/^I'm sorry/)
  ->text_like('#copyright' => qr/Zaphod Beeblebrox/);

# perldoc
$t->get_ok('/perldoc/Contenticious')->status_is(200)
  ->text_is(title => 'Contenticious - build web sites from markdown files')
  ->text_is('h1 a#NAME' => 'NAME');

# done
remove_tree('public');
ok(! -d 'public', 'public directory deleted');

__END__
