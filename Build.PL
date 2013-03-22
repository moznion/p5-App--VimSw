use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    name              => 'App-VimSw',
    module_name       => 'App::VimSw',
    script_files      => ['vimsw'],
    license           => 'perl',
    dist_author       => 'moznion <moznion@gmail.com>',
    dist_version_from => 'lib/App/VimSw.pm',
    build_requires    => {
        'Test::More'                => '0.98',
        'Test::MockObject::Extends' => '1.20120301',
        'Test::Exception'           => '0.31',
        'Test::File'                => '1.34',
        'FindBin'                   => 0,
        'File::Copy'                => 0,
        'File::Path'                => 0,
        'File::Spec::Functions'     => 0,
    },
    configure_requires => { 'Module::Build' => '0.40' },
    requires           => {
        perl   => '5.008004',
        'Carp' => 0,
        'Cwd'  => 0,
    },
    no_index   => { 'directory' => ['inc'] },
    meta_merge => {
        'resources' => {
            'license'    => 'http://dev.perl.org/licenses/',
            'repository' => 'git://github.com/moznion/App--VimSw.git',
        },
    },
    test_files => ( -d '.git' || $ENV{RELEASE_TESTING} ) ? 't/ xt/' : 't/',
    recursive_test_files => 1,
    add_to_cleanup       => ['App-VimSw-*'],
    create_license       => 1,
    create_readme        => 1,
);

$builder->create_build_script();
