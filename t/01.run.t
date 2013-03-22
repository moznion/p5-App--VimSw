#!perl

use strict;
use warnings;
use utf8;

use App::VimSw;

use Test::More tests => 5;
use Test::MockObject::Extends;
use Test::Exception;

# command equals function name.
# This application supports the following commands.
#   - init
#   - list
#   - switch
#   - create

sub common_test {
    my ($command) = @_;

    my $app = App::VimSw->new( undef, \%ENV );
    can_ok( $app, $command );

    my $app_mock = Test::MockObject::Extends->new($app);
    $app_mock->mock(
        $command,
        sub {
            return $command;
        }
    );
    is $app_mock->run($command), $command, "It can execute $command()";
}

subtest 'Run with init' => sub {
    common_test('init');
};

subtest 'Run with list' => sub {
    common_test('list');
};

subtest 'Run with switch' => sub {
    common_test('switch');
};

subtest 'Run with create' => sub {
    common_test('create');
};

# Exceptional
subtest 'Run with not_exists_function' => sub {
    my $app = App::VimSw->new( undef, \%ENV );
    dies_ok { $app->run('not_exists_function') };
};

done_testing;
