use Zef::Net::HTTP::Request;
use Zef::Net::HTTP::Response;
use Zef::Net::URI;

try require IO::Socket::SSL;

class Zef::Net::HTTP::Client {
    has $.can-ssl = !::("IO::Socket::SSL").isa(Failure);
    has $.auto-check is rw;
    has @.history;
    has $.proxy-url is rw;
    has $.user is rw;
    has $.pass is rw;

    my class RoundTrip {
        has $.request;
        has $.response;
    }

    submethod connect(Zef::Net::URI $uri) {
        my $proxy-uri = Zef::Net::URI.new(url => $!proxy-url) if $!proxy-url;
        my $scheme = (?$proxy-uri && ?$proxy-uri.scheme ?? $proxy-uri.scheme !! $uri.scheme) // 'http';
        my $host   = ?$proxy-uri  && ?$proxy-uri.host   ?? $proxy-uri.host   !! $uri.host;
        my $port   = (?$proxy-uri && ?$proxy-uri.port   ?? $proxy-uri.port   !! $uri.port) // ($scheme eq 'https' ?? 443 !! 80);

        if $scheme eq 'https' && !$!can-ssl {
            die "Please install IO::Socket::SSL for SSL support";
        }

        return !$!can-ssl
            ??  IO::Socket::INET.new( host => $host, port => $port )
            !! $scheme ~~ /^https/ 
                    ?? ::('IO::Socket::SSL').new( host => $host, port => $port )
                    !! IO::Socket::INET.new( host => $host, port => $port );
    }

    method send(Str $action, Str $url, :$payload) {
        my $request    = Zef::Net::HTTP::Request.new( :$action, :$url, :$payload, :$.user, :$.pass );
        my $connection = self.connect($request.uri);
        $connection.send(~$request);

        # todo:
        # Change EOL to \r\n\r\n, use readline to read in the header using :enc(ascii)
        # Read in the rest as the message-body using the appropriate encoding

        my $response   = Zef::Net::HTTP::Response.new(message => do { 
            my $d; while my $r = $connection.recv { $d ~= $r }; $d;
        });

        @.history.push: RoundTrip.new(:$request, :$response);

        if $.auto-check {
            return Zef::Net::HTTP::Request.new unless $response && $response.status-code;
            
            given $response.status-code {
                when /^2\d+$/ { }
                when /^301/     {
                    $response = self.send($action, ~$response.header.<Location>, :$payload);
                }
                default {
                    die "[NYI] http-code: '$_'";
                }
            }
        }

        return $response;
    }

    method get(Str $url) {
        my $response = self.send('GET', $url);
        return $response;
    }

    method post(Str $url, :$payload) {
        my $response = self.send('POST', $url, :$payload);
        return $response;
    }
}