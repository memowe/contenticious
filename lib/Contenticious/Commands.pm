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

    # copy static directory content
    dircopy($app->static->root, $dd);

    # silence!
    $app->log->level('warn');

    # pretty subdispatching
    $app->plugin('Subdispatch');

    # dump content
    $app->content->for_all_nodes(sub {
        my $node = shift;

        # skip all index nodes (content from parent node)
        return if $node->name eq 'index';

        # determine dump file path
        my $path = $node->is_root ? 'index' : $node->path;
        my $df   = "$dd/$path.html";

        # log 1
        print "$path.html ... ";

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
