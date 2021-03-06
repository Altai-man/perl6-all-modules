use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Standard_table ../../resources/ISO_32000/Standard_table_attributes.json

#| PDF 32000-1:2008 Table 349 – Standard table attributes
role ISO_32000::Standard_table {
    method RowSpan {...};
    method ColSpan {...};
    method Headers {...};
    method Scope {...};
    method Summary {...};
}

=begin pod

=head1 Methods (Entries)

=head2 RowSpan [integer]
- (Optional; not inheritable) The number of rows in the enclosing table that is spanned by the cell. The cell shall expand by adding rows in the block-progression direction specified by the table’s WritingModeattribute. If this entry is absent, a conforming reader shall assume a value of 1.
This entry shall only be used when the table cell has a structure type of TH or TD or one that is role mapped to structure type TH or TD (see Table 337).

=head2 ColSpan [integer]
- (Optional; not inheritable) The number of columns in the enclosing table that is spanned by the cell. The cell shall expand by adding columns in the inline-progression direction specified by the table’s WritingMode attribute. If this entry is absent, a conforming reader shall assume a value of 1
This entry shall only be used when the table cell has a structure type of TH or TD or one that is role mapped to structure types TH or TD (see Table 337).

=head2 Headers [array]
- (Optional; not inheritable; PDF 1.5) An array of byte strings, where each string is the element identifier (see the ID entry in Table 323) for a TH structure element that is used as a header associated with this cell.
This attribute may apply to header cells (TH) as well as data cells (TD) (see Table 337). Therefore, the headers associated with any cell is those in its Headers array plus those in the Headers array of any THcells in that array, and so on recursively.

=head2 Scope [name]
- (Optional; not inheritable; PDF 1.5) A name whose value is one of the following: Row, Column, or Both. This attribute shall only be used when the structure type of the element is TH. (see Table 337). It shall reflect whether the header cell applies to the rest of the cells in the row that contains it, the column that contains it, or both the row and the column that contain it.

=head2 Summary [text string]
- (Optional; not inheritable; PDF 1.7) A summary of the table’s purpose and structure. This entry shall only be used within Table structure elements (see Table 337).
NOTE For use in non-visual rendering such as speech or braille

=end pod
