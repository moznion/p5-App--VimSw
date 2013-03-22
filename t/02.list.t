#!perl

use strict;
use warnings;
use utf8;

use FindBin;
use File::Spec::Functions qw/catfile/;
use App::VimSw;

use Test::More tests => 1;

subtest 'Execute list' => sub {
    my $vimsw_dir = catfile( $FindBin::Bin, 'resource', 'list_test', '.vimsw' );
    my $app = App::VimSw->new( $vimsw_dir, \%ENV );
    my $expected = [ 'default', 'jackson', 'user01' ];
    @$expected = sort @$expected;
    my $got = $app->run('list');
    is_deeply $got, $expected;
};

done_testing;
