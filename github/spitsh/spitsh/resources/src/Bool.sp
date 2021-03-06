#| Bool refers to the Boolean type. They can be used as values but
#| more often represent whether a shell command exited
#| successfully. In [Str](Str.md) context a Bool will be '1' if true
#| and "" (they empty string) if false.
#|{
    say True.WHAT #-> Bool
    say False.WHAT #-> Bool
    say ("foo" eq "bar").WHAT; #-> Bool
    say False; #-> ''
    say True;  #-> '1'
}
augment Bool {
    #| In Int context, Bools become a 1 if True or a 0 if False.
    method Int+ { $self ?? 1 !! 0 }
    #| .gist returns "True" or "False".
    method gist~ { $self ?? "True" !! "False" }

    method JSON { ($self ?? 'true' !! 'false')-->JSON }

    #| Simply returns the value of the invocant regardless of the argument.
    method ACCEPTS($b)? { $self }
}
