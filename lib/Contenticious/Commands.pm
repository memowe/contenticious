package Contenticious::Commands;
use Mojo::Base -base;

use File::Copy::Recursive 'dircopy';
use Carp;

has app => sub { croak 'no app given' };

sub dump {
    my $self = shift;
    my $app  = $self->app;

    # prepare directory
    my $dd = $app->config->{dump_dir};
    $dd  //= $app->home->rel_dir('dump');

    mkdir $dd unless -d $dd;

    say 'dumping everything to ' . $dd . ' ...';

    # copy static directory contents
    dircopy($_, $dd) for @{$app->static->paths};

    # silence!
    $app->log->level('warn');

    # pretty subdispatching
    $app->plugin('Subdispatch', {base_url => 'http://dummy_base'});

    # dump content
    $app->content->for_all_nodes(sub {
        my $node = shift;

        # skip all index nodes (content from parent node)
        return if $node->name eq 'index';

        # determine dump file path
        my $path = $node->is_root ? 'index' : $node->path;
        my $ext  = $node->extension;
        my $df   = "$dd/${path}${ext}";

        # log 1
        print "${path}${ext} ... ";

        # create directory if needed
        mkdir "$dd/$path"
            if  not $node->is_root
                and $node->can('children') and @{$node->children}
                and not -d "$dd/$path";

        # get content
        my $res  = $app->subdispatch->get('content', cpath => $node->path);
        my $html = $res->body;

        # dump to file
        open my $fh, '>', $df or die "couldn't open file $df: $!";
        print $fh $html;

        # log 2
        say "done.";
    });

    say 'done!';
}

1;

__END__

=head1 NAME

Contenticious::Commands - commands used by the contenticious script

=head1 SYNOPSIS

    use Contenticious::Commands;
    my $cc = Contenticious::Commands->new(app => $app);
    $cc->dump;

=head1 DESCRIPTION

The application logic behind the contenticious script

=head1 ATTRIBUTES

=head2 C<app>

The web app to use.

=head1 METHODS

=head2 C<dump>

Generate static HTML files from the web app

=head1 SEE ALSO

L<Contenticious>
