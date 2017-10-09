use Zef;

class Zef::Service::Shell::unzip does Extractor does Messenger {
    method extract-matcher($path) { so $path.IO.extension.lc eq 'zip' }

    method probe {
        state $probe = try { zrun('unzip', '--help', :!out, :!err).so };
    }

    method extract(IO() $archive-file, IO() $extract-to) {
        die "archive file does not exist: {$archive-file.absolute}"
            unless $archive-file.e && $archive-file.f;
        die "target extraction directory {$extract-to.absolute} does not exist and could not be created"
            unless ($extract-to.e && $extract-to.d) || mkdir($extract-to);

        my $passed;
        react {
            my $cwd := $archive-file.parent;
            my $ENV := %*ENV;
            my $proc = zrun-async('unzip', '-o', '-qq', $archive-file.basename, '-d', $extract-to.absolute);
            whenever $proc.stdout(:bin) { }
            whenever $proc.stderr(:bin) { }
            whenever $proc.start(:$ENV, :$cwd) { $passed = $_.so }
        }

        my $meta6-prefix = self.list($archive-file).sort.first({ .IO.basename eq 'META6.json' });
        my $extracted-to = $extract-to.child($meta6-prefix);
        ($passed && $extracted-to.e) ?? $extracted-to !! False;
    }

    method list(IO() $archive-file) {
        die "archive file does not exist: {$archive-file.absolute}"
            unless $archive-file.e && $archive-file.f;

        my $passed;
        my $output = Buf.new;
        react {
            my $cwd := $archive-file.parent;
            my $ENV := %*ENV;
            my $proc = zrun-async('unzip', '-Z', '-1', $archive-file.basename);
            whenever $proc.stdout(:bin) { $output.append($_) }
            whenever $proc.stderr(:bin) { }
            whenever $proc.start(:$ENV, :$cwd) { $passed = $_.so }
        }

        my @extracted-paths = $output.decode.lines;
        $passed ?? @extracted-paths.grep(*.defined) !! ();
    }
}
