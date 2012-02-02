#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 14;
use FindBin '$Bin';
use lib "$Bin/../lib";

use_ok('Contenticious::Content');

my $cont = Contenticious::Content->new;
isa_ok($cont, 'Contenticious::Content', 'generated object');

# pages_dir
eval { $cont->pages_dir };
like($@, qr/no pages_dir given/, 'right error message');
$cont->pages_dir("$Bin/pages");
like($cont->pages_dir, qr|/pages|, 'right pages_dir');

# root_node
my $rn = $cont->root_node;
isa_ok($rn, 'Contenticious::Content::Node', 'root_node');
my $baza = $rn->find(qw(baz a));
isa_ok($baza, 'Contenticious::Content::Node::File', 'found node');
is($baza->name, 'a', 'right name of found node');
like($baza->html, qr|<h1>This is a</h1>|, 'right html of found node');

# wrong pages_dir
my $fail = Contenticious::Content->new(pages_dir => 'bullshitbullshitbullshit');
isa_ok($fail->root_node, 'Contenticious::Content::Node',
    'root_node from wrong dir'
);
is_deeply($fail->root_node->children, [], 'right children array (wrong dir)');

# find method
is($cont->find, $cont->root_node, 'root found');
is($cont->find('bullshit'), undef, 'bullshit not found');
my $found = $cont->find('baz/a');
is($found, $baza, 'baz/a found');

# for_all_nodes method
my @paths = ();
$cont->for_all_nodes(sub { push @paths, shift->path });
is(join('|' => @paths), '|foo|bar|baz|baz/a|baz/b|baz/index', 'right paths');

__END__
