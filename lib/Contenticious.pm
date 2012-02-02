package Contenticious;
use Mojo::Base 'Mojolicious::Plugin';

use Contenticious::Content;
use Contenticious::Commands;
use Carp;

has app         =>  sub { croak 'no app given' };
has pages_dir   =>  sub { croak 'no pages_dir given' };

has content     =>  sub { my $self = shift;
    return Contenticious::Content->new(
        pages_dir   => $self->pages_dir,
    );
};

has commands    =>  sub { my $self = shift;
    return Contenticious::Commands->new(
        app     => $self->app,
        content => $self->content,
    );
};

# register into Mojolicious apps
sub register {
    my ($self, $app, $args) = @_;

    # overwrite defaults
    $self->pages_dir($args->{pages_dir} // $app->home->rel_dir('pages'));

    # register contenticious helper
    $app->helper(contenticious => sub { $self });

    return $self;
}

# Contenticious::Content shortcuts:

sub root_node { shift->content->root_node }

sub find { shift->content->find(@_) }

sub for_all_nodes { shift->content->for_all_nodes(@_) }

sub empty_cache { shift->content->empty_cache }

1;
__END__
