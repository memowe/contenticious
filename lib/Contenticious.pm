package Contenticious;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.333';

use Contenticious::Content;
use Carp;

has pages_dir   =>  sub { croak 'no pages_dir given' };

has content     =>  sub { my $self = shift;
    return Contenticious::Content->new(
        pages_dir   => $self->pages_dir,
    );
};

# init web app
sub startup {
    my $self = shift;

    # find out config file name
    my $config_file = $ENV{CONTENTICIOUS_CONFIG};
    $config_file  //= $self->home->rel_file('config');

    # load config
    my $config = $self->plugin(Config => {file => $config_file});

    # prepare content
    $self->pages_dir($config->{pages_dir} // $self->home->rel_dir('pages'));

    # dumping needs relative URLs
    $self->plugin('RelativeUrlFor');

    # add content helper
    $self->helper(contenticious => sub { $self->content });

    # set utf8 as default charset on all layers
    $self->plugin(Charset => {charset => 'utf8'});

    # tell the renderer where to find templates
    $self->renderer->classes(['Contenticious']);

    # perldoc renderer (to display Contenticious.pod for first-time-users)
    $self->plugin('PODRenderer') if $self->config('perldoc');

    # content action
    my $serve_content = sub {
        my $c    = shift;
        my $path = $c->param('cpath') // '';

        # delete format
        $path =~ s/\.\w+$//;

        # found matching content node?
        my $content_node = $c->contenticious->find($path);
        unless (defined $content_node) {
            $c->render_not_found;
            return;
        }

        # render static content nodes
        if ($content_node->isa('Contenticious::Content::Node::Static')) {
            $c->res->headers->content_type(Mojolicious::Types->new->type($content_node->format));
            $c->render(data => $content_node->raw);
        }

        else {
            $c->render(
                cpath           => $path,
                content_node    => $content_node,
                template        => 'content',
            );
        }

        # empty cache?
        $c->contenticious->empty_cache unless $c->config('cached');
    };

    # content routes
    my $r = $self->routes;
    $r->get('/'         => $serve_content);
    $r->get('/*cpath'   => $serve_content)->name('content');

}

1;

__DATA__

@@ content.html.ep
% layout 'contenticious', title => $content_node->title;
% if (defined $content_node->html) {
%== $content_node->html
% } else {
%= include 'list', content_node => $content_node
% }

@@ list.html.ep
<h1><%= $content_node->title %></h1>
<ul id="content_list">
% foreach my $c (@{$content_node->children}) {
    % my $url = rel_url_for 'content', cpath => $c->path, format => $c->format;
    <li><a href="<%= $url %>"><strong><%= $c->title %></strong></a></li>
% }
</ul>

@@ navi.html.ep
% my $node      = contenticious->root_node;
% my @names     = split m|/| => $cpath;
% my $level     = 1;
% LOOP: { do { # perldoc perlsyn: do-while isn't a loop
    % last unless $node->can('children');
    % my $name      = shift(@names) // '';
    % my $id_prefix = 'sub' x ($level - 1);
    % unless (
    %   (defined stash('only') and stash('only') != $level) or
    %   (defined stash('only_not') and stash('only_not') == $level)
    % ) {
    <ul class="navi" id="<%= $id_prefix %>navi">
        % foreach my $c (@{$node->children}) {
            % next if $c->name eq 'index';
            % next if $c->format ne 'html';
            % my $class   = $c->name eq $name ? 'active' : '';
            % my $url = rel_url_for 'content', cpath => $c->path, format => $c->format;
        <li class="<%= $class %>">
            <a href="<%= $url %>"><%= $c->navi_name %></a>
        </li>
        % }
    </ul>
    % }
    % $node = $node->find($name) or last;
    % $level++;
% } while 1 }

@@ not_found.html.ep
% my $url = $self->req->url;
% layout 'contenticious', title => 'File not found!';
<h1>File not found!</h1>
<p>I'm sorry, but I couldn't find what you were looking for:</p>
<p><strong><%= $url %></strong></p>

@@ layouts/contenticious.html.ep
<!doctype html>
<html>
<head>
    % my $t = join ' - ' => grep { $_ } stash('title'), config('name');
    <title><%= $t || 'contenticious!' %></title>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" type="text/css" href="<%= rel_url_for 'styles.css' %>">
</head>
<body>
<div id="top">
    <div id="inner">
        <p id="name"><a href="<%= rel_url_for 'content', cpath => '' %>">
            <%= config('name') // 'contenticious!' %>
        </a></p>
%= include 'navi', only => 1
    </div><!-- inner -->
</div><!-- top -->
<div id="main">
%= include 'navi', only_not => 1
<div id="content">
%= content
</div><!-- content -->
</div><!-- main -->
<div id="footer">
    % if (config 'copyright') {
    <p id="copyright">
        &copy;
        <%= 1900 + (localtime)[5] %>
        <%= config 'copyright' %>
    </p>
    % }
    <p id="built_with">
        built with
        <a href="http://memowe.github.com/contenticious">contenticious</a>,
        on top of <a href="http://mojolicio.us/">Mojolicious</a>.
    </p>
</div><!-- footer -->
</body>
</html>
