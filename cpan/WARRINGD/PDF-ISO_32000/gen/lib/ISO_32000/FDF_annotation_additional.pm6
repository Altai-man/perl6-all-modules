use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::FDF_annotation_additional ../../resources/ISO_32000/FDF_annotation_additional_entries.json

#| PDF 32000-1:2008 Table 251 – Additional entry for annotation dictionaries in an FDF file
role ISO_32000::FDF_annotation_additional {
    method Page {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Page [integer]
- (Required for annotations in FDF files) The ordinal page number on which this annotation shall appear, where page 0 is the first page.

=end pod
