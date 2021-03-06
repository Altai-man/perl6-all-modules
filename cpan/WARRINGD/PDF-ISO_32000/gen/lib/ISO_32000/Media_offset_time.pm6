use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Media_offset_time ../../resources/ISO_32000/Media_offset_time_entries.json

#| PDF 32000-1:2008 Table 286 – Additional entries in a media offset time dictionary
role ISO_32000::Media_offset_time {
    method T {...};
}

=begin pod

=head1 Methods (Entries)

=head2 T [dictionary]
- (Required) A timespan dictionary (see Table 289) that shall specify a temporal offset into a media object. Negative timespans are not allowed in this context. The media offset time dictionary is non-viable if its timespan dictionary is non-viable.

=end pod
