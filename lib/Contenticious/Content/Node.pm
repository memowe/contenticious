package Contenticious::Content::Node;
use Mojo::Base -base;

use Carp;
use File::Basename 'basename';

has is_root     => undef;
has filename    => sub { croak 'no filename given' };
has name        => sub { shift->build_name };
has path_prefix => '';
has path        => sub { shift->build_path };
has meta        => sub { {} };
has html        => sub { shift->build_html };
has title       => sub { shift->build_title };
has navi_name   => sub { shift->build_navi_name };
has extension   => sub { '.html' };
has format      => sub { 'html' };

sub build_name {
    my $self = shift;

    # root node
    return '' if $self->is_root;

    # get last path part
    my $base = basename($self->filename);

    # delete prefix
    $base =~ s/^\d+_//;

    # delete suffix
    $base =~ s/\.\w+$//;

    return $base;
}

sub build_path {
    my $self = shift;

    # root node
    return '' if $self->is_root;

    # build from path_prefix, infix slash and name
    return join '/' => grep {$_ ne ''} $self->path_prefix, $self->name;
}

sub build_html {
    my $self = shift;
    croak 'build_html needs to be overwritten by subclass';
}

sub build_title {
    my $self = shift;

    # try to extract title
    return $self->meta->{title} if exists $self->meta->{title};
    return $1 if defined $self->html and $self->html =~ m|<h1>(.*?)</h1>|i;
    return $self->name;
}

sub build_navi_name {
    my $self = shift;

    # try to find a proper name
    return $self->meta->{navi_name} if exists $self->meta->{navi_name};
    return $self->name;
}

sub find {
    my ($self, @names) = @_;

    # no search
    return $self unless @names;

    # not found
    return;
}

1;

__END__

=head1 NAME

Contenticious::Content::Node - base class for Contenticious content

=head1 SYNOPSIS

    use Mojo::Base 'Contenticious::Content::Node';

=head1 DESCRIPTION

Basic node functionality for both files and directories.

=head1 ATTRIBUTES

=head2 C<is_root>

Is true iff this node is the root node of a content tree.

=head2 C<filename>

The filename of this node. Needs to be set early.

=head2 C<name>

The name of this node.

=head2 C<path_prefix>

A prefix for this node's path in the whole content tree.

=head2 C<path>

This node's path in the whole content tree.

=head2 C<meta>

A hashref of meta informations.

=head2 C<html>

Generated HTML from this node.

=head2 C<title>

This node's title.

=head2 C<navi_name>

The name this node has in the page navigation.

=head1 METHODS

=head2 C<find>

Find nodes in this subtree. This is a very basic version. It returns the
node if the search path is empty and undef in all other cases.

=head1 SEE ALSO

L<Contenticious::Content>,
L<Contenticious::Content::Node::File>,
L<Contenticious::Content::Node::Directory>,
L<Contenticious>
