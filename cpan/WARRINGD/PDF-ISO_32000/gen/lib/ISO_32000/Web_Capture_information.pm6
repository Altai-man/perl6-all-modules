use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Web_Capture_information ../../resources/ISO_32000/Web_Capture_information_entries.json

#| PDF 32000-1:2008 Table 350 – Entries in the Web Capture information dictionary
role ISO_32000::Web_Capture_information {
    method V {...};
    method C {...};
}

=begin pod

=head1 Methods (Entries)

=head2 V [number]
- (Required) The Web Capture version number. The version number is 1.0 in a conforming file.
This value is a single real number, not a major and minor version number.
EXAMPLE A version number of 1.2 would be considered greater than 1.15.

=head2 C [array]
- (Optional) An array of indirect references to Web Capture command dictionaries (see 14.10.5.3, “Command Dictionaries”) describing commands that were used in building the PDF file. The commands shall appear in the array in the order in which they were executed in building the file.

=end pod
