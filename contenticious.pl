#!/usr/bin/env perl

BEGIN { use FindBin; use lib "$FindBin::Bin/mojo/lib" }

use Mojolicious::Lite;
use Text::Markdown qw( markdown );
use Mojo::File;

# build the content tree as a HoH to file names
sub content_tree {
    my $dirname = shift || app->home->rel_dir('pages');
    my %tree    = ();

    foreach my $e ( glob("$dirname/*") ) {

        if ( $e =~ m|([\w_-]+)\.md$| and -f $e and -r $e ) {
            $tree{$1} = $e;
        }
        elsif ( -d $e and -r $e and -x $e and $e =~ m|([\w_-]+)$| ) {
            $tree{$1} = content_tree($e);
            delete $tree{$1} unless keys %{ $tree{$1} };
        }

    }

    return \%tree;
}

# gimmeh dem stash and dem content_tree, k?
app->renderer->add_helper(
    stash           => sub { shift->stash(@_) },
    content_tree    => sub { content_tree },
);

# k, now gimmeh utf-8 pls
app->types->type( html => 'text/html; charset=utf-8' );

#kthx

# serve static content
app->static->root( app->home->rel_dir('public') )
    if -d app->home->rel_dir('public');

# serve managed content
get '/(*path).html' => [ path => qr([/\w_-]+) ] => sub {
    my $self        = shift;
    my @dirs        = split m|/| => $self->stash('path');
    my $dir_key     = join '}{' => @dirs;

    # file not found!
    unless ( eval "exists content_tree()->{$dir_key}" ) {
        $self->render(
            template    => 'not_found',
            format      => 'html',
            status      => 404,
        );
        return 1;
    }

        # the eval "content_tree()->{$dir_key}" is not cool, but
        #
        # use List::Util qw( reduce )
        # my $fpath = reduce {
        #     ref $a eq 'HASH' ? $a->{$b} : content_tree()->{$a}{$b}
        # } @dirs;
        #
        # is loooong and it fails in the exists part (auto-vivification).

    my $fpath   = eval "content_tree()->{$dir_key}";
    my $html    = markdown( Mojo::File->new( path => $fpath )->slurp );
    my $title   = $html =~ m|<h1>(.*?)</h1>| ? $1 : $dirs[-1];

    $self->render_inner( content => $html );
    $self->stash(
        title       => $title,
        template    => 'layouts/wrapper',
    );

} => 'content';

# serve managed directories
get '/(*path)/$' => [ path => qr([/\w_-]+) ] => sub {
    my $self    = shift;
    my $path    = $self->stash('path');
    my @dirs    = split m|/| => $path;
    my $dir_key = join '}{' => @dirs;

    # directory not found!
    unless ( eval "exists content_tree()->{$dir_key}"
             and eval "ref content_tree()->{$dir_key} eq 'HASH'" ) {
        $self->render(
            template    => 'not_found',
            format      => 'html',
            status      => 404,
        );
        return 1;
    }

    my $dir_hash = eval "content_tree()->{$dir_key}";

    # index found!
    if ( exists $dir_hash->{index} ) {
        $self->redirect_to( "$path/index.html" );
        return 1;
    }

    # no index. now what?
    
    # empty
    unless ( keys %$dir_hash ) {
        $self->render(
            template    => 'not_found',
            format      => 'html',
            status      => 404,
        );
        return 1;
    }

    # no choice!
    if ( keys %$dir_hash == 1 ) {
        my $key = ( keys %$dir_hash )[0];
        $self->redirect_to( "/$path/$key.html" );
        return 1;
    }

    # multiple choice!
    $self->stash(
        urls        => [ map { "/$path/$_.html" } keys %$dir_hash ],
        template    => 'multiple_choice',
    );

} => 'directory';

shagadelic( $ARGV[0] || 'daemon' );

__DATA__

@@ layouts/wrapper.html.ep
<!doctype html>

<html>
<head><title><%= $title || 'contenticious!' %></title></head>
<link rel="stylesheet" type="text/css" href="/screen.css" media="screen">
<body>
<div id="content">

%== content

</div>
</body>
</html>

@@ multiple_choice.html.ep
% layout 'wrapper';
% stash title => 'More than one document!';
<h1><%= stash 'title' %></h1>
<p>I didn't found an index document for this directory. Please choose:</p>
<ul class="multiple_choice">
% foreach my $url ( @$urls ) {
    <li><a href="<%= $url %>"><%= $url %></a></li>
% }
</ul>

@@ exception.html.ep
% layout 'wrapper';
% stash title => 'Exception!';
<h1><%= stash 'title' %></h1>
<pre class="exception"><%= $exception %></pre>

@@ not_found.html.ep
% layout 'wrapper';
% stash title => 'Error 404: Resource not found!';
<h1><%= stash 'title' %></h1>
<p>The resource you requested
(<code><%= $self->req->url->to_abs %></code>)
could not be found. Sorry!</p>

__END__

=head1 NAME

Contenticious -- simple file based "CMS" on Mojo steroids!

=head1 SYNOPSIS

    $ vim pages/index.md
    $ mkdir pages/section
    $ vim pages/section/foo.md
    $ vim pages/section/bar.md
    $ perl contenticious.pl

=head1 DESCRIPTION

Contenticious is a very simple way to glue together some content to a small website. You just write Markdown files and check the generated HTML in your browser. To publish, just use the C<static> command to generate static HTML as described below.

=head2 HOW TO ORGANIZE YOUR CONTENT

=head2 HOW TO DEPLOY

=head2 CUSTOMIZATION (C11N)

=head1 AUTHOR AND LICENSE

Copyright (c) 2009 Mirko Westermeier, <mail@memowe.de>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

