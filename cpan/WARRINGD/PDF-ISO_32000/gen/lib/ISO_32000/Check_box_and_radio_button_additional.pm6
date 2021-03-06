use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Check_box_and_radio_button_additional ../../resources/ISO_32000/Check_box_and_radio_button_additional_entries.json

#| PDF 32000-1:2008 Table 227 – Additional entry specific to check box and radio button fields
role ISO_32000::Check_box_and_radio_button_additional {
    method Opt {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Opt [array of text strings]
- (Optional; inheritable; PDF 1.4) An array containing one entry for each widget annotation in the Kids array of the radio button or check box field. Each entry is a text string representing the on state of the corresponding widget annotation.
When this entry is present, the names used to represent the on state in the APdictionary of each annotation (for example, /1, /2) numerical position (starting with 0) of the annotation in the Kids array, encoded as a name object. This allows distinguishing between the annotations even if two or more of them have the same value in the Opt array.

=end pod
