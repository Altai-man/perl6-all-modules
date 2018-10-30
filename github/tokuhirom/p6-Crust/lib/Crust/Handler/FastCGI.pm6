use v6;

unit class Crust::Handler::FastCGI;

require FastCGI::NativeCall;
require FastCGI::NativeCall::PSGI;

has $!psgi;

method new(*%args) {
    my $socket = %args<socket> // %*ENV<FCGI_SOCKET> // '/var/www/run/p6w-fcgi.sock';
    my $backlog = %args<backlog> // %*ENV<FCGI_BACKLOG> // 5;
    self.bless()!initialize(:$socket, :$backlog);
}

method !initialize(:$socket, :$backlog) {
    my $sock = &::("FastCGI::NativeCall::OpenSocket")($socket, $backlog);
    $!psgi = ::("FastCGI::NativeCall::PSGI").new(::("FastCGI::NativeCall").new($sock));
    self;
}

method run(Crust::Handler::FastCGI:D: Callable $app) {
    $!psgi.app($app);
    $!psgi.run;
}

=begin pod

=head1 NAME

Crust::Handler::FastCGI - Crust adapter for FastCGI::NativeCall::PSGI

=head1 SYNOPSIS

    crustup \
        -s FastCGI -MFastCGI::NativeCall -MFastCGI::NativeCall::PSGI \
        [--socket /PATH/TO/APP.SOCK] [--backlog INT] \
        app.p6w

=end pod
