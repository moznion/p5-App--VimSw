#!perl

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::VimSw' );
}

diag( "Testing App::VimSw $App::VimSw::VERSION" );
done_testing;
