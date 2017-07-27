package Contenticious::Generator;
use Mojo::Base 'Mojolicious::Command';

# store everything in files
sub init {
    my $self = shift;
    $self->generate_config_file;
    $self->generate_web_app;
    $self->generate_example_pages;
}

sub generate_config_file {
    shift->render_to_rel_file(config => 'config');
}

sub generate_web_app {
    my $self = shift;
    $self->render_to_rel_file('webapp.pl' => 'webapp.pl');
    $self->chmod_rel_file('webapp.pl' => oct(755));
}

sub generate_example_pages {
    my $self  = shift;
    my @pages = qw(index.md 01_Perldoc.md 02_About.md);
    $self->render_to_rel_file(("pages/$_") x 2) for @pages;
}

1;

__DATA__

@@ config
{
    pages_dir   => app->home->rel_file('pages'),
    dump_dir    => app->home->rel_file('dump'),
    name        => 'This is Contenticious.',
    copyright   => 'Zaphod Beeblebrox',
    cached      => 0,
    perldoc     => 1,
}

@@ webapp.pl
#!/usr/bin/env perl
use Mojo::Base -strict;

# use local lib (if Contenticious isn't installed)
BEGIN {
    use File::Basename 'dirname';
    my $dir = dirname(__FILE__);
    unshift @INC, "$dir/lib", "$dir/../lib";
}

use Contenticious;
use Contenticious::Commands;
use Mojolicious::Commands;

# use Contenticious
$ENV{MOJO_HOME} = dirname(__FILE__);

# Contenticious dump command
if (defined $ARGV[0] and $ARGV[0] eq 'dump') {
    Contenticious::Commands->new(app => Contenticious->new)->dump;
}

# use Contenticious as mojo app
else {
    Mojolicious::Commands->start_app('Contenticious');
}

@@ pages/index.md
Title: Welcome to Contenticious - build web sites from markdown files

Welcome!
========

**Hi there, Contenticious is working**. This is an example page.
You can find it in your `pages` directory.
It is rendered live from [Markdown][md] to this
nice HTML page together with a simple navigation.

[md]: http://daringfireball.net/projects/markdown/

Possible next steps
-------------------

1. Edit `pages/index.md` to change this file!
1. Read the [introduction perldoc](perldoc/Contenticious).
1. [Customize this!](perldoc/Contenticious#Customize)
1. Read API docs ([perldoc sitemap](Perldoc.html)).
1. Find out [more about Contenticious](About.html).

@@ pages/01_Perldoc.md
title: Contenticious Perldoc Sitemap
navi_name: Perldoc

Contenticious documentation perldocs
====================================

* [Contenticious][app] - a user-friendly introduction. **Start here**!

The following documents are API docs:

* [Contenticious::Content][content] - access content
* [Contenticious::Content::Node][node] - content node base class
    * [Contenticious::Content::Node::File][file] - represents a file
    * [Contenticious::Content::Node::Directory][dir] - represents a directory
* [Contenticious::Commands][commands] - commands like `dump`
* [Contenticious::Generator][generator] - generates boilerplate

After installing Contenticious you can access these documents via the
`perldoc` command:

    $ perldoc Contenticious::Content::Node

[app]:          perldoc/Contenticious
[content]:      perldoc/Contenticious/Content
[node]:         perldoc/Contenticious/Content/Node
[file]:         perldoc/Contenticious/Content/Node/File
[dir]:          perldoc/Contenticious/Content/Node/Directory
[commands]:     perldoc/Contenticious/Commands
[generator]:    perldoc/Contenticious/Generator

@@ pages/02_About.md
title: About Contenticious
navi_name: About

About Contenticious
===================

Contenticious is a small and clean [Mojolicious][mojo] web app with additional
tools to provide a smooth Markdown publishing workflow for you.
It's developed as open source with one of the most free [licenses][license]
(MIT License) to make it really easy for you to get your stuff done.

* [**Follow Contenticious' development on github][repo]**
    There you'll find a bug tracker, a wiki and all sources.

Help testing and improving Contenticious!

[mojo]:     http://mojolicio.us/
[license]:  #license
[repo]:     http://github.com/memowe/contenticious

<h2 id="license">License</h2>

Copyright (c) Mirko Westermeier, <mail@memowe.de>

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

__END__

=head1 NAME

Contenticious::Generator - generates contenticious boilerplate

=head1 SYNOPSIS

    use Contenticious::Generator;
    my $generator = Contenticious::Generator->new;
    $generator->init;

=head1 DESCRIPTION

The generator builds a basic file-system structure for Contenticious

=head1 ATTRIBUTES

Contenticious::Generator inherits all L<Mojolicious::Command> attributes
and implements the following new ones:

None.

=head1 METHODS

Contenticious::Generator inherits all L<Mojolicious::Command> methods
and implements the following new ones:

=head2 C<generate_config_file>

Generates I<config>.

=head2 C<generate_web_app>

Generates I<webapp.pl>.

=head2 C<generate_example_pages>

Generates I<pages>.

=head2 C<init>

Generates everything from above.

=head1 SEE ALSO

L<Contenticious>
