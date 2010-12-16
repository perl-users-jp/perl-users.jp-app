use 5.13.7;
use common::sense;
use lib 'lib';
use PerlUsersJp;

use Path::Class;
use Plack::Builder;

my $conf = do 'config.pl' or
            die "please run 'cp config.pl.sample config.pl' and edit config.pl";

my $app = PerlUsersJp->new( config => $conf );

builder {
    while (my($path, $root) = each %{ $conf->{static_maps} || {} }) {
        enable 'Static', path => $path, root => $root;
    }
    enable 'ReverseProxy';
    $app->code;
};
