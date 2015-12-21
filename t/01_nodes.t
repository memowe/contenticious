#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 79;
use utf8;
use FindBin '$Bin';
use lib "$Bin/../lib";

use_ok('Contenticious::Content::Node');
use_ok('Contenticious::Content::Node::File');
use_ok('Contenticious::Content::Node::Directory');

# Contenticious::Content::Node tests
my $node = Contenticious::Content::Node->new;
isa_ok($node => 'Contenticious::Content::Node', 'generated object');
eval { $node->filename };
like($@, qr/no filename given/, 'right error message');
$node->filename('/foo/bar/42_baz.quux');
is($node->filename, '/foo/bar/42_baz.quux', 'right filename');
ok(! $node->is_root, "isn't root");
is($node->name, 'baz', 'right extracted name');
$node->path_prefix('quuuux');
is($node->path, 'quuuux/baz', 'right path');
is_deeply($node->meta, {}, 'right default meta hash');

# Contenticious::Content::Node::File tests
my $fnode = Contenticious::Content::Node::File->new(
    filename => "$Bin/test_pages/17_foo.md",
);
isa_ok($fnode => 'Contenticious::Content::Node::File', 'generated object');
ok(! $fnode->is_root, "isn't root");
like($fnode->filename, qr|/test_pages/17_foo.md$|, 'right filename');
is($fnode->name, 'foo', 'right extracted name');
is($fnode->raw, <<'EOF', 'right raw content');
Title: Simple foo file
navi_name: Foooo
custom_meta: custom meta content

Hello wørld!
============
EOF
is($fnode->content, <<'EOF', 'right content');
Hello wørld!
============
EOF
is_deeply($fnode->meta, {
    title       => 'Simple foo file',
    navi_name   => 'Foooo',
    custom_meta => 'custom meta content',
}, 'right meta data');
like($fnode->html, qr|<h1>Hello wørld!</h1>|, 'right html');
is($fnode->title, 'Simple foo file', 'right title from meta data');
is($fnode->navi_name, 'Foooo', 'right navi_name from meta data');

$fnode = Contenticious::Content::Node::File->new(
    filename => "$Bin/test_pages/19_baz/a.md",
);
ok(! $fnode->is_root, "isn't root");
is($fnode->name, 'a', 'right name');
is($fnode->raw, <<'EOF', 'right raw content');
This is a
=========
EOF
is($fnode->content, <<'EOF', 'right content');
This is a
=========
EOF
is_deeply($fnode->meta, {}, 'right meta data');
is($fnode->title, 'This is a', 'right title (html fallback)');
is($fnode->navi_name, 'a', 'right navi_name (name fallback)');

$fnode = Contenticious::Content::Node::File->new(
    filename => "$Bin/test_pages/19_baz/b.md",
);
ok(! $fnode->is_root, "isn't root");
is($fnode->name, 'b', 'right name');
is($fnode->raw, "This is b\n", 'right raw content');
is($fnode->content, "This is b\n", 'right content');
is_deeply($fnode->meta, {}, 'right meta data');
is($fnode->title, 'b', 'right title (name fallback)');
is($fnode->navi_name, 'b', 'right navi_name (name fallback');

# Contenticious::Content::Node::Directory tests
my $dnode = Contenticious::Content::Node::Directory->new(
    filename    => "$Bin/test_pages",
    is_root     => 1,
);
isa_ok($dnode => 'Contenticious::Content::Node::Directory', 'generated object');
ok($dnode->is_root, 'is root');
is($dnode->name, '', 'no name (root)');
is($dnode->path, '', 'right path');
is_deeply($dnode->meta, {}, 'right meta info');
is($dnode->html, undef, 'no html found');
is($dnode->title, '', 'right title (name fallback)');
is($dnode->navi_name, '', 'right navi_name (name fallback)');

isa_ok($dnode->children, 'ARRAY', 'children');
is(scalar(@{$dnode->children}), 3, 'three child nodes');
my @dnc = @{$dnode->children};

isa_ok($dnc[0], 'Contenticious::Content::Node::File', 'first child');
ok(! $dnc[0]->is_root, "isn't root");
is($dnc[0]->name, 'foo', 'right first child');
is($dnc[0]->path, 'foo', 'right first child path');

isa_ok($dnc[1], 'Contenticious::Content::Node::Directory', 'second child');
ok(! $dnc[1]->is_root, "isn't root");
is($dnc[1]->name, 'bar', 'right second child');
is($dnc[1]->path, 'bar', 'right second child path');
is_deeply($dnc[1]->meta, {
    title       => 'bar Title',
    navi_name   => 'Baaar',
    foo         => 'Bar Baz Quux',
}, 'right meta info of second child');
is($dnc[1]->html, undef, 'no html found');
is($dnc[1]->title, 'bar Title', 'right title');
is($dnc[1]->navi_name, 'Baaar', 'right navi_name from meta');

isa_ok($dnc[2], 'Contenticious::Content::Node::Directory', 'third child');
ok(! $dnc[2]->is_root, "isn't root");
is($dnc[2]->name, 'baz', 'right third child');
is($dnc[2]->path, 'baz', 'right third child path');
is_deeply($dnc[2]->meta, {
    title       => "Title of baz's index",
    navi_name   => 'Baaaz',
}, 'right meta info of third child');
like($dnc[2]->html, qr|<p>I <strong>has</strong> <em>HTML</em>|, 'right html');
is($dnc[2]->title, "Title of baz's index", 'right title');
is($dnc[2]->navi_name, 'Baaaz', 'right navi_name from meta');

# wrong directory
my $fail = Contenticious::Content::Node::Directory->new(filename => 'bullshit');
is_deeply($fail->meta, {}, 'right meta info (wrong dir)');
is_deeply($fail->children, [], 'right children array (wrong dir)');

# traverse Contenticious::Content::Node::Directory structures
my $root = $dnode;
is($root->find, $root, 'void traversing');
is($root->find->path, '', 'right path');
is($root->find('bullshit'), undef, 'failing search');
is($root->find('foo'), $root->children->[0], 'foo found');
is($root->find('foo')->path, 'foo', 'right foo path');
is($root->find('bar'), $root->children->[1], 'bar found');
is($root->find('bar')->path, 'bar', 'right bar path');
is($root->find(qw(bar quux)), undef, 'bar/quux not found');
is($root->find('baz'), $root->children->[2], 'baz found');
is($root->find('baz')->path, 'baz', 'right baz path');
is($root->find(qw(baz bullshit)), undef, 'baz/bullshit not found');
is($root->find(qw(baz a)), $root->children->[2]->children->[0], 'baz/a found');
is($root->find(qw(baz a))->path, 'baz/a', 'right baz/a path');

__END__
