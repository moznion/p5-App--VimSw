#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Path;
use File::Spec::Functions qw/catfile/;

use App::VimSw;

use Test::More tests => 1;
use Test::File;

subtest 'Execute create' => sub {
    my $vimsw_dir = catfile( $FindBin::Bin, 'create_test', '.vimsw' );
    rmtree($vimsw_dir) if -d $vimsw_dir;
    mkpath $vimsw_dir or die "$!\n";

    my $profile = 'Luke';
    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    $app->create($profile);

    my $luke_dir = catfile( $vimsw_dir, 'Luke' );
    dir_exists_ok( catfile( $luke_dir, '.vim' ) );
    file_exists_ok( catfile( $luke_dir, '.vimrc' ) );

    is $app->create, undef, 'Not specified the profile name';
    is $app->create($profile), undef, 'Specify duplicated profile name';
};

done_testing;
