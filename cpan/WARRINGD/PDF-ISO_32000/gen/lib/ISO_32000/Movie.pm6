use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Movie ../../resources/ISO_32000/Movie_entries.json

#| PDF 32000-1:2008 Table 295 – Entries in a movie dictionary
role ISO_32000::Movie {
    method F {...};
    method Aspect {...};
    method Rotate {...};
    method Poster {...};
}

=begin pod

=head1 Methods (Entries)

=head2 F [file specification]
- (Required) A file specification identifying a self-describing movie file.
NOTE The format of a self-describing movie file is left unspecified, and there is no guarantee of portability.

=head2 Aspect [array]
- (Optional) The width and height of the movie’s bounding box, in pixels, and is specified as [ width height ]. This entry is omitted for a movie consisting entirely of sound with no visible images.

=head2 Rotate [integer]
- (Optional) The number of degrees by which the movie is rotated clockwise relative to the page. The value is a multiple of 90. Default value: 0.

=head2 Poster [boolean or stream]
- (Optional) A flag or stream specifying whether and how a poster imagerepresenting the movie is displayed. If this value is a stream, it shall contain an image XObject (see 8.9, “Images”) to be displayed as the poster. If it is the boolean value true, the poster image is retrieved from the movie file; if it is false, no poster is displayed. Default value: false.

=end pod
