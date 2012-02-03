package Contenticious;
use Mojo::Base 'Mojolicious';

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
    $self->plugin(RelativeUrlFor => {replace_url_for => 1});

    # add content helper
    $self->helper(contenticious => sub { $self->content });

    # set utf8 as default charset on all layers
    $self->plugin(Charset => {charset => 'utf8'});

    # tell the renderer where to find templates
    $self->renderer->default_template_class('Contenticious');

    # content action
    my $serve_content = sub {
        my $c    = shift;
        my $path = $c->param('cpath') // '';

        # delete format
        $path =~ s/\.html$//;

        # found matching content node?
        my $content_node = $c->app->content->find($path);
        unless (defined $content_node) {
            $c->render_not_found;
            return;
        }

        # go
        $c->render(
            cpath           => $path,
            content_node    => $content_node,
            template        => 'content',
        );

        # empty cache?
        $c->app->content->empty_cache unless $c->config('cached');
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
%= b($content_node->html)
% } else {
%= include 'list', content_node => $content_node
% }

@@ list.html.ep
<h1><%= $content_node->title %></h1>
<ul id="content_list">
% foreach my $c (@{$content_node->children}) {
    % my $url = url_for 'content', cpath => $c->path, format => 'html';
    <li><a href="<%= $url %>"><strong><%= $c->title %></strong></a></li>
% }
</ul>

@@ navi.html.ep
% my $node      = contenticious->root_node;
% my @names     = split m|/| => $cpath;
% my $prefix    = '';
% LOOP: { do { # perldoc perlsyn: do-while isn't a loop
    % last unless $node->can('children');
    % my $name = shift(@names) // '';
    <ul id="<%= $prefix %>navi">
    % foreach my $c (@{$node->children}) {
        % next if $c->name eq 'index';
        % my $class   = $c->name eq $name ? 'active' : '';
        % my $url = url_for 'content', cpath => $c->path, format => 'html';
        <li class="<%= $class %>">
            <a href="<%= $url %>"><%= $c->navi_name %></a>
        </li>
    % }
    </ul>
    % $node = $node->find($name) or last;
    % $prefix .= 'sub';
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
    <%= stylesheet 'styles.css' %>
</head>
<body>
<div id="top">
    <div id="inner">
        <p id="name"><a href="<%= url_for 'content', cpath => '' %>">
            <%= config('name') // 'contenticious!' %>
        </a></p>
%= include 'navi'
    </div><!-- inner -->
</div><!-- top -->
<div id="content">
%= content
</div><!-- content -->
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
        <a href="http://github.com/memowe/contenticious">contenticious</a>,
        on top of <a href="http://mojolicio.us/">Mojolicious</a>.
    </p>
</div><!-- footer -->
</body>
</html>
