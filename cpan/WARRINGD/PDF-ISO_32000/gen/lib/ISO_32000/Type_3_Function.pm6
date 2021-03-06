use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Type_3_Function ../../resources/ISO_32000/Type_3_Function_entries.json

#| PDF 32000-1:2008 Table 41 – Additional entries specific to a type 3 function dictionary
role ISO_32000::Type_3_Function {
    method Functions {...};
    method Bounds {...};
    method Encode {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Functions [array]
- (Required) An array of k 1-input functions that shall make up the stitching function. The output dimensionality of all functions is the same, and compatible with the value of Range if Range is present.

=head2 Bounds [array]
- (Required) An array of k 1 numbers that, in combination with Domain, shall define the intervals to which each function from the Functions array applies. Bounds elements is in order of increasing value, and each value is within the domain defined by Domain.

=head2 Encode [array]
- (Required) An array of 2 k numbers that, taken in pairs, shall map each subset of the domain defined by Domain and the Bounds array to the domain of the corresponding function.

=end pod
