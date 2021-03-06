use v6;
use Hinges::StreamEventKind;
use Hinges::Output;

class Hinges::Stream {
    has @!events;
    has $serializer;

    multi method new(@events, $serializer?) {
        return self.new(
            :events(@events),
            :serializer($serializer // Hinges::XHTMLSerializer.new())
        );
    }

    # RAKUDO: We shouldn't have to provide this method. It should be handed
    #         to us by C<Object>.
    multi method new(*%_) {
        return self.bless(self.CREATE(), |%_);
    }

    method Str() {
        # RAKUDO: A complex set of circumstances may cause the
        #         array to have been nested one level too deeply at
        #         this point. Compensating.
        @!events = @(@!events[0])
            while @!events.elems == 1 && @!events[0] ~~ Array;
        return $serializer.serialize(self);
    }

    method llist() {
        # RAKUDO: A complex set of circumstances may cause the
        #         array to have been nested one level too deeply at
        #         this point. Compensating.
        @!events = @(@!events[0])
            while @!events.elems == 1 && @!events[0] ~~ Array;
        return @!events;
    }

    method render($format, :$doctype) {
        return "";
    }
}
