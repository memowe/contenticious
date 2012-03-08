use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Contenticious',
    VERSION_FROM    => 'lib/Contenticious.pm',
    AUTHOR          => 'Mirko Westermeier <mail@memowe.de>',
    EXE_FILES       => ['contenticious'],
    MIN_PERL_VERSION    => '5.10.1',
    PREREQ_PM       => {

        # core modules since 5.10
        'Carp'                                  => '1.08',
        'File::Basename'                        => '2.76',
        'File::Path'                            => '2.04',
        'FindBin'                               => '1.49',
        'List::Util'                            => '1.19',

        # non-trivial dependencies
        'File::Copy::Recursive'                 => '0.38',
        'Mojolicious'                           => '2.4',
        'Mojolicious::Plugin::Subdispatch'      => '0.02',
        'Mojolicious::Plugin::RelativeUrlFor'   => '0.01',
        'Text::Markdown'                        => '1.000031',
    },
    test            => {TESTS => 't/*.t'}
);
