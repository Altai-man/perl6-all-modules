use v6;
# generated by: ../../etc/make-modules.p6 --role-name=ISO_32000::Number_tree_node ../../resources/ISO_32000/Number_tree_node_entries.json

#| PDF 32000-1:2008 Table 37 – Entries in a number tree node dictionary
role ISO_32000::Number_tree_node {
    method Kids {...};
    method Nums {...};
    method Limits {...};
}

=begin pod

=head1 Methods (Entries)

=head2 Kids [array]
- (Root and intermediate nodes only; required in intermediate nodes; present in the root node if and only if Nums is not present) Shall be an array of indirect references to the immediate children of this node. The children may be intermediate or leaf nodes.

=head2 Nums [array]
- (Root and leaf nodes only; is required in leaf nodes; present in the root node if and only if Kids is not present) Shall be an array of the form
[ key 1 value 1 key 2 value 2 … key n value n ]
where each key i is an integer and the corresponding value i is the object associated with that key. The keys is sorted in numerical order, analogously to the arrangement of keys in a name tree as described in
7.9.6, "Name Trees."

=head2 Limits [array]
- (Shall be present in Intermediate and leaf nodes only) Shall be an array of two integers, that shall specify the (numerically) least and greatest keys included in the Nums array of a leaf node or in the Nums arrays of any leaf nodes that are descendants of an intermediate node.

=end pod
