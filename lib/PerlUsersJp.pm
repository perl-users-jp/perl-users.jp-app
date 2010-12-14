use 5.13.7;
use common::sense;
package PerlUsersJp {
    our $VERSION = '0.01';

    use Plack::Request;
    use Plack::App::File;

    use Encode;
    use Path::Class;
    use Router::Simple;
    use Text::Xslate qw/mark_raw/;

    sub new {
        my($class, %args) = @_;

        my $router = Router::Simple->new;
        $router->connect(
            qr!^.*/$!,
            {
                action => 'index',
            },
        );
        $router->connect(
            qr!^.*\.html$!,
            {
                action => 'html',
            },
        );

        my $file = Plack::App::File->new({ root => dir($args{config}->{document_root})->subdir('static') });

        bless {
            conf   => $args{config},
            file   => $file,
            router => $router,
        }, $class;
    }

    sub code {
        my $self = shift;
        sub {
            my $env = shift;
            my $req = Plack::Request->new($env);
            if ( my $p = $self->{router}->match($env) ) {
                given ($p->{action}) {
                    when ('index') { $self->dispatch_index($req) }
                    when ('html')  { $self->dispatch_html($req) }
                    defaul         { $self->dispatch_file($req->path) }
                }
            } else {
                $self->dispatch_file($req->path);
            }
        };
    }

    sub dispatch_index {
        my($self, $req) = @_;
        my $path = $req->path . 'index.html';
        $self->render_html($req, $path);
    }
    sub dispatch_html {
        my($self, $req) = @_;
        $self->render_html($req, $req->path);
    }
    sub dispatch_file {
        my($self, $path) = @_;
        my $env = {
            PATH_INFO   => $path,
            SCRIPT_NAME => '',
        };
        $self->{file}->call($env);
    }

    sub render_html {
        my($self, $req, $path) = @_;

        my $root = dir($self->{conf}->{document_root})->subdir('template');
        my $tmpl_path = $path;
        $tmpl_path =~ s/\.html/.tmpl/;
        my $real_tmpl_path = $root->file($tmpl_path);
        return $self->dispatch_file($path) unless -f $real_tmpl_path;

        my $tx = Text::Xslate->new(
            syntax => 'TTerse',
            path   => [
                $root
            ],
            cache_dir => '/tmp/perl-users.jp',
            cache     => 1,
            function  => {
            }
        );

        my $vars = { req => $req, };

        my $content_type = 'text/html';
        my $body         = encode_utf8( $tx->render( $tmpl_path, $vars ) );
        return [
            200,
            [
                'Content-Type'   => $content_type,
                'Content-Length' => length($body),
            ],
            [$body]
        ];
    }
}

!!1;

__END__

=head1 NAME

PerlUsersJp  - http://perl-users.jp/

=head1 AUTHOR

yappo

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
