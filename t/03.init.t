#!perl

use strict;
use warnings;
use utf8;

use FindBin;
use File::Copy;
use File::Spec::Functions qw/catfile/;
use File::Path;

use App::VimSw;

use Test::More tests => 2;
use Test::File;

sub move_to_home {
    my ( $app, $file ) = @_;

    move catfile( $app->{vimsw_dir}, 'default', $file ),
      catfile( $app->{env}->{HOME}, $file )
      or die $!;
}

sub tear_down {
    my ( $app, $init_test_dir ) = @_;

    unlink catfile( $app->{env}->{HOME}, '.vim' );
    unlink catfile( $app->{env}->{HOME}, '.vimrc' );
    move_to_home( $app, '.vim' );
    move_to_home( $app, '.vimrc' );
    rmtree($init_test_dir);
}

my $init_test_dir       = catfile( $FindBin::Bin,  'resource', 'init_test' );
my $vimsw_dir           = catfile( $init_test_dir, '.vimsw' );
my $default_profile_dir = catfile( $vimsw_dir,     'default' );
my $vimsw_profile       = catfile( $vimsw_dir,     '.vimsw_profile' );
my $vim_dir = catfile( $default_profile_dir, '.vim' );
my $vimrc   = catfile( $default_profile_dir, '.vimrc' );

subtest 'Execute init' => sub {
    $ENV{HOME} = catfile( $FindBin::Bin, 'resource', 'resource_init_test' );

    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->init;

    dir_exists_ok($vimsw_dir);
    dir_exists_ok($vim_dir);
    file_exists_ok($vimrc);
    file_exists_ok($vimsw_profile);
    symlink_target_exists_ok( catfile( $ENV{HOME}, '.vim' ),   $vim_dir );
    symlink_target_exists_ok( catfile( $ENV{HOME}, '.vimrc' ), $vimrc );

    tear_down( $app, $init_test_dir );
};

subtest 'Execute init with symlink' => sub {
    $ENV{HOME} =
      catfile( $FindBin::Bin, 'resource', 'resource_init_test', 'symlink' );

    rmtree( $ENV{HOME} ) if -d $ENV{HOME};
    mkdir $ENV{HOME};

    my $resource = catfile( $FindBin::Bin, 'resource', 'resource_init_test' );
    symlink catfile( $resource, '.vim' ), catfile( $ENV{HOME}, '.vim' )
      or die "$!\n";
    symlink catfile( $resource, '.vimrc' ), catfile( $ENV{HOME}, '.vimrc' )
      or die "$!\n";

    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->init;

    dir_exists_ok($vimsw_dir);
    symlink_target_exists_ok( $vim_dir, catfile( $resource, '.vim' ) );
    symlink_target_exists_ok( $vimrc,   catfile( $resource, '.vimrc' ) );
    file_exists_ok($vimsw_profile);
    symlink_target_exists_ok( catfile( $ENV{HOME}, '.vim' ),   $vim_dir );
    symlink_target_exists_ok( catfile( $ENV{HOME}, '.vimrc' ), $vimrc );

    is $app->init, undef, 'Already initialized';

    tear_down( $app, $init_test_dir );
};

done_testing;
