use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Media_clip_section ../../resources/ISO_32000/Media_clip_section_entries.json

#| PDF 32000-1:2008 Table 277 – Additional entries in a media clip section dictionary
role ISO_32000::Media_clip_section {
    method D {...};
    method Alt {...};
    method MH {...};
    method BE {...};
}

=begin pod

=head1 Methods (Entries)

=head2 D [dictionary]
- (Required) The media clip section or media clip data object (the next-level media object) of which this media clip section object defines a continuous section.

=head2 Alt [array]
- (Optional) An array that provides alternate text descriptions for the media clip section in case it cannot be played; see
14.9.2.4, “Multi-language Text Arrays.”


=head2 MH [dictionary]
- (Optional) A dictionary whose entries (see Table 278) is honoured for the media clip section to be considered viable.

=head2 BE [dictionary]
- (Optional) A dictionary whose entries (see Table 278) shall only be honoured in a “best effort” sense.

=end pod
