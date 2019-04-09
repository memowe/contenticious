use 5.010001;

use strict;
use warnings;

use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share dist => 'share';

WriteMakefile(
    NAME                => 'Contenticious',
    VERSION_FROM        => 'lib/Contenticious.pm',
    ABSTRACT            => 'build web sites from markdown files',
    AUTHOR              => 'Mirko Westermeier <mail@memowe.de>',
    LICENSE             => 'mit',
    META_MERGE          => {
        resources   => {
            homepage    => 'http://memowe.github.com/contenticious/',
            bugtracker  => 'http://github.com/memowe/contenticious/issues',
            repository  => 'http://github.com/memowe/contenticious',
        },
    },
    MIN_PERL_VERSION    => '5.10.1',
    PREREQ_PM           => {

        # core modules since 5.10
        'Carp'                                  => '1.08',
        'Cwd'                                   => '3.62',
        'File::Basename'                        => '2.76',
        'File::Copy'                            => '2.11',
        'File::Path'                            => '2.04',
        'File::Spec'                            => '3.62',
        'FindBin'                               => '1.49',
        'List::Util'                            => '1.19',

        # non-trivial dependencies
        'File::Copy::Recursive'                 => '0.38',
        'File::Share'                           => '0.25',
        'Mojolicious'                           => '8.05',
        'Mojolicious::Plugin::AssetPack'        => '1.45',
        'Mojolicious::Plugin::PODViewer'        => '0.004',
        'Mojolicious::Plugin::RelativeUrlFor'   => '0.052',
        'Mojolicious::Plugin::Subdispatch'      => '0.04',
        'Text::Markdown'                        => '1.000031',
    },
    EXE_FILES           => ['contenticious'],
    test                => {TESTS => 't/*.t'}
);

package MY;
use File::ShareDir::Install 'postamble';
