use v6;

use PDF::COS::Tie::Hash;

role PDF::Mask
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;

    # See [PDF 32000 Table 144 - Entries in a soft-mask dictionary]
    ## use ISO_32000::Soft-mask;
    ## also does ISO_32000::Soft-mask;
    # /Type entry is optional, but should be /Mask when present
    has PDF::COS::Name $.Type is entry where 'Mask';
    method type {'Mask'}

    my subset MaskSubtype of PDF::COS::Name where 'Alpha'|'Luminosity';
    has MaskSubtype $.S is entry(:required, :alias<subtype>);   # (Required) A subtype specifying the method to be used in deriving the mask values from the transparency group specified by the G entry:
        # - Alpha: The group’s computed alpha shall be used, disregarding its colour.
        # - Luminosity The group’s computed colour shall be converted to a single-component luminosity value (see
    has PDF::COS::Stream $.G is entry(:required, :alias<transparency-group>); # (Required) A transparency group XObject to be used as the source of alpha or colour values for deriving the mask. If the subtype S is Luminosity, the group attributes dictionary shall contain a CS entry defining the colour space in which the compositing computation is to be performed.
    has Numeric @.BC is entry(:alias<backdrop-color>); # An array of component values specifying the colour to be used as the backdrop against which to composite the transparency group XObject G. This entry shall be consulted only if the subtype S is Luminosity. The array shall consist of n numbers, where n is the number of components in the colour space specified by the CS entry in the group attributes dictionary
    # Default value: the colour space’s initial value, representing black.
    use PDF::Function;
    my subset FunctionOrIdentity where PDF::Function|'Identity';
    has FunctionOrIdentity $.TR is entry(:alias<transfer-function>, :default<Identity>);                 # A function object specifying the transfer function to be used in deriving the mask values. The function shall accept one input, the computed group alpha or luminosity (depending on the value of the subtype S), and shall return one output, the resulting mask value. The input shall be in the range 0.0 to 1.0. The computed output shall be in the range 0.0 to 1.0; if it falls outside this range, it shall be forced to the nearest valid value. The name Identity may be specified in place of a function object to designate the identity
    # function. Default value: Identity.

}
