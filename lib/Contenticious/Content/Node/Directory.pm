package Contenticious::Content::Node::Directory;
use Mojo::Base 'Contenticious::Content::Node';

use Contenticious::Content::Node::File;
use List::Util  'first';
use Carp;

has children    => sub { shift->build_children };
has meta        => sub { shift->build_meta };

sub build_children {
    my $self = shift;

    my $dirname     = $self->filename;
    my @children    = ();

    # sort and iterate directory entries
    foreach my $entry (sort glob("$dirname/*")) {

        # add content file node
        if ($entry =~ /.md$/ and -f -r $entry) {
            my $node = Contenticious::Content::Node::File->new(
                filename    => $entry,
                path_prefix => $self->path,
            );
            push @children, $node;
        }

        # add content directory node
        elsif (-d -r -x $entry) {
            my $node = Contenticious::Content::Node::Directory->new(
                filename    => $entry,
                path_prefix => $self->path,
            );
            push @children, $node;
        }
    }

    return \@children;
}

sub build_meta {
    my $self = shift;
    my %meta = ();

    # does a 'meta' file exist?
    my $meta_fn = $self->filename . '/meta';
    if (-f -r $meta_fn) {

        # open file for decoded reading
        open my $meta_fh, '<:encoding(UTF-8)', $meta_fn
            or croak "couldn't open $meta_fn: $!";

        # slurp
        my $meta_fc = do { local $/; <$meta_fh> };

        # extract meta information
        $meta{lc $1} = $2
            while $meta_fc =~ s/\A(\w+):\s*(.*)[\n\r]+//;
    }
    
    # get meta information from 'index' node
    elsif (my $index = $self->find_child('index')) {
        $meta{$_} = $index->meta->{$_} for keys %{$index->meta};
    }

    return \%meta;
}

sub build_html {
    my $self = shift;

    # try to find index
    my $index = $self->find_child('index');
    return unless $index;

    return $index->html;
}

sub find_child {
    my ($self, $name) = @_;
    return first {$_->name eq $name} @{$self->children};
}

sub find {
    my ($self, @names) = @_;
    my $node = $self;

    # done
    return $node unless @names;

    # find matching child node
    my $name = shift @names;
    $node = $self->find_child($name);

    # couldn't find
    return unless $node;

    # continue search on child node
    return $node->find(@names);
}

1;

__END__

=head1 NAME

Contenticious::Content::Node::Directory - a directory in a Contenticious tree

=head1 SYNOPSIS

    use Contenticious::Content::Node::Directory;
    my $dir = Contenticious::Content::Node::Directory->new(
        filename => 'foo'
    );
    my $first_child = $dir->children->[0];

=head1 DESCRIPTION

Directory nodes represent directories in a Contenticious::Content content tree.

=head1 ATTRIBUTES

Contenticious::Content::Node::Directory inherits all
L<Contenticious::Content::Node> attributes
and implements the following new ones:

=head2 children

An array ref of child elements in this content tree.

=head1 METHODS

Contenticious::Content::Node::Directory inherits all
L<Contenticious::Content::Node> methods
and implements the following new ones:

=head2 C<find_child>

    my $foo = $dir->find_child('foo');

Returns the first child object with that name.

=head2 C<find>

    my $bar_baz = $dir->find(qw(bar baz));

Returns the first descendant with the path 'bar/baz' from here.

=head1 SEE ALSO

L<Contenticious::Content::Node>,
L<Contenticious::Content::Node::File>,
L<Contenticious::Content>,
L<Contenticious>
