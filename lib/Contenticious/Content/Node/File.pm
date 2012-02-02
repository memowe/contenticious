package Contenticious::Content::Node::File;
use Mojo::Base 'Contenticious::Content::Node';

use Carp;
use Mojo::Util      'decode';
use Text::Markdown  'markdown';

has raw     => sub { shift->build_raw };
has content => sub { shift->build_content_and_meta->content };
has meta    => sub { shift->build_content_and_meta->meta };

sub build_raw {
    my $self = shift;

    # open file for decoded reading
    my $fn = $self->filename;
    open my $fh, '<:encoding(UTF-8)', $fn or croak "couldn't open $fn: $!";

    # slurp
    return do { local $/; <$fh> };
}

sub build_content_and_meta {
    my $self    = shift;
    my $content = $self->raw;
    my %meta    = ();

    # extract (and delete) meta data from file content
    $meta{lc $1} = $2
        while $content =~ s/\A(\w+):\s*(.*)[\n\r]+//;

    # done
    $self->content($content)->meta(\%meta);
}

sub build_html {
    my $self = shift;
    return markdown($self->content);
}

1;
__END__
