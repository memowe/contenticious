#!/usr/bin/env perl

BEGIN { use FindBin; use lib "$FindBin::Bin/mojo/lib" }

use Mojolicious::Lite;
use Mojo::Asset::File;
use Mojo::Command;
use Text::Markdown qw( markdown );
use List::Util qw( first );
use File::Copy::Recursive qw( dircopy );

# build the content tree as a LoHoLoH...
# realized as a sub to get changed content immediately
sub content_tree {
    my $dirname = shift || app->home->rel_dir('pages');
    my @tree    = ();

    for ( sort glob("$dirname/*") ) {

        # content file
        if ( /([\w_-]+)\.md$/ and -f and -r ) {
            ( my $name = $1 ) =~ s/^(\d+_)?//; # drop sort prefix

            my $file    = Mojo::Asset::File->new( path => $_ );
            my $content = $file->slurp;
            my %meta    = ();
            $meta{lc $1} = $2 while $content =~ s/\A(\w+):\s*(.*)[\n\r]+//;

            push @tree, {
                name        => $name,
                filename    => $_,
                type        => 'file',
                meta        => \%meta,
                content     => $content,
                html        => markdown( $content ),
            };

            next;
        }

        #content directory
        if ( /([\w_-]+)$/ and -d and -r and -x ) {
            ( my $name = $1 ) =~ s/^(\d+_)?//; # drop sort prefix

            my %meta    = ();
            my $metafn  = "$_/meta";
            if ( -f $metafn and -r $metafn ) {
                my $mfc = Mojo::Asset::File->new( path => $metafn )->slurp;
                $meta{lc $1} = $2 while $mfc =~ s/\A(\w+):\s*(.*)[\n\r]+//;
            }

            my $content = content_tree($_);

            push @tree, {
                name        => $name,
                filename    => $_,
                type        => 'dir',
                meta        => \%meta,
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

# traverse the content_tree and execute a given sub on each data hash
# this sub gets the data hash and also a path to that data like foo/bar/baz
sub walk_content_tree {
    my ( $sub, $tree, $prefix ) = @_;
    $tree   ||= content_tree;
    $prefix ||= '';

    foreach my $data ( @$tree ) {

        my $ext = $data->{type} eq 'dir' ? '/' : '.html';
        $sub->( $data, "$prefix/$data->{name}$ext" );

        walk_content_tree( $sub, $data->{content}, "$prefix/$data->{name}" )
            if $data->{type} eq 'dir' and defined $data->{content};
    }
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

    my $title = defined $entry->{meta}{title} ? $entry->{meta}{title}
                : $entry->{html} =~ m|<h1>(.*?)</h1>| ? $1
                : $names[-1];

    $self->stash(
        title           => $title,
        content_tree    => $content_tree,
        template        => 'layouts/wrapper',
    );
    $self->render_inner( content => $entry->{html} );

} => 'content';

# serve managed directories
get '(*path)/$' => [ path => qr([/\w_-]*) ] => sub {
    my $self    = shift;
    my $path    = $self->stash('path') || '';
    my @names   = grep { $_ } split m|/| => $path;
    my ( $entry, $content_tree ) = active_content( @names );

    # /
    $entry = {
        content     => $content_tree,
        type        => 'dir',
        name        => 'Index',
    } unless @names;

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

# command line commands
if ( my $command = $ARGV[0] ) {

    my $cmd = Mojo::Command->new;

    # extract the inline templates into 'templates'
    if ( $command eq 'templates' ) {

        $cmd->create_rel_dir('templates');
        my @names = qw( layouts/wrapper navi directory not_found exception );

        foreach my $template ( @names ) {
            my $data = $cmd->get_data( "$template.html.ep", 'main' );
            $cmd->write_rel_file( "templates/$template.html.ep", $data );
        }

        exit 0;
    }
    
    # generate static html in 'static' from the pages
    if ( $command eq 'dump' ) {

        my $client = app->client->app(app); # D'oh
        app->log->level('error');

        walk_content_tree( sub {
            my ( $data, $path ) = @_;

            $client->get( $path => sub {
                my ( $self, $tx ) = @_;
                my $filename = "static$path";

                # no index.html found
                $filename .= 'index.html' unless $path =~ /\.html$/;

                $cmd->write_rel_file( $filename, $tx->res->body );
            });
        });

        $client->process();

        # now get the static stuff from public
        dircopy( 'public', 'static' );
        print "Files from 'public' copied\n";

        exit 0;
    }
}

shagadelic( $ARGV[0] || 'daemon' );

__DATA__

@@ layouts/wrapper.html.ep
<!doctype html>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <title><%= $title || 'contenticious!' %></title>
</head>
<link rel="stylesheet" type="text/css" href="/screen.css" media="screen">
<link rel="stylesheet" type="text/css" href="/print.css" media="print">
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
% my $level = 0;
% while ( $tree ) {
%   my $list = $tree;
%   undef $tree;
%   my $pre = $prefix;
%   last unless @$list;
<ul class="navi navilevel<%= $level %>">
%   for ( @$list ) {
%       my $class   = $_->{active} ? ' class="active"' : '';
%       my $ext     = $_->{type} eq 'file' ? '.html' : '/';
%       my $name    = $_->{meta}{navi} ? $_->{meta}{navi} : $_->{name};
    <li<%== $class %>>
        <a href="<%== "$pre/$_->{name}$ext" %>"><%= $name %></a>
    </li>
%       if ( $_->{active} and $_->{type} eq 'dir' ) {
%           $tree = $_->{content};
%           $prefix .= "/$_->{name}";
%       }
%   }
</ul>
%   $level++;
% }
</div>

@@ directory.html.ep
% layout 'wrapper';
% stash title => $entry->{name};
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
