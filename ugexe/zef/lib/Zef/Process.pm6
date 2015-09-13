# A wrapper around Proc and Proc::Async
class Zef::Process {
    has $.id       is rw;
    has $.unit-id  is rw;
    has $.command  is rw;
    has @.args     is rw;
    has $.cwd      is rw;
    has %.env      is rw;
    has $.stdout;
    has $.stderr;
    has $.stdmerge;
    has $.start-time;
    has $.end-time;
    has $.process;
    has $.promise;
    has $!type;
    has $.async;
    has $!can-async;
    has $.started;
    has $.finished;

    submethod BUILD(:$!command = $*EXECUTABLE, :@!args, :$!cwd = $*CWD, :%!env = %*ENV.hash, Bool :$!async, :$!id) {
        $!can-async = $*DISTRO.name eq 'macosx' ?? False !! not ::("Proc::Async") ~~ Failure;
        $!stdout := Supply.new;
        $!stderr := Supply.new;
        $!type   := $!async && $!can-async ?? ::("Proc::Async") !! ::("Proc");
        $!id      = $!id 
            ?? $!id 
            !! @!args.elems
                ?? @!args[*-1].IO.basename 
                !! $!command 
                    ?? $!command.IO.basename 
                    !! ''; # shameful

        die "Proc::Async not available, but option --jobs explicitily requested it (JVM and OSX NYI)"
            if $!async && !$!can-async;
    }

    method start {
        # error check is duplicated here because, dun dun dunnn, JVM won't die otherwise
        die "Proc::Async not available, but option --jobs explicitily requested it (JVM and OSX NYI)"
            if $!async && !$!can-async;

        if $!async {
            $!process := Proc::Async.new($!command, @!args);
            $!process.stdout.act: { $!stdout.emit($_); $!stdmerge ~= $_ }
            $!process.stderr.act: { $!stderr.emit($_); $!stdmerge ~= $_ }
            $!process.stdout.emit("{$!command.IO.basename} {@!args.join(' ')}\n");

            $!promise  := $!process.start(:$!cwd, ENV => %!env);

            $!started  := $!process.started;
            $!finished := $!promise.Bool;
        }
        else {
            $!process := shell("{$!command} {@!args.join(' ')} 2>&1", :out, :$!cwd, :%!env, :!chomp);
            $!promise := Promise.new;
            $!stdout.act: { $!stdmerge ~= $_ }
            $!stderr.act: { $!stdmerge ~= $_ }

            $!stdout.emit("{$!command.IO.basename} {@!args.join(' ')}\n");

            $!started = True;
            $!stdout.emit($_) for $!process.out.lines(:!eager, :close);
            $!stdout.done; $!stderr.done;
            $!process.out.close; $!stderr.close;
            $!finished := ?$!promise.keep($!process);
        }

        $!promise;
    }

    method ok       { $!process.DEFINITE ?? $.exitcode == 0 ?? True !! False !! False }
    method nok      { ?$.ok ?? False !! True    }
    method status   { $!process.status          }
    method exitcode { 
        $!promise.result; # osx bug RT125758
        $!promise.result.exitcode;
    }
}