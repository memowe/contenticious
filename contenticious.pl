#!/usr/bin/env perl

use Mojolicious::Lite;
use File::Copy::Recursive 'dircopy';
use lib app->home->rel_dir('lib'); # FindBin doesn't work with morbo

# configuration with good defaults
my $config_file = $ENV{CONTENTICIOUS_CONFIG} // app->home->rel_file('config');
my $config      = plugin Config => {file => $config_file};

# prepare contenticious
my $cont = plugin Contenticious => { pages_dir => $config->{pages_dir} };

plugin Charset => {charset => 'utf-8'};

# serve content
get '/*cpath' => {cpath => ''} => sub {
    my $self = shift;
    my $path = $self->param('cpath');
    
    # delete format
    $path =~ s/\.html$//;
    $self->stash->{cpath} =~ s/\.html$//;

    # found matching content node?
    my $content_node = $self->contenticious->find($path);
    $self->render_not_found and return unless defined $content_node;
    $self->stash(content_node => $content_node);

    # empty cache?
    $self->contenticious->empty_cache unless $self->config('cached');
} => 'content';

# dump command
my $command = $ARGV[0];
if (defined $command and $command eq 'dump') {

    # prepare directory
    my $dd = $config->{dump_dir} // app->home->rel_dir('dump');
    mkdir $dd unless -d $dd;

    say 'dumping everything to ' . $dd . ' ...';

    # copy static directoy content
    dircopy(app->static->root, $dd);

    # dump content
    $cont->for_all_nodes(sub {
        my $node = shift;

        # skip all index nodes (content from parent node)
        return if $node->name eq 'index';

        # determine dump file path
        my $path = $node->is_root ? 'index' : $node->path;
        my $df   = "$dd/$path.html";

        # create directory if needed
        mkdir "$dd/$path"
            if  not $node->is_root
                and $node->can('children') and @{$node->children}
                and not -d "$dd/$path";

        # prepare subdispatch
        my $tx  = app->build_tx;
        my $url = app->url_for('content', cpath => $node->path);
        $tx->req->url($url)->method('GET');

        # subdispatch
        app->handler($tx);
        my $html = $tx->res->body;

        # dump to file
        open my $fh, '>', $df or die "couldn't open file $df: $!";
        print $fh $html;
    });

    say 'done!';
}

# web app
else { app->start }

__DATA__

@@ content.html.ep
% layout 'contenticious', title => $content_node->title;
% if (defined $content_node->html) {
%= b($content_node->html)
% } else {
%= include 'list', content_node => $content_node
% }

@@ list.html.ep
% my $level =()= $self->req->url->path =~ m|/|g;
<h1><%= $content_node->title %></h1>
<ul id="content_list">
% foreach my $c (@{$content_node->children}) {
    % my $rel_url = '../' x ($level - 1) . $c->path . '.html';
    <li><a href="<%= $rel_url %>"><strong><%= $c->title %></strong></a></li>
% }
</ul>

@@ navi.html.ep
% my $level  =()= $self->req->url->path =~ m|/|g;
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
        % my $rel_url = '../' x ($level - 1) . $c->path . '.html';
        <li class="<%= $class %>">
            <a href="<%= $rel_url %>"><%= $c->navi_name %></a>
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
% my $level =()= $self->req->url->path =~ m|/|g;
<!doctype html>
<html>
<head>
    % my $t = join ' - ' => grep { $_ } stash('title'), config('name');
    <title><%= $t || 'contenticious!' %></title>
    <%= stylesheet '../' x ($level - 1) . 'styles.css' %>
</head>
<body>
<div id="top">
    <div id="inner">
        <p id="name"><a href="<%= ('../' x ($level - 1)) || './' %>">
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
