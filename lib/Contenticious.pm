package Contenticious;
use Mojo::Base 'Mojolicious::Plugin';

use Contenticious::Node::Directory;
use File::Copy::Recursive 'dircopy';
use Carp;

has pages_dir   => sub { croak 'no pages_dir given' };
has root_node   => sub { shift->build_root_node };

# root_node builder
sub build_root_node {
    my $self = shift;

    # let there be root!
    return Contenticious::Node::Directory->new(
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

# register into Mojolicious apps
sub register {
    my ($self, $app, $args) = @_;

    # overwrite defaults
    $self->pages_dir($args->{pages_dir} // $app->home->rel_dir('pages'));

    # register contenticious helper
    $app->helper(contenticious => sub { $self });

    return $self;
}

1;
__END__
