#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec::Functions qw/catfile/;
use File::Path;
use File::Copy;

use App::VimSw;

use Test::More tests => 1;
use Test::File;
use Test::Exception;

sub fetch_current_profile {
    my ($file) = @_;

    open( my $fh, '<', $file ) or die "$!\n";
    my $profile = readline($fh);
    close($fh);

    chomp($profile);
    return $profile;
}

sub unlink_already_exists_file {
    my ($path) = @_;

    if ( -e $path ) {
        rmtree $path or die "$!\n";
    }
}

sub initialize {
    my ( $profile_file, $from, $to ) = @_;

    open( my $fh, '>', $profile_file ) or die "$!\n";
    print $fh 'default';
    close($fh);

    my $target_vim_dir = catfile( $to, '.vim' );
    my $target_vimrc   = catfile( $to, '.vimrc' );
    unlink_already_exists_file($target_vim_dir);
    unlink_already_exists_file($target_vimrc);

    symlink catfile( $from, '.vim' ),   $target_vim_dir or die "$!\n";
    symlink catfile( $from, '.vimrc' ), $target_vimrc   or die "$!\n";
}

subtest 'Execute switch' => sub {
    $ENV{HOME} = catfile( $FindBin::Bin, 'resource', 'switch_test' );
    my $vimsw_dir    = catfile( $ENV{HOME}, '.vimsw' );
    my $home_vim     = catfile( $ENV{HOME}, '.vim' );
    my $home_vimrc   = catfile( $ENV{HOME}, '.vimrc' );

    my $profile_file      = catfile( $vimsw_dir, '.vimsw_profile' );
    my $orig_profile_file = catfile( $vimsw_dir, '.vimsw_profile.orig' );
    rmtree($profile_file) if (-f $profile_file);
    File::Copy::copy( $orig_profile_file, $profile_file );

    my $default_profile = 'default';
    initialize( $profile_file, catfile( $vimsw_dir, $default_profile ),
        $ENV{HOME} );


    my $current_profile = fetch_current_profile($profile_file);

    is $current_profile, 'default', 'Initial profile name should be "default".';
    symlink_target_exists_ok(
        $home_vim,
        catfile( $ENV{HOME}, '.vimsw', $current_profile, '.vim' ),
        'Does it point default .vim?'
    );
    symlink_target_exists_ok(
        $home_vimrc,
        catfile( $ENV{HOME}, '.vimsw', $current_profile, '.vimrc' ),
        'Does it point default .vimrc?'
    );

    my $new_profile = 'jackson';
    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->switch($new_profile);
    $current_profile = fetch_current_profile($profile_file);

    is $current_profile, 'jackson',
      'Switched profile name should be "jackson".';
    symlink_target_exists_ok(
        $home_vim,
        catfile( $ENV{HOME}, '.vimsw', $current_profile, '.vim' ),
        'Does it point jackson .vim?'
    );
    symlink_target_exists_ok(
        $home_vimrc,
        catfile( $ENV{HOME}, '.vimsw', $current_profile, '.vimrc' ),
        'Does it point jackson .vimrc?'
    );

    dies_ok{ $app->switch() };
    dies_ok{ $app->switch('Not-Exits-Name') };
};

done_testing;
