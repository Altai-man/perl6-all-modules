use v6;

unit module Sparrowdo::Chef::Client;

use Sparrowdo;
use JSON::Tiny;

our sub tasks (%args) {


  my %chef-json =  Hash.new;

  %chef-json<run_list> = %args<run-list> || [];

  my %attributes = %args<attributes> || Hash.new;

  for %attributes.keys -> $a {
    %chef-json{$a} = %attributes{$a} 
  } 
  

  task_run %(
    task => "set up chef run list and attributes",
    plugin => "file",
    parameters => %(
      target  => "/tmp/chef.json",
      content => ( to-json %chef-json ),
    ),
  );
  
  my $log-level = %args<log-level> || 'info';

  my $chef-run-command = '';

  if %args<chef-repo-path> {
    $chef-run-command ~= "cd " ~ %args<chef-repo-path> ~ ' && '
  }

  $chef-run-command ~= "chef-client --color --json /tmp/chef.json -l $log-level";

  $chef-run-command ~= " --force-formatter"  if %args<force-formatter>;

  $chef-run-command ~= " --local-mode"  if %args<local-mode>;

  task_run %(
    task => "run chef-client",
    plugin => "bash",
    parameters => %(
      command => $chef-run-command
    ),
  );
  
  
}

