use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Media_screen_parameters ../../resources/ISO_32000/Media_screen_parameters_entries.json

#| PDF 32000-1:2008 Table 282 – Entries in a media screen parameters dictionary
role ISO_32000::Media_screen_parameters {
    method Type {...};
    method MH {...};
    method BE {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Type [name]
- (Optional) The type of PDF object that this dictionary describes; if present, is MediaScreenParams for a media screen parameters dictionary.

=head2 MH [dictionary]
- (Optional) A dictionary whose entries (see Table 283) is honoured for the media screen parameters to be considered viable.

=head2 BE [dictionary]
- (Optional) A dictionary whose entries (see Table 283) is honoured.

=end pod
