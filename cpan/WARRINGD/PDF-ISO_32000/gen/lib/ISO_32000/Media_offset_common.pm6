use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Media_offset_common ../../resources/ISO_32000/Media_offset_common_entries.json

#| PDF 32000-1:2008 Table 285 – Entries common to all media offset dictionaries
role ISO_32000::Media_offset_common {
    method Type {...};
    method S {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Type [name]
- (Optional) The type of PDF object that this dictionary describes; if present, is MediaOffset for a media offset dictionary.

=head2 S [name]
- (Required) The subtype of media offset dictionary. Valid values is:
T A media offset time dictionary (see Table 286)
F A media offset frame dictionary (see Table 287)
M A media offset marker dictionary (see Table 288)
The rendition is considered non-viable if the conforming reader does not recognize the value of this entry.

=end pod
