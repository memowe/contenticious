use strict;
use warnings;
use 5.10.0;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME        => 'contenticious',
    VERSION     => '0.2',
    AUTHOR      => 'Mirko Westermeier <mail@memowe.de>',
    EXE_FILES   => ['contenticious.pl'],
    PREREQ_PM   => {
        'Mojolicious'           => '2.4',
        'Carp'                  => 0,
        'File::Basename'        => 0,
        'Text::Markdown'        => 0,
        'List::Util'            => 0,
        'File::Copy::Recursive' => 0,
        'File::Path'            => 0,
    },
    test        => {TESTS => 't/*.t'}
);
