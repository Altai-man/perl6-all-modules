use IO::Socket::Async::SSL;

my $conn = await IO::Socket::Async::SSL.connect('www.perl6.org', 443);
$conn.print: "GET / HTTP/1.0\r\nHost: www.perl6.org\r\n\r\n";
react {
    whenever $conn {
        .print
    }
}
$conn.close;
