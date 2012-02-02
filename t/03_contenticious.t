#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 6;
use FindBin '$Bin';
use lib "$Bin/../lib";

use_ok('Contenticious');

my $cont = Contenticious->new;
isa_ok($cont, 'Contenticious', 'generated object');

# pages_dir
eval { $cont->pages_dir };
like($@, qr/no pages_dir given/, 'right error message');
$cont->pages_dir("$Bin/pages");
like($cont->pages_dir, qr|/pages|, 'right pages_dir');

# find method
my $rn = $cont->content->root_node;
is($cont->find('bar/a'), $rn->find('bar/a'), 'baz/a found');

# for_all_nodes method
my @paths = ();
$cont->for_all_nodes(sub { push @paths, shift->path });
is(join('|' => @paths), '|foo|bar|baz|baz/a|baz/b|baz/index', 'right paths');

__END__
