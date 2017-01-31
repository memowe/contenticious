# Contenticious [![Build Status](https://travis-ci.org/memowe/contenticious.svg?branch=master)](https://travis-ci.org/memowe/contenticious)

Contenticious is a simple way to build a pretty simple website from Markdown content. It includes a helper script which will create example pages and directories for you to get you started in no time. With one single command Contenticious will create static HTML ready for upload. It's also possible to mount Contenticious in existing Mojolicious web apps.

See [memowe.github.com/contenticious](http://memowe.github.com/contenticious) for an introduction.

## Prerequisites

    - perl 5.10.1
    - File::Copy::Recursive 0.38
    - Mojolicious 7.0
    - Mojolicious::Plugin::Subdispatch 0.04
    - Mojolicious::Plugin::RelativeUrlFor 0.052
    - Text::Markdown 1.000031

## Installation

This distribution is available on CPAN. You can install it like any other CPAN module via

    $ cpan Contenticious

or

    $ cpanm Contenticious

See their documentation for details. To install it manually, download the dist tarball or clone the git repository and execute the following standard procedure:

    $ cpanm --installdeps --notest .
    $ perl Makefile.PL
    $ make
    $ make test
    $ make install

It's possible to use this module from inside of its dist directory without installation.

## Documentation

After installation you can access the main documentation with this command:

    $ perldoc Contenticious

It's possible to [view the same file without installing Contenticious](https://github.com/memowe/contenticious/blob/master/lib/Contenticious.pod).

## Author and License

Copyright (c) [Mirko Westermeier](https://github.com/memowe), [mirko@westermeier.de](mailto:mirko@westermeier.de).

Credits:

- [Joel Berger](https://github.com/jberger)
- [John Hall](https://github.com/dancingfrog)
- [Stephan Jauernick](https://github.com/stephan48)
- [Keedi Kim](https://github.com/keedi)
- [Joan Pujol Tarrés](https://github.com/mimosinnet)
- [Maxim Vuets](https://github.com/mvuets)

Thank you for your contributions!

Published under the MIT license. See MIT-LICENSE.
