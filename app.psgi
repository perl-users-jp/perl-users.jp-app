use 5.13.7;
use common::sense;
use lib 'lib';
use PerlUsersJp;

use Path::Class;
use Plack::Builder;

my $conf = do 'config.pl' or
            die "please run 'cp config.pl.sample config.pl' and edit config.pl";

my $app = PerlUsersJp->new( config => $conf );

my $static_root = dir($conf->{document_root})->subdir('static');
my $file = Plack::App::File->new({ root => $static_root });

builder {
    enable 'Static', path => qr{^/(?:img|css|js)/}, root => $static_root;
    enable 'ReverseProxy';
    $app->code;
};
