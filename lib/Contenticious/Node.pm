package Contenticious::Node;
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
