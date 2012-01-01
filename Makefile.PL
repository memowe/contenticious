use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME        => 'contenticious',
    VERSION     => '0.2',
    AUTHOR      => 'Mirko Westermeier <mail@memowe.de>',
    EXE_FILES   => ['contenticious.pl'],
    PREREQ_PM   => {
        'Mojolicious'           => '2.0'
        'Text::Markdown'        => 0,
        'List::Util'            => 0,
        'File::Copy::Recursive' => 0,
    },
    test        => {TESTS => 't/*.t'}
);
