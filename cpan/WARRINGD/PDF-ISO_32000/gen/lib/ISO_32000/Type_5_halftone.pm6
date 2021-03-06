use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Type_5_halftone ../../resources/ISO_32000/Type_5_halftone_entries.json

#| PDF 32000-1:2008 Table 134 – Entries in a type 5 halftone dictionary
role ISO_32000::Type_5_halftone {
    method Type {...};
    method HalftoneType {...};
    method HalftoneName {...};
    method Default {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Type [name]
- (Optional) The type of PDF object that this dictionary describes; if present, is Halftone for a halftone dictionary.

=head2 HalftoneType [number]
- (Required) A code identifying the halftone type that this dictionary describes; is 5 for this type of halftone.

=head2 HalftoneName [byte string]
- (Optional) The name of the halftone dictionary.

=head2 Default [dictionary or stream]
- (Required) A halftone to be used for any colorant or colour component that does not have an entry of its own. The value is not 5. If there are any nonprimary colorants, the default halftone has a transfer function.

=end pod
