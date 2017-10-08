#| EnumClass is the base class used to create hierarchical enums. The only
#| example in Spitsh of this is the OS EnumClass which stores the
#| relationships between Operating Systems.
augment EnumClass {

    #| Returns the name of the enum class.
    method name~ { $self.${cut -f1 '-d|'} }

    #| Returns true if the argument string exactly matches a member of
    #| the enum class.
    #|{
        say Debian.has-member('Ubuntu'); # true
        say RHEL.has-member('Ubuntu'); # false
        say Ubuntu ~~ Debian; # true
    }
    method has-member(#|[A string to match against the enum's members] $candidate)? {
        $candidate.matches(/^($self)$/)
    }

    #| Returns True if the argument EnumClass is a member of the
    #| invocant EnumClass.
    method ACCEPTS(EnumClass $b)? { $self.has-member($b.name) }
}
