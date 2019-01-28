use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Name_tree_node ../../resources/ISO_32000/Name_tree_node_entries.json

#| PDF 32000-1:2008 Table 36 – Entries in a name tree node dictionary
role ISO_32000::Name_tree_node {
    method Kids {...};
    method Names {...};
    method Limits {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Kids [array]
- (Root and intermediate nodes only; required in intermediate nodes; present in the root node if and only if Names is not present) Shall be an array of indirect references to the immediate children of this node. The children may be intermediate or leaf nodes.

=head2 Names [array]
- (Root and leaf nodes only; required in leaf nodes; present in the root node if and only if Kids is not present) Shall be an array of the form
[ key 1 value 1 key 2 value 2 … key n value n ]
where each key i is a string and the corresponding value i is the object associated with that key. The keys is sorted in lexical order, as described below.

=head2 Limits [array]
- (Intermediate and leaf nodes only; required) Shall be an array of two strings, that shall specify the (lexically) least and greatest keys included in the Names array of a leaf node or in the Names arrays of any leaf nodes that are descendants of an intermediate node.

=end pod
