use v6;
use lib 't';

use Test;

use MongoDB;
use MongoDB::MDBConfig;
use MongoDB::Server::Control;

# Must call new to create the sandbox
use Test-support;
my MongoDB::Test-support $ts .= new;

#-------------------------------------------------------------------------------
drop-send-to('mongodb');
#my $handle = 'MongoDB.mlog'.IO.open( :mode<wo>, :create, :truncate);
#modify-send-to( 'mongodb', :level(MongoDB::MdbLoglevels::Trace), :to($handle));
drop-send-to('screen');
#modify-send-to( 'screen', :level(MongoDB::MdbLoglevels::Info));
info-message("Test start");

#-------------------------------------------------------------------------------
subtest "config test", {

  # search for Sandbox/config.toml
  my MongoDB::MDBConfig $mdbcfg .= instance(
    :locations(['Sandbox',]), :config-name<config.toml>
  );
  isa-ok $mdbcfg, MongoDB::MDBConfig;
  like $mdbcfg.cfg.refine(<server s2>)<port>, /650\d\d/, 'port number select';
  is $mdbcfg.cfg.refine(<locations s6>)<server-subdir>, 'Server-s6',
     'server 6 subdir';
};

#-------------------------------------------------------------------------------
subtest "control test", {

  my MongoDB::Server::Control $mdbcntrl .= new;
  isa-ok $mdbcntrl, MongoDB::Server::Control;
  like $mdbcntrl.get-port-number('s2'), /650\d\d/, 'port number select';
};

#-------------------------------------------------------------------------------
subtest "server start/stop from config data test", {

  my MongoDB::Server::Control $sc .= new;
  ok $sc.start-mongod("s1"), 'Server 1 started';
  sleep 0.8;
  ok $sc.stop-mongod("s1"), 'Server 1 stopped';
};

#-------------------------------------------------------------------------------
info-message("Test $?FILE end");
done-testing;
