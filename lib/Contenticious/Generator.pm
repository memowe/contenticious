package Contenticious::Generator;
use Mojo::Base 'Mojolicious::Command';

# store everything in files
sub init {
    my $self = shift;
    $self->generate_config_file;
    $self->generate_web_app;
    $self->generate_example_pages;
    $self->generate_public_directory;
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

sub generate_public_directory {
    my $self   = shift;
    my @public = qw(styles.css);
    $self->render_to_rel_file(("public/$_") x 2) for @public;
}

1;

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

=head2 C<generate_public_directory>

Generates I<public>.

=head2 C<init>

Generates everything from above.

=head1 SEE ALSO

L<Contenticious>
