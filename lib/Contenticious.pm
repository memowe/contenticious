package Contenticious;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.391';

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
    $self->pages_dir($config->{pages_dir} // $self->home->rel_file('pages'));

    # dumping needs relative URLs
    $self->plugin('RelativeUrlFor');

    # add content helper
    $self->helper(contenticious => sub { $self->content });

    # tell the renderer where to find templates
    $self->renderer->classes(['Contenticious']);

    # perldoc renderer (to display Contenticious.pod for first-time-users)
    $self->plugin('PODRenderer') if $self->config('perldoc');

    # content action
    my $serve_content = sub {
        my $c    = shift;
        my $path = $c->param('cpath') // '';

        # delete format
        $path =~ s/\.html$//;

        # found matching content node?
        my $content_node = $c->contenticious->find($path);
        unless (defined $content_node) {
            $c->reply->not_found;
            return;
        }

        # go
        $c->render(
            cpath           => $path,
            content_node    => $content_node,
            template        => 'content',
        );

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
    %= include list => content_node => $content_node
% }

@@ list.html.ep
%= t h1 => $content_node->title || config('name')

%= t ul => id => content_list => begin
    % foreach my $child (@{$content_node->children}) {
        % my $url = rel_url_for content => cpath => $child->path => format => 'html';
        %= t li => link_to $child->title => $url
    % }
% end

@@ navi.html.ep
% my $names = stash('names') // [split m|/| => $cpath];
% my $here  = stash('here') // 1;

% if ($node->can('children') and @{$node->children}) {
    % my $name = shift(@$names) // '';

    %= t ul => class => navi => begin
        % foreach my $child (@{$node->children}) {
            % next if $child->name eq 'index';
            % my $h = ($here && $child->name eq $name) ? 'active' : '';

            %= t li => class => $h => begin
                % my $url = rel_url_for content => cpath => $child->path => format => 'html';
                %= link_to $child->navi_name => $url
                %= include navi => node => $child, names => $names, here => $h;
            % end
        % }
    % end

% }

@@ not_found.html.ep
% layout 'contenticious', title => 'File not found!';
%= t h1 => 'File not found!'
%= t p => begin
    I'm sorry, but I couldn't find what you were looking for:
    %= t strong => t tt => $self->req->url
% end

@@ layouts/contenticious.html.ep
<!doctype html>
%= t html => begin
    %= t head => begin
        %= t meta => charset => 'UTF-8'
        % my $title = join ' - ' => grep {$_} stash('title'), config('name');
        %= t title => $title // 'Contenticious'
    % end
    %= t body => begin
        %= t div => id => top => begin
            %= link_to config('name') => rel_url_for content => cpath => ''
        % end
        %= include navi => node => contenticious->root_node;
        %= t div => id => content => begin
            %= content
        % end
    % end
    %= t footer => begin
        % if (config 'copyright') {
            %= t p => id => copyright => begin
                &copy; <%= 1900 + (localtime)[5] %> <%= config 'copyright' %>.
            % end
        % }
        %= t p => id => built_with => begin
            Built with
            <%= link_to Contenticious => 'https://github.com/memowe/contenticious' %>,
            on top of
            <%= link_to Mojolicious => 'http://mojolicious.org' %>.
        % end
    % end
% end
