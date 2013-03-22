#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Basename qw/dirname/;
use File::Path;
use File::Spec::Functions qw/catfile/;

use App::VimSw;

use Test::More tests => 1;
use Test::File;
use Test::Exception;

subtest 'Execute create' => sub {
    my $vimsw_dir = catfile( $FindBin::Bin, 'resource', 'create_test', '.vimsw' );
    rmtree(dirname($vimsw_dir)) if -d $vimsw_dir;
    mkpath $vimsw_dir or die "$!\n";

    my $profile = 'Luke';
    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->create($profile);

    my $luke_dir = catfile( $vimsw_dir, 'Luke' );
    dir_exists_ok( catfile( $luke_dir, '.vim' ) );
    file_exists_ok( catfile( $luke_dir, '.vimrc' ) );

    dies_ok{ $app->create() };
    dies_ok{ $app->create($profile) };
};

done_testing;
