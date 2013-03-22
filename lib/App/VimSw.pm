package App::VimSw;

use strict;
use warnings;
use utf8;
use Carp;
use Cwd qw/abs_path/;
use File::Spec::Functions qw/catfile/;
use File::Copy;
use File::Path;

our $VERSION = '0.0.1';

sub new {
    my ( $class, $vimsw_dir, $env ) = @_;
    bless {
        vimsw_dir     => $vimsw_dir,
        vimsw_profile => catfile( $vimsw_dir, '.vimsw_profile' ),
        env           => $env,
    }, $class;
}

sub run {
    my ( $self, @args ) = @_;

    my $command = shift @args;
    my $result = eval { $self->$command(@args) };
    croak "$@" if $@;    # FIXME change error message

    return $result;
}

sub init {
    my ($self) = @_;
    my $profile = 'default';

    print "Initializing...\n";

    # Make root directory for VimSw
    my $status = mkpath( catfile( $self->{vimsw_dir}, $profile ) );
    unless ($status) {
        print STDERR "Already initialized.\n";
        return;
    }

    $self->_swap_symlink_for_entity( '.vim',   $profile );
    $self->_swap_symlink_for_entity( '.vimrc', $profile );

    $self->_rewrite_profile_file($profile);

    print "Initialized!\n";
}

sub list {
    my ($self) = @_;

    my $profiles = $self->_fetch_profiles_list( $self->{vimsw_dir} );

    open( my $fh, '<', $self->{vimsw_profile} )
      or die "Cannot open '$self->{vimsw_profile}': $!\n";
    my $current = readline($fh);
    close($fh);

    chomp($current);
    @$profiles = sort @$profiles;
    foreach my $profile (@$profiles) {
        if ( $profile eq $current ) {
            print '=>';
        }
        else {
            print '  ';
        }
        print "$profile\n";
    }
    print "\n=> : Current Profile\n";

    return $profiles;
}

sub switch {
    my ( $self, $profile ) = @_;

    unless ($profile) { # Duplicated
        print STDERR "Please specify the profile name\n";
        print STDERR "Usage: \$ vimsw switch [profile name]\n";
        return;
    }

    my $profiles = $self->_fetch_profiles_list( $self->{vimsw_dir} );
    my %profiles;
    $profiles{$_} = 1 for @$profiles;
    unless ( defined $profiles{$profile} ) {
        print STDERR "'$profile' does not exist.\n";
        return;
    }

    # Rewrite current profile state
    open( my $fh, '>', $self->{vimsw_profile} );
    print $fh $profile;
    close($fh);

    my $home_vim   = catfile( $self->{env}->{HOME}, '.vim' );
    my $home_vimrc = catfile( $self->{env}->{HOME}, '.vimrc' );
    my $vimsw_vim   = catfile( $self->{vimsw_dir}, $profile, '.vim' );
    my $vimsw_vimrc = catfile( $self->{vimsw_dir}, $profile, '.vimrc' );

    $self->_unlink_already_exests_one($home_vim);
    $self->_unlink_already_exests_one($home_vimrc);

    symlink $vimsw_vim,   $home_vim   or die "$!\n";
    symlink $vimsw_vimrc, $home_vimrc or die "$!\n";
}

sub create {
    my ( $self, $profile ) = @_;

    unless ($profile) { #Duplicated
        print STDERR "Please specify the profile name\n";
        print STDERR "Usage: \$ vimsw create [profile name]\n";
        return;
    }

    my $profile_dir = catfile( $self->{vimsw_dir}, $profile );

    my $status = mkpath( catfile($profile_dir) );
    unless ($status) {
        print STDERR "'$profile' already exists.\n";
        return;
    }

    mkpath( catfile( $profile_dir, '.vim' ) );
    open( my $fh, '>', catfile( $profile_dir, '.vimrc' ) ); # <= like `touch .vimrc`
    close($fh);

    print "Create the profile as '$profile'\n";
}

sub _unlink_already_exests_one {
    my ( $self, $path ) = @_;

    if ( -e $path ) {
        unlink $path or die "$!\n";
    }
}

sub _rewrite_profile_file {
    my ( $self, $profile_name ) = @_;

    open( my $fh, '>', $self->{vimsw_profile} )
      or die "Cannot open '$self->{vimsw_profile}': $!\n";
    print $fh $profile_name;
    close($fh);
}

sub _swap_symlink_for_entity {
    my ( $self, $file, $profile ) = @_;

    my $home_side = catfile( $self->{env}->{HOME}, $file );
    my $vimsw_side = catfile( $self->{vimsw_dir}, $profile, $file );

    if ( -l $home_side ) {
        symlink abs_path($home_side), $vimsw_side or die "$!\n";
        unlink $home_side or die "$!\n";
    }
    else {
        move $home_side, $vimsw_side or die "$!\n";   # Entity goes to ".vimsw".
    }

    symlink $vimsw_side, $home_side
      or die $!;  # Make symlink on home directory. It refers the moved entity.
}

sub _update_symlink {
    my ($self) = @_;
}

sub _fetch_profiles_list {
    my ( $self, $dir_location ) = @_;

    opendir my $dh, $dir_location or die "Cannot open $dir_location: $!";
    my @directories =
      grep { $_ !~ /^\.\.?$/ && -d catfile( $dir_location, $_ ) } readdir($dh);
    close($dh);

    return \@directories;
}

1;
__END__

=encoding utf8

=head1 NAME

vimsw - Profile switcher for Vim


=head1 VERSION

This document describes vimsw version 0.0.1


=head1 SYNOPSIS

    $ vimsw [command] ([argument(s)])

    Commands:
        init                   Initialize the environment
        list                   Show the Vim profiles
        create [profile name]  Create a empty Vim profile
        switch [profile name]  Switch to the specified Vim profile

    Example:
        $ vimsw init           # Initialize
        $ vimsw list           # Show profiles list
        $ vimsw create scott   # Create the vim profile of "scott"
        $ vimsw switch scott   # Switch the vim profile to "scott"


=head1 DESCRIPTION

vimsw is the profile switcher for Vim.

This application can switch each profiles and create profiles.


=head1 DEPENDENCIES

Test::File (version 1.34 or later)

Test::Exception (version 0.31 or later)

Test::MockObject::Extends (version 1.20120301 or later)


=head1 BUGS AND LIMITATIONS

No bugs have been reported.


=head1 AUTHOR

moznion  C<< <moznion@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, moznion C<< <moznion@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
