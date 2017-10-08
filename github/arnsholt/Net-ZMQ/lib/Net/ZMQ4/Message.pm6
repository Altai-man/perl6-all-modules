use NativeCall;
unit class Net::ZMQ4::Message is repr('CStruct');

use Net::ZMQ4::Util;

# XXX Hack, hack, hack!
# NativeCall has no way of dealing with flattened arrays yet, so for the time
# being, we just hack around it by embedding 8 64 members instead of a
# 64 byte flattened array.
has int64 $!vsm_data0;
has int64 $!vsm_data1;
has int64 $!vsm_data2;
has int64 $!vsm_data3;
has int64 $!vsm_data4;
has int64 $!vsm_data5;
has int64 $!vsm_data6;
has int64 $!vsm_data7;

# ZMQ_EXPORT int zmq_msg_init (zmq_msg_t *msg);
my sub zmq_msg_init(Net::ZMQ4::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_init_size (zmq_msg_t *msg, size_t size);
my sub zmq_msg_init_size(Net::ZMQ4::Message, size_t --> int32) is native('zmq',v5) { * }
# typedef void (zmq_free_fn) (void *data, void *hint);
# ZMQ_EXPORT int zmq_msg_init_data (zmq_msg_t *msg, void *data,
#     size_t size, zmq_free_fn *ffn, void *hint);
my sub zmq_msg_init_data(Net::ZMQ4::Message, Str, size_t,
    OpaquePointer, OpaquePointer --> int32) is native('zmq',v5) { * }
my sub zmq_msg_init_bytes(Net::ZMQ4::Message, CArray[int8], int32,
    OpaquePointer, OpaquePointer --> int32) is native('zmq',v5) is symbol('zmq_msg_init_data') { * }
# ZMQ_EXPORT int zmq_msg_close (zmq_msg_t *msg);
my sub zmq_msg_close(Net::ZMQ4::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_move (zmq_msg_t *dest, zmq_msg_t *src);
my sub zmq_msg_move(Net::ZMQ4::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_copy (zmq_msg_t *dest, zmq_msg_t *src);
my sub zmq_msg_copy(Net::ZMQ4::Message --> int32) is native('zmq',v5) { * }
# ZMQ_EXPORT void *zmq_msg_data (zmq_msg_t *msg);
my sub zmq_msg_data(Net::ZMQ4::Message --> CArray[int8]) is native('zmq',v5) { * }
# ZMQ_EXPORT size_t zmq_msg_size (zmq_msg_t *msg);
my sub zmq_msg_size(Net::ZMQ4::Message --> int64) is native('zmq',v5) { * }
# ZMQ_EXPORT int zmq_msg_more (const zmq_msg_t *msg);
my sub zmq_msg_more(Net::ZMQ4::Message --> int32) is native('zmq',v5) { * }

# TODO: Public interface methods
multi submethod BUILD() {
    my $ret = zmq_msg_init(self);
    zmq_die() if $ret != 0;
}

multi submethod BUILD(Str :$message! is copy) {
    # XXX: This is only going to work with ASCII data
    # XXX: This is going to leak memory without proper lifecycle handling
    explicitly-manage($message); # TODO: Goes away with better blob handling
    my $ret = zmq_msg_init_data(self, $message, $message.chars, OpaquePointer,
        OpaquePointer);
    zmq_die() if $ret != 0;
}

has CArray[uint8] $!data;
multi submethod BUILD(Blob[uint8] :$data!) {
    my CArray[uint8] $msg .= new;
    $msg[$_] = $data[$_] for 0..^$data.elems;
    my $ret = zmq_msg_init_bytes(self, $msg, $msg.elems, OpaquePointer,
        OpaquePointer);
    zmq_die() if $ret != 0;
}

method close() {
    zmq_msg_close(self);
}

method more(--> Bool) { zmq_msg_more(self) > 0 }

method data() {
    my $buf = buf8.new;
    my $zmq_data = zmq_msg_data(self);
    for 0..^zmq_msg_size(self) {
        $buf.push: $zmq_data[$_];
    }
    return $buf;
}

method data-str() {
    $.data.decode;
}

method size() {
    zmq_msg_size(self);
}
