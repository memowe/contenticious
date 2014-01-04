package Contenticious::Content::Node::Static;
use Mojo::Base 'Contenticious::Content::Node';

use Carp;
use Mojo::Util      'slurp';
use File::Basename 'basename';

has raw     => sub { slurp shift->filename };
has content => sub { shift->raw };
has extension => sub { '.' . shift->format };
has format    => sub { shift->build_format };

sub build_html { return ''; }

sub build_format {
    my $self = shift;
    my ($ext) = ($self->filename =~ m/\.(\w+)$/);
    return $ext;
}

sub build_name {
    my $self = shift;

    # get last path part
    my $base = basename($self->filename);

    # delete suffix
    $base =~ s/\.\w+$//;

    return $base;
}

1;

__END__

=head1 NAME

Contenticious::Content::Node::Static - a static file in a Contenticious content tree

=head1 SYNOPSIS

    use Contenticious::Content::Node::Static;
    my $file = Contenticious::Content::Node::File->new(
        filename => 'cat.gif'
    );
    my $output = $file->output;

=head1 DESCRIPTION

File nodes represent files in a Contenticious::Content content tree.

=head1 ATTRIBUTES

Contenticious::Content::Node::File inherits all L<Contenticious::Content::Node>
attributes and implements the following new ones:

=head2 raw

Raw file content right after decoding.

=head2 content

File content after meta informations are extracted.

=head1 METHODS

Contenticious::Content::Node::File inherits all L<Contenticious::Content::Node>
methods and implements the following new ones:

=head2 html

    my $html = $file->html;

HTML generated by L<Text::Markdown> from this file's C<content>.

=head1 SEE ALSO

L<Contenticious::Content::Node>,
L<Contenticious::Content::Node::Directory>,
L<Contenticious::Content>,
L<Contenticious>