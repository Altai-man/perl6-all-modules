#!/usr/bin/env perl6

use Event::Emitter::Inter-Process;

my $ee = Event::Emitter::Inter-Process.new(:sub-process(True));

$ee.on('echo', -> $data {
  dd $data.decode;
  $ee.emit('echo'.encode, $data);
});

sleep 3;
