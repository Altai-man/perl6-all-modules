use v6;

use Panda::Common;
use Panda::Builder;
class Build is Panda::Builder {
    method build($workdir) {
        if $*KERNEL.name ne 'linux' {
            die "Linux::Fuser is only supported on Linux";
        }
        True;
    }
}
