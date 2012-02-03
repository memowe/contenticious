#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Test::More tests => 112;
use File::Path 'remove_tree';
use Mojo::Dom;
use FindBin '$Bin';

# slurp helper
sub slurp {
    my $fn = shift;
    open my $fh, '<:encoding(UTF-8)', $fn or die "couldn't open $fn: $!";
    return do { local $/; <$fh> };
}

my $dd = "$Bin/dump";
remove_tree($dd);
ok(! -d $dd, 'dump directory gone');

# hardcode dumping acshun
$ENV{MOJO_LOG_LEVEL} = 'warn'; # silence!
$ENV{CONTENTICIOUS_CONFIG} = "$Bin/config";
unshift @ARGV, 'dump';
require("$Bin/../contenticious.pl");

# stylesheet
ok(-f -r "$dd/styles.css", 'stylesheet found');
like(slurp("$dd/styles.css"), qr/#built_with a {/, 'right stylesheet');

# index
ok(-f -r "$dd/index.html", 'index found');
my $index = Mojo::DOM->new(slurp("$dd/index.html"));
is($index->at('title')->text, 'Shagadelic', 'right title');
is($index->at('link')->attrs->{href}, 'styles.css', 'right css link');
is($index->at('#top #name a')->text, 'Shagadelic', 'right site name');
my $navi = $index->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attrs->{href}, 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attrs->{href}, 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attrs->{href}, 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($index->at('h1')->text, '', 'right h1');
my $list = $index->find('#content_list a');
is($list->size, 3, '3 content list links');
is($list->[0]->attrs->{href}, 'foo.html', 'right foo url');
is($list->[0]->at('strong')->text, 'Simple foo file', 'right foo title');
is($list->[1]->attrs->{href}, 'bar.html', 'right bar url');
is($list->[1]->at('strong')->text, 'bar Title', 'right bar title');
is($list->[2]->attrs->{href}, 'baz.html', 'right baz url');
is($list->[2]->at('strong')->text, "Title of baz's index", 'right baz title');
like($index->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# foo
ok(-f -r "$dd/foo.html", 'foo found');
my $foo = Mojo::DOM->new(slurp("$dd/foo.html"));
is($foo->at('title')->text, 'Simple foo file - Shagadelic', 'right title');
is($foo->at('link')->attrs->{href}, 'styles.css', 'right css link');
is($foo->at('#top #name a')->text, 'Shagadelic', 'right site name');
$navi = $foo->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attrs->{href}, 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($foo->find('#navi li')->[0]->attrs->{class}, 'active', 'foo is active');
is($navi->[1]->attrs->{href}, 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attrs->{href}, 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($foo->at('h1')->text, 'Hello wørld!', 'right h1');
like($foo->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# bar
ok(-f -r "$dd/bar.html", 'bar found');
my $bar = Mojo::DOM->new(slurp("$dd/bar.html"));
is($bar->at('title')->text, 'bar Title - Shagadelic', 'right title');
is($bar->at('link')->attrs->{href}, 'styles.css', 'right css link');
is($bar->at('#top #name a')->text, 'Shagadelic', 'right site name');
$navi = $bar->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attrs->{href}, 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attrs->{href}, 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($bar->find('#navi li')->[1]->attrs->{class}, 'active', 'bar is active');
is($navi->[2]->attrs->{href}, 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($bar->at('h1')->text, 'bar Title', 'right h1');
is($bar->find('#content_list li')->size, 0, 'empty listing');
like($bar->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# baz
ok(-f -r "$dd/baz.html", 'baz found');
my $baz = Mojo::DOM->new(slurp("$dd/baz.html"));
is($baz->at('title')->text, "Title of baz's index - Shagadelic", 'right title');
is($baz->at('link')->attrs->{href}, 'styles.css', 'right css link');
is($baz->at('#top #name a')->text, 'Shagadelic', 'right site name');
$navi = $baz->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attrs->{href}, 'foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attrs->{href}, 'bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attrs->{href}, 'baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
is($baz->find('#navi li')->[2]->attrs->{class}, 'active', 'baz is active');
my $subnavi = $baz->find('#subnavi a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attrs->{href}, 'baz/a.html', 'right baz/a url');
is($subnavi->[0]->text, 'a', 'right baz/a link text');
is($subnavi->[1]->attrs->{href}, 'baz/b.html', 'right baz/b url');
is($subnavi->[1]->text, 'b', 'right baz/b link text');
like($baz->at('#content p')->text, qr/I/, 'right content');
like($baz->at('#content p strong')->text, qr/has/, 'right content');
like($baz->at('#content p em')->text, qr/HTML/, 'right content');
like($baz->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# baz/a
ok(-f -r "$dd/baz/a.html", 'baz/a found');
my $baza = Mojo::DOM->new(slurp("$dd/baz/a.html"));
is($baza->at('title')->text, 'This is a - Shagadelic', 'right title');
is($baza->at('link')->attrs->{href}, '../styles.css', 'right css link');
is($baza->at('#top #name a')->text, 'Shagadelic', 'right site name');
$navi = $baza->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attrs->{href}, '../foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attrs->{href}, '../bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attrs->{href}, '../baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
$subnavi = $baza->find('#subnavi a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attrs->{href}, 'a.html', 'right baz/a url');
is($subnavi->[0]->text, 'a', 'right baz/a link text');
is($baza->find('#subnavi li')->[0]->attrs->{class}, 'active', 'baz/a active');
is($subnavi->[1]->attrs->{href}, 'b.html', 'right baz/b url');
is($subnavi->[1]->text, 'b', 'right baz/b link text');
is($baza->at('h1')->text, 'This is a', 'right content');
like($baza->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

# baz/b: "deep" page
ok(-f -r "$dd/baz/b.html", 'baz/b found');
my $bazb = Mojo::DOM->new(slurp("$dd/baz/b.html"));
is($bazb->at('title')->text, 'b - Shagadelic', 'right title');
is($bazb->at('link')->attrs->{href}, '../styles.css', 'right css link');
is($bazb->at('#top #name a')->text, 'Shagadelic', 'right site name');
$navi = $bazb->find('#navi a');
is($navi->size, 3, '3 navigation links');
is($navi->[0]->attrs->{href}, '../foo.html', 'right foo url');
is($navi->[0]->text, 'Foooo', 'right foo link text');
is($navi->[1]->attrs->{href}, '../bar.html', 'right bar url');
is($navi->[1]->text, 'Baaar', 'right bar link text');
is($navi->[2]->attrs->{href}, '../baz.html', 'right baz url');
is($navi->[2]->text, 'Baaaz', 'right baz link text');
$subnavi = $bazb->find('#subnavi a');
is($subnavi->size, 2, '2 subnavigation links');
is($subnavi->[0]->attrs->{href}, 'a.html', 'right baz/a url');
is($subnavi->[0]->text, 'a', 'right baz/a link text');
is($subnavi->[1]->attrs->{href}, 'b.html', 'right baz/b url');
is($subnavi->[1]->text, 'b', 'right baz/b link text');
is($bazb->find('#subnavi li')->[1]->attrs->{class}, 'active', 'baz/a active');
is($bazb->at('#content p')->text, 'This is b', 'right content');
like($bazb->at('#copyright')->text, qr/Zaphod Beeblebrox/, 'right copyright');

remove_tree($dd);
ok(! -d $dd, 'dump directory gone');

__END__
