use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::FDF_catalog ../../resources/ISO_32000/FDF_catalog_entries.json

#| PDF 32000-1:2008 Table 242 – Entries in the FDF catalog dictionary
role ISO_32000::FDF_catalog {
    method Version {...};
    method FDF {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Version [name]
- (Optional; PDF 1.4) The version of the FDF specification to which this FDF file conforms (for example, 1.4) if later than the version specified in the file’s header (see Link FDF Header in 12.7.7.2, “FDF File Structure”). If the header specifies a later version, or if this entry is absent, the document conforms to the version specified in the header.
The value of this entry is a name object, not a number, and therefore is preceded by a slash character (/) when written in the FDF file (for example, /1.4).

=head2 FDF [dictionary]
- (Required) The FDF dictionary for this file (see Table 243).

=end pod
