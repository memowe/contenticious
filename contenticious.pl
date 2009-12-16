#!/usr/bin/env perl

BEGIN { use FindBin; use lib "$FindBin::Bin/mojo/lib" }

use Mojolicious::Lite;
use Text::Markdown qw( markdown );
use Mojo::File;

app->renderer->add_helper( stash => sub { shift->stash(@_) } );

# serve managed content
get '/(*path).html' => sub {
    my $self = shift;
    my $path = $self->stash('path');
    
    if ( $path =~ /\.\./ ) {
        $self->stash(
            exception   => 'Path not allowed: ' . $path,
            template    => 'exception',
        );
        return 1;
    }
    
    unless ( -r "$FindBin::Bin/pages/$path.md" ) {
        $self->render(
            template    => 'not_found',
            format      => 'html',
            status      => 404,
        );
        return 1;
    }

    my $file    = Mojo::File->new( path => "pages/$path.md" );
    my $html    = markdown( $file->slurp );
    my $title   = $html =~ m|<h1>(.*?)</h1>| ? $1 : ( split m|/| => $path )[-1];

    $self->stash(
        title   => $title,
        html    => $html,
    );

} => 'content';

# .../
get '(*path)/' => sub {
    my $self = shift;
    my $path = $self->stash('path');
    
} => 'multiple_choice';

shagadelic('daemon');

__DATA__

@@ content.html.ep
% layout 'wrapper';
<div id="content">
%== $html
</div>

@@ layouts/wrapper.html.ep
% $self->res->headers->content_type( 'text/html; charset: utf-8' );
<!doctype html>
<html>
<head><title><%= $title || 'contenticious!' %></title></head>
<body>
%== content
</body>
</html>

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

    $ perl contenticious daemono

=head1 DESCRIPTION

Whoops! No documentation found!

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

