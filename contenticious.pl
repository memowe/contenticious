#!/usr/bin/env perl

BEGIN { use FindBin; use lib "$FindBin::Bin/mojo/lib" }

use Mojolicious::Lite;
use Mojo::File;
use Text::Markdown qw( markdown );
use List::Util qw( first );

# build the content tree as a LoHoLoH...
# realized as a sub to get changed content immediately
sub content_tree {
    my $dirname = shift || app->home->rel_dir('pages');
    my @tree    = ();

    for ( sort glob("$dirname/*") ) {

        # content file
        if ( /([\w_-]+)\.md$/ and -f and -r ) {
            ( my $name = $1 ) =~ s/^(\d+_)?//; # drop sort prefix

            push @tree, {
                name        => $name,
                filename    => $_,
                type        => 'file',
            };

            next;
        }

        #content directory
        if ( /([\w_-]+)$/ and -d and -r and -x ) {
            ( my $name = $1 ) =~ s/^(\d+_)?//; # drop sort prefix

            my $content = content_tree($_);

            push @tree, {
                name        => $name,
                filename    => $_,
                type        => 'dir',
                content     => @$content ? $content : undef,
            };

            next;
        }
    }

    return \@tree;
}

# return the resource data hash according to the given names list.
# if in list context, it returns also a content_tree with 'active' marks
# the index resource if the target is a dir and an index exists
# undef if not found
sub active_content {
    my @names           = @_;
    my $content_tree    = content_tree;
    my $content         = $content_tree;
    my $entry;

    foreach my $name ( @names ) {
        $entry = first { $_->{name} eq $name } @$content;
        return unless $entry;

        $entry->{active} = 1;

        if ( $entry->{type} eq 'dir' ) {
            $content = $entry->{content};
        }
        else { last }
    }

    return $entry, $content_tree if wantarray;
    return $entry;
}

# k, now gimmeh dem stash and dem utf-8 pls
app->renderer->add_helper( stash => sub { shift->stash(@_) } );
app->types->type( html => 'text/html; charset=utf-8' );
#kthx

# serve static content
app->static->root( app->home->rel_dir('public') )
    if -d app->home->rel_dir('public');

# generate a 404 error with navigatable content_tree
sub not_found {
    shift->render(
        template        => 'not_found',
        format          => 'html',
        status          => 404,
        content_tree    => content_tree(),
    );
}

# serve managed content
get '/(*path).html' => [ path => qr([/\w_-]+) ] => sub {
    my $self    = shift;
    my @names   = split m|/| => $self->stash('path');
    my ( $entry, $content_tree ) = active_content( @names );

    # content not found
    unless ( $entry and $entry->{type} eq 'file' ) {
        not_found($self);
        return 1;
    }

    my $file    = Mojo::File->new( path => $entry->{filename} );
    my $html    = markdown( $file->slurp );
    my $title   = $html =~ m|<h1>(.*?)</h1>| ? $1 : $names[-1];

    $self->stash(
        title           => $title,
        content_tree    => $content_tree,
        template        => 'layouts/wrapper',
    );
    $self->render_inner( content => $html );

} => 'content';

# serve managed directories
get '(*path)/$' => [ path => qr([/\w_-]*) ] => sub {
    my $self    = shift;
    my $path    = $self->stash('path');
    my @names   = grep { $_ } split m|/| => $path;
    my ( $entry, $content_tree ) = active_content( @names );

    # /
    $entry = { content => $content_tree, type => 'dir' } unless @names;

    # directory not found
    unless ( $entry and $entry->{type} eq 'dir' ) {
        not_found($self);
        return 1;
    }

    # index found
    if ( my $index = first { $_->{name} eq 'index' } @{ $entry->{content} } ) {
        $self->redirect_to( "$path/index.html" );
        return 1;
    }

    # no index. generate one.
    $self->stash(
        path            => $path,
        entry           => $entry,
        content_tree    => $content_tree,
    );

} => 'directory';

# need this catcher to have a content_tree in not_found.html.epl
get '(*anything)' => \&not_found;

shagadelic( $ARGV[0] || 'daemon' );

__DATA__

@@ layouts/wrapper.html.ep
<!doctype html>

<html>
<head><title><%= $title || 'contenticious!' %></title></head>
<link rel="stylesheet" type="text/css" href="/screen.css" media="screen">
<body>
%== include 'navi';
<div id="content">

%== content

</div>
</body>
</html>

@@ navi.html.ep
<div id="navi">
% my $tree   = $content_tree;
% my $prefix = '';
% while ( $tree ) {
%   my $list = $tree;
%   undef $tree;
%   my $pre = $prefix;
%   last unless @$list;
<ul class="navi">
%   for ( @$list ) {
%       my $class   = $_->{active} ? ' class="active"' : '';
%       my $ext     = $_->{type} eq 'file' ? '.html' : '/';
    <li<%== $class %>>
        <a href="<%== "$pre/$_->{name}$ext" %>"><%= $_->{name} %></a>
    </li>
%       if ( $_->{active} and $_->{type} eq 'dir' ) {
%           $tree = $_->{content};
%           $prefix .= "/$_->{name}";
%       }
%   }
</ul>
% }
</div>

@@ directory.html.ep
% layout 'wrapper';
% stash title => $entry->{name} . ' - Index';
<h1><%= stash 'title' %></h1>
% if ( @{ $entry->{content} } ) {
<ul class="multiple_choice">
%   foreach my $e ( @{ $entry->{content} } ) {
%       if ( $e->{type} eq 'file' ) {
    <li><a href="<%= "$e->{name}.html" %>"><%= $e->{name} %></a></li>
%       } else {
    <li><a href="<%= "$e->{name}/" %>"><%= $e->{name} %></a></li>
%       }
%   }
</ul>
% } else {
<p>Here is nothing.</p>
% }

@@ not_found.html.ep
% layout 'wrapper';
% stash title => 'Error 404: Resource not found!';
<h1><%= stash 'title' %></h1>
<p>The resource you requested
(<code><%= $self->req->url->to_abs %></code>)
could not be found. Sorry!</p>

@@ exception.html.ep
<!doctype html>
<html><head><title>Exception</title></head>
<body><h1>Exception</h1><pre class="exception"><%= $exception %></pre></body>

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

