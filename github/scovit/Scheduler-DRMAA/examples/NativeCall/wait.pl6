use v6.d.PREVIEW;
use DRMAA::NativeCall;
use NativeCall :types;
use NativeHelpers::CBuffer;

my $error   = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
my $errnum  = 0;

my $remote-command = CBuffer.new("./sleeper.sh");

my Pointer[drmaa_job_template_t] $jt = Pointer[drmaa_job_template_t].new;

$errnum = drmaa_init((CBuffer), $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not initialize the DRMAA library: ", $error;
}

$errnum = drmaa_allocate_job_template($jt, $error, DRMAA_ERROR_STRING_BUFFER);

if ($errnum != DRMAA_ERRNO_SUCCESS) {
    warn "Could not create job template: ", $error;
}
else {
    $errnum = drmaa_set_attribute($jt.deref, DRMAA_REMOTE_COMMAND, $remote-command,
				  $error, DRMAA_ERROR_STRING_BUFFER);

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not set attribute "', DRMAA_REMOTE_COMMAND, '": ', $error;
    }
    else {
	my $args will leave { .free for .Seq } = CArray[CBuffer].new(CBuffer.new("5"), (CBuffer));

	$errnum = drmaa_set_vector_attribute($jt.deref, DRMAA_V_ARGV, $args, $error,
					     DRMAA_ERROR_STRING_BUFFER);
    }

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not set attribute "', DRMAA_V_ARGV, '": ', $error;
    }
    else {
	my $jobid will leave { .free }          = CBuffer.new(DRMAA_JOBNAME_BUFFER);
	my $jobid_out will leave { .free }      = CBuffer.new(DRMAA_JOBNAME_BUFFER);
	my int32 $status                        = 0;
	my Pointer[drmaa_attr_values_t] $rusage = Pointer[drmaa_attr_values_t].new;

	$errnum = drmaa_run_job($jobid, DRMAA_JOBNAME_BUFFER, $jt.deref, $error,
				DRMAA_ERROR_STRING_BUFFER);
 
	if ($errnum != DRMAA_ERRNO_SUCCESS) {
	    warn "Could not submit job: ", $error;
	}
	else {
	    say 'Your job has been submitted with id ', $jobid;

	    $errnum = drmaa_wait($jobid, $jobid_out, DRMAA_JOBNAME_BUFFER, $status,
				 DRMAA_TIMEOUT_WAIT_FOREVER, $rusage, $error,
				 DRMAA_ERROR_STRING_BUFFER);

	    if ($errnum != DRMAA_ERRNO_SUCCESS) {
                warn "Could not wait for job: ", $error;
	    }
	    else {
                my $usage will leave { .free } = CBuffer.new(DRMAA_ERROR_STRING_BUFFER);
                my int32 $aborted = 0;
 
                drmaa_wifaborted($aborted, $status, (Buf), 0);
 
                if ($aborted == 1) {
		    say 'Job ', $jobid, ' never ran';
                }
                else {
		    my int32 $exited = 0;
 
		    drmaa_wifexited($exited, $status, (CBuffer), 0);
 
		    if ($exited == 1) {
			my int32 $exit_status = 0;
 
			drmaa_wexitstatus($exit_status, $status, (CBuffer), 0);
			say 'Job ', $jobid, ' finished regularly with exit status ', $exit_status;
		    }
		    else {
			my int32 $signaled = 0;
 
			drmaa_wifsignaled($signaled, $status, (CBuffer), 0);
 
			if ($signaled == 1) {
			    my $termsig will leave { .free } = CBuffer.new((DRMAA_SIGNAL_BUFFER+1));
 
			    drmaa_wtermsig($termsig, DRMAA_SIGNAL_BUFFER, $status, (CBuffer), 0);
			    say 'Job ', $jobid, ' finished due to signal ', $termsig;
			}
			else {
			    say 'Job ', $jobid, ' finished with unclear conditions';
			}
		    } # else
                } # else

                say 'Job Usage:';

                while (drmaa_get_next_attr_value($rusage.deref, $usage, DRMAA_ERROR_STRING_BUFFER) == DRMAA_ERRNO_SUCCESS) {
		    say "  ", $usage;
                }
                
	    } # else
	} # else
    } # else

    $errnum = drmaa_delete_job_template($jt.deref, $error, DRMAA_ERROR_STRING_BUFFER);

    if ($errnum != DRMAA_ERRNO_SUCCESS) {
	warn 'Could not delete job template: ', $error;
    }
} # else

$errnum = drmaa_exit($error, DRMAA_ERROR_STRING_BUFFER);
 
if ($errnum != DRMAA_ERRNO_SUCCESS) {
    die "Could not shut down the DRMAA library: ", $error;
}
