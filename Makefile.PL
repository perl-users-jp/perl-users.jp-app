use 5.13.7;
use inc::Module::Install;
name 'PerlUsersJp';
all_from 'lib/PerlUsersJp.pm';

requires 'common::sense';
requires 'Path::Class';
requires 'Plack';
requires 'Router::Simple';
requires 'Text::Xslate' => '0.3001';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
WriteAll;
