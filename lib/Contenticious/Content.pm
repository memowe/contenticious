package Contenticious::Content;
use Mojo::Base -base;

use Contenticious::Content::Node::Directory;
use File::Copy::Recursive 'dircopy';
use Carp;

has pages_dir   => sub { croak 'no pages_dir given' };
has root_node   => sub { shift->build_root_node };

# root_node builder
sub build_root_node {
    my $self = shift;

    # let there be root!
    return Contenticious::Content::Node::Directory->new(
        filename    => $self->pages_dir,
        is_root     => 1,
    );
}

# find a content node for a given path like foo/bar/baz
sub find {
    my $self = shift;
    my $path = shift // '';

    # split path and find content node
    my @names = split m|/| => $path;
    return $self->root_node->find(@names);
}

# execute a subroutine for all content nodes
# the given subroutine gets the node as a single argument
sub for_all_nodes {
    my ($self, $sub) = @_;
    _walk_tree($self->root_node, $sub);
}

# not a public method but a recursive utitlity function
sub _walk_tree {
    my ($node, $sub) = @_;
    
    # execute
    $sub->($node);

    # walk the tree if possible (duck typing)
    if ($node->can('children')) {
        _walk_tree($_, $sub) foreach @{$node->children};
    }
}

# delete cached content
sub empty_cache {
    my $self = shift;

    # urgs
    delete $self->{root_node};
}

1;

__END__

=head1 NAME

Contenticious::Content - content for Contenticious

=head1 SYNOPSIS

    use Contenticious::Content;
    my $content = Contenticious::Content->new(pages_dir => 'pages');
    my $node    = $content->find('foo/bar');

=head1 DESCRIPTION

Access a Contenticious content tree.

=head1 ATTRIBUTES

=head2 C<pages_dir>

The directory to read from

=head2 C<root_node>

The root of the generated content tree. Will be generated from C<pages_dir>.

=head1 METHODS

=head2 C<find>

    my $node = $content->find('foo/bar');

Find a content node for a given path

=head2 C<for_all_nodes>

    $content->for_all_nodes(sub {
        my $node = shift;
        do_something_with($node);
    });

Execute a subroutine for all content nodes

=head2 C<empty_cache>

Delete cached content

=head1 SEE ALSO

L<Contenticious::Content::Node>, L<Contenticious>
