use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Media_offset_frame ../../resources/ISO_32000/Media_offset_frame_entries.json

#| PDF 32000-1:2008 Table 287 – Additional entries in a media offset frame dictionary
role ISO_32000::Media_offset_frame {
    method F {...};
}

=begin pod

=head1 Methods (Entries)

=head2 F [integer]
- (Required) Shall specify a frame within a media object. Frame numbers begin at 0; negative frame numbers are not allowed.

=end pod
