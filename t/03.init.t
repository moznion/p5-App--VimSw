#!perl

use strict;
use warnings;
use utf8;

use FindBin;
use File::Copy::Recursive qw/fcopy dircopy/;
use File::Spec::Functions qw/catfile/;
use File::Path;

use App::VimSw;

use Test::More tests => 2;
use Test::File;

my $init_test_dir = catfile( $FindBin::Bin, 'resource', 'init_test' );
my $vimsw_dir = catfile( $init_test_dir, '.vimsw' );
my $default_profile_dir = catfile( $vimsw_dir,           'default' );
my $vimsw_profile       = catfile( $vimsw_dir,           '.vimsw_profile' );
my $vim_dir             = catfile( $default_profile_dir, '.vim' );
my $vimrc               = catfile( $default_profile_dir, '.vimrc' );

subtest 'Execute init' => sub {
    $ENV{HOME} = $init_test_dir;

    # TODO integrate!
    my $vim_dir_on_home      = catfile( $ENV{HOME}, '.vim' );
    my $vimrc_on_home        = catfile( $ENV{HOME}, '.vimrc' );
    my $orig_vim_dir_on_home = catfile( $ENV{HOME}, '.vim.orig' );
    my $orig_vimrc_on_home   = catfile( $ENV{HOME}, '.vimrc.orig' );
    rmtree($vim_dir_on_home) if ( -e -l $vim_dir_on_home );
    rmtree($vimrc_on_home)   if ( -e -l $vimrc_on_home );
    dircopy( $orig_vim_dir_on_home, $vim_dir_on_home );
    fcopy( $orig_vimrc_on_home, $vimrc_on_home );
    rmtree($vimsw_dir) if ( -d $vimsw_dir );

    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->init();

    dir_exists_ok($vimsw_dir);
    dir_exists_ok($vim_dir);
    file_exists_ok($vimrc);
    file_exists_ok($vimsw_profile);
    symlink_target_exists_ok( $vim_dir_on_home, $vim_dir );
    symlink_target_exists_ok( $vimrc_on_home,   $vimrc );
};

subtest 'Execute init with symlink' => sub {
    $ENV{HOME} = $init_test_dir;

    # TODO integrate!
    my $vim_dir_on_home      = catfile( $ENV{HOME}, '.vim' );
    my $vimrc_on_home        = catfile( $ENV{HOME}, '.vimrc' );
    my $orig_vim_dir_on_home = catfile( $ENV{HOME}, '.vim.orig' );
    my $orig_vimrc_on_home   = catfile( $ENV{HOME}, '.vimrc.orig' );
    rmtree($vim_dir_on_home) if ( -e -l $vim_dir_on_home );
    rmtree($vimrc_on_home)   if ( -e -l $vimrc_on_home );
    rmtree($vimsw_dir)       if ( -d $vimsw_dir );
    symlink $orig_vim_dir_on_home, $vim_dir_on_home or die "$!\n";
    symlink $orig_vimrc_on_home,   $vimrc_on_home   or die "$!\n";

    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->init();

    dir_exists_ok($vimsw_dir);
    symlink_target_exists_ok( $vim_dir, $orig_vim_dir_on_home );
    symlink_target_exists_ok( $vimrc,   $orig_vimrc_on_home );
    file_exists_ok($vimsw_profile);
    symlink_target_exists_ok( $vim_dir_on_home, $vim_dir );
    symlink_target_exists_ok( $vimrc_on_home, $vimrc );

    is $app->init, undef, 'Already initialized';
};

done_testing;
