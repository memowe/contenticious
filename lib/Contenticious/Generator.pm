package Contenticious::Generator;
use Mojo::Base -base;

use File::Basename;
use File::Spec::Functions; # catdir, catfiles
use File::Share 'dist_dir';
use FindBin;
use File::Path 'make_path';
use File::Copy;

has share_directory     => dist_dir 'Contenticious';
has working_directory   => $FindBin::Bin;

has files => sub{[
    catfile(qw(config)),
    catfile(qw(webapp.pl)),
    catfile(qw(public css bootstrap.css)),
    catfile(qw(public js bootstrap.js)),
    catfile(qw(public js jquery.js)),
    catfile(qw(pages index.md)),
    catfile(qw(pages 01_Perldoc.md)),
    catfile(qw(pages 02_About.md)),
]};

has is_executable => sub {{
    catfile(qw(webapp.pl)) => 1,
}};

sub _file_location {
    my ($self, $filename) = @_;

    # check
    return unless grep {$_ eq $filename} @{$self->files};

    # concatenate
    return catfile $self->share_directory, $filename;
}

# store everything in files
sub generate {
    my $self = shift;
    $self->generate_file($_) for @{$self->files};
}

# store a an asset in a file
sub generate_file {
    my ($self, $filename) = @_;

    # check requested file name
    my $source = $self->_file_location($filename);
    die "Unknown file: '$filename'!\n" unless defined $source;

    # determine path
    my $target = catfile $self->working_directory, $filename;

    # create directory if neccessary
    my $target_dir = dirname $target;
    make_path $target_dir unless -d $target_dir;

    # dump file
    copy $source => $target;

    # chmod executable if neccessary
    chmod oct(755) => $target if $self->is_executable($filename);
}

1;

__END__

=head1 NAME

Contenticious::Generator - generates contenticious boilerplate

=head1 SYNOPSIS

    use Contenticious::Generator;
    my $generator = Contenticious::Generator->new;
    $generator->generate;

=head1 DESCRIPTION

The generator builds a basic file-system structure for Contenticious

=head1 ATTRIBUTES

Contenticious::Generator inherits all L<Mojolicious::Command> attributes
and implements the following new ones:

=head2 C<share_directory>

The directory to read files from.

=head2 C<files>

A list of files the Generator tries to generate.

=head1 METHODS

Contenticious::Generator inherits all L<Mojolicious::Command> methods
and implements the following new ones:

=head2 C<generate>

Generates builds a basic file-system structure for Contenticious.

=head2 C<generate_file>

Generates a single file if it is known to Contenticious.

=head1 SEE ALSO

L<Contenticious>
