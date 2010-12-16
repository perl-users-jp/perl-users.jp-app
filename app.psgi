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

builder {
    enable 'Static', path => qr{^/(?:img|css|js)/}, root => $static_root;
    while (my($path, $root) = each %{ $conf->{static_maps} || {} }) {
        enable 'Static', path => $path, root => $root;
    }
    enable 'ReverseProxy';
    $app->code;
};
