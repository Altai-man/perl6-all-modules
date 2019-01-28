use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Web_Capture_image_set ../../resources/ISO_32000/Web_Capture_image_set_entries.json

#| PDF 32000-1:2008 Table 354 – Additional entries specific to a Web Capture image set
role ISO_32000::Web_Capture_image_set {
    method S {...};
    method R {...};
}

=begin pod

=head1 Methods (Entries)

=head2 S [name]
- (Required) The subtype of content set that this dictionary describes; is SIS.

=head2 R [integer or array]
- (Required) The reference counts for the image XObjects belonging to the image set. For an image set containing a single XObject, the value is the integer reference count for that XObject. For an image set containing multiple XObjects, the value is an array of reference counts parallel to the O array (see Table 352); that is, each element in the R array shall hold the reference count for the image XObject at the corresponding position in the O array.

=end pod
