use strict;
use warnings;
use 5.10.0;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'contenticious',
    VERSION_FROM    => 'lib/Contenticious.pm',
    AUTHOR          => 'Mirko Westermeier <mail@memowe.de>',
    EXE_FILES       => ['contenticious'],
    PREREQ_PM       => {
        'Carp'                                  => 0,
        'File::Basename'                        => 0,
        'File::Copy::Recursive'                 => 0,
        'File::Path'                            => 0,
        'FindBin'                               => 0,
        'List::Util'                            => 0,
        'Mojolicious'                           => '2.4',
        'Mojolicious::Plugin::Subdispatch'      => '0.02',
        'Mojolicious::Plugin::RelativeUrlFor'   => '0.01',
        'Text::Markdown'                        => 0,
    },
    test            => {TESTS => 't/*.t'}
);
