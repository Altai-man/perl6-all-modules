use v6;

=begin pod

=head1 CommonMark

Interface to the L<libcmark> CommonMark parser

=head1 Synopsis

    use CommonMark;

    say CommonMark.to-html("Hello, world!");
    # "<p>Hello, world!</p>"

    say CommonMark.version-string;
    # 0.28.3

=head1 Documentation

CommonMark is Markdown with a proper spec - It should render most Markdown
files the same; it nails down some edge cases, and specifies byte encodings.

You'll want to call C<.to-html($text)> to convert markdown to HTML. The
library itself also supports XML, LaTeX, and nroff/troff formats, but I haven't
seen where it's tested. Check out the Perl 6 source for more details there.

=head1 CommonMark class

=head2 METHODS

=item to-html( $common-mark )

Return HTML from CommonMark format. This is likely the only method you'll use.
There's a lower-level interface that'll let you interrogate the library at the
individual node level, look at the source for more inspiration.

=item version()

Returns a 32-bit int containing the version number.

From the documetation:

 * Bits 16-23 contain the major version.
 * Bits 8-15 contain the minor version.
 * Bits 0-7 contain the patchlevel.

=item version-string()

Returns the library version in text form.

=item parse-document( Str $buffer, int32 $options )

Returns a CommonMark::Node root of the document.

=head1 CommonMark::Node class

=item new( :$type )

Create a new CommonMark node with the specified type - this isn't well-documented in the library, so please read the source.

=item next()

Return this node's successor in the multiply-linked list

=item previous()

Return this node's predecessor in the multiply-linked list

=item parent()

Return this node's parent in the multiply-linked list

=item first-child()

Return this node's first child within the multiply-linked list

=item last-child()

Return this node's last child within the multiply-linked list

=item user-data()

Return this node's user data (generic pointer)

=item user-data( Pointer $ptr )

Set user data pointer

=item type()

Return this node's type number

=item type-string()

Return this node's type as a string

=item literal()

Return this node's literal string

=item literal( Str $str )

Set this node's literal string

=item heading-level()

Return this node's heading level

=item heading-level( int32 $level )

Set this node's heading level

=item list-type()

Return this node's list type

=item list-type( int32 $level )

Set this node's list type

=item list-delim()

Return this node's list delimiter

=item list-delim( int32 $level )

Set this node's list delimiter

=item list-start()

Return this node's list start

=item list-start( int32 $level )

Set this node's list start

=item list-tight()

Return this node's list tightness

=item list-tight( int32 $level )

Set this node's list tightness

=item fence-info()

Return this node's fence information

=item fence-info( Str $info )

Set this node's fence information

=item url()

Return this node's URL content

=item url( Str $url )

Set this node's URL content

=item title()

Return this node's title

=item title( Str $title )

Set this node's title

=item on-enter()

Return this node's on-enter string

=item on-enter( Str $title )

Set this node's on-enter string

=item on-exit()

Return this node's on-exit string

=item on-exit( Str $title )

Set this node's on-exit string

=item start-line()

Return this node's starting line

=item start-column()

Return this node's starting column

=item end-line()

Return this node's end line

=item end-column()

Return this node's end column

=item unlink()

Unlink this node from the tree.

=item insert-before( CommonMark::Node $node )

Insert C<$node> before this node

=item insert-after( CommonMark::Node $node )

Insert C<$node> after this node

=item replace( CommonMark::Node $node )

Replace this node with C<$node>

=item prepend-child( CommonMark::Node $node )

Prepend C<$node> below this node

=item append-child( CommonMark::Node $node )

Append C<$node> below this node

=item consolidate-text-nodes()

Consolidate the text nodes in this node

=item render-xml( int32 $options )

Render this node as XML, with the appropriate options C<$options>

=item render-html( int32 $options )

Render this node as HTML, with the appropriate options C<$options>

=item render-man( int32 $options, int32 $width )

Render this node as a manpage, with the appropriate options C<$options>, C<$width>

=item render-commonmark( int32 $options, int32 $width )

Render this node as the original CommonMark text, with the appropriate options C<$options> and C<$idth>

=item render-latex( int32 $options, int32 $width )

Render this node as LaTeX, with the appropriate options C<$options>, C<$width>

=item check( int32 $file-ID )

Check this node with file descriptor $file-ID

=head1 CommonMark::Iterator class

=item next()

Return the next item in this iterator

=item node()

Return the current node for the iterator

=item event-type()

Return the current event type

=item root()

Return the root for the iterator

=item reset( CommonMark::Node $current, int32 $event-type )

Reset the iterator to node C<$current>, type C<$event-type>

=head1 CommonMark::Parser class

=item feed( Str $buffer )

Feed the buffer to the parser

=item finish()

Finish parsing the document

=end pod

sub cmark-lib {
	state $lib;
	unless $lib {
		if $*VM.config<dll> ~~ /dll/ {
			die "Someone let me know...";
		}
		else {
			$lib = $*VM.platform-library-name(
				'cmark'.IO).Str;
		}
	}
	return $lib;
}

use NativeCall;

class CommonMark::Node is repr('CPointer') {
#`(
cmark_node *cmark_node_new(cmark_node_type type);
#cmark_node *cmark_node_new_with_mem(cmark_node_type type, cmark_mem *mem);
void cmark_node_free(cmark_node *node);
cmark_node *cmark_node_next(cmark_node *node);
cmark_node *cmark_node_previous(cmark_node *node);
cmark_node *cmark_node_parent(cmark_node *node);
cmark_node *cmark_node_first_child(cmark_node *node);
cmark_node *cmark_node_last_child(cmark_node *node);
)
sub cmark_node_new( int32 )
    returns CommonMark::Node
    is native('cmark') { * }
#sub cmark_node_new( int32, CommonMark::Mem )
#    returns CommonMark::Node
#    is native('cmark') { * }
sub cmark_node_free( CommonMark::Node )
    is native('cmark') { * }
sub cmark_node_next( CommonMark::Node )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_node_previous( CommonMark::Node )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_node_parent( CommonMark::Node )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_node_first_child( CommonMark::Node )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_node_last_child( CommonMark::Node )
    returns CommonMark::Node
    is native('cmark') { * }

	multi method new( :$type ) {
		cmark_node_new( $type );
	}
	#multi method new( :$type, CommonMark::Mem $mem ) {
	#	cmark_node_new( $type );
	#}
	submethod DESTROY {
		cmark_node_free( self );
	}
	method next {
		return cmark_node_next( self );
	}
	method previous {
		return cmark_node_previous( self );
	}
	method parent {
		return cmark_node_parent( self );
	}
	method first-child {
		return cmark_node_first_child( self );
	}
	method last-child {
		return cmark_node_last_child( self );
	}

### #`(
### void *cmark_node_get_user_data(cmark_node *node);
### int cmark_node_set_user_data(cmark_node *node, void *user_data);
### cmark_node_type cmark_node_get_type(cmark_node *node);
### const char *cmark_node_get_type_string(cmark_node *node);
### const char *cmark_node_get_literal(cmark_node *node);
### int cmark_node_set_literal(cmark_node *node, const char *content);
### int cmark_node_get_heading_level(cmark_node *node);
### int cmark_node_set_heading_level(cmark_node *node, int level);
### cmark_list_type cmark_node_get_list_type(cmark_node *node);
### int cmark_node_set_list_type(cmark_node *node, cmark_list_type type);
### cmark_delim_type cmark_node_get_list_delim(cmark_node *node);
### int cmark_node_set_list_delim(cmark_node *node, cmark_delim_type delim);
### int cmark_node_get_list_start(cmark_node *node);
### int cmark_node_set_list_start(cmark_node *node, int start);
### int cmark_node_get_list_tight(cmark_node *node);
### int cmark_node_set_list_tight(cmark_node *node, int tight);
### const char *cmark_node_get_fence_info(cmark_node *node);
### int cmark_node_set_fence_info(cmark_node *node, const char *info);
### const char *cmark_node_get_url(cmark_node *node);
### int cmark_node_set_url(cmark_node *node, const char *url);
### const char *cmark_node_get_title(cmark_node *node);
### int cmark_node_set_title(cmark_node *node, const char *title);
### const char *cmark_node_get_on_enter(cmark_node *node);
### int cmark_node_set_on_enter(cmark_node *node, const char *on_enter);
### const char *cmark_node_get_on_exit(cmark_node *node);
### int cmark_node_set_on_exit(cmark_node *node, const char *on_exit);
### int cmark_node_get_start_line(cmark_node *node);
### int cmark_node_get_start_column(cmark_node *node);
### int cmark_node_get_end_line(cmark_node *node);
### int cmark_node_get_end_column(cmark_node *node);
### )

sub cmark_node_get_user_data( CommonMark::Node )
    returns Pointer
    is native('cmark') { * }
sub cmark_node_set_user_data( CommonMark::Node, Pointer )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_type( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_type_string( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_get_literal( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_set_literal( CommonMark::Node, Str is encoded('utf8') )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_heading_level( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_set_heading_level( CommonMark::Node, int32 )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_list_type( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_set_list_type( CommonMark::Node, int32 )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_list_delim( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_set_list_delim( CommonMark::Node, int32 )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_list_start( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_set_list_start( CommonMark::Node, int32 )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_list_tight( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_set_list_tight( CommonMark::Node, int32 )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_fence_info( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_set_fence_info( CommonMark::Node, Str is encoded('utf8') )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_url( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_set_url( CommonMark::Node, Str is encoded('utf8') )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_title( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_set_title( CommonMark::Node, Str is encoded('utf8') )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_on_enter( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_set_on_enter( CommonMark::Node, Str is encoded('utf8') )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_on_exit( CommonMark::Node )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_node_set_on_exit( CommonMark::Node, Str is encoded('utf8') )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_start_line( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_start_column( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_end_line( CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_get_end_column( CommonMark::Node )
    returns int32
    is native('cmark') { * }

	multi method user-data {
		return cmark_node_get_user_data( self );
	}
	multi method user-data( Pointer $ptr ) {
		return cmark_node_set_user_data( self, $ptr );
	}
	method type {
		return cmark_node_get_type( self );
	}
	method type-string {
		return cmark_node_get_type_string( self );
	}
 	multi method literal {
 		return cmark_node_get_literal( self );
 	}
 	multi method literal( Str $str ) returns int32 {
 		return cmark_node_set_literal( self, $str );
 	}
 
 	multi method heading-level {
 		return cmark_node_get_heading_level( self );
 	}
 	multi method heading-level( int32 $level ) {
 		return cmark_node_set_heading_level( self, $level );
 	}
 
 	multi method list-type {
 		return cmark_node_get_list_type( self );
 	}
 	multi method list-type( int32 $type ) returns int32 {
 		cmark_node_set_list_type( self, $type );
 	}
 
 	multi method list-delim {
 		return cmark_node_get_list_delim( self );
 	}
 	multi method list-delim( int32 $delim ) returns int32 {
 		cmark_node_set_list_delim( self, $delim );
 	}
 
 	multi method list-start {
 		return cmark_node_get_list_start( self );
 	}
 	multi method list-start( int32 $delim ) returns int32 {
 		cmark_node_set_list_start( self, $delim );
 	}
 
 	multi method list-tight {
 		return cmark_node_get_list_tight( self );
 	}
 	multi method list-tight( int32 $delim ) returns int32 {
 		cmark_node_set_list_tight( self, $delim );
 	}
 
 	multi method fence-info {
 		return cmark_node_get_fence_info( self );
 	}
 	multi method fence-info( Str $info ) returns int32 {
 		cmark_node_set_fence_info( self, $info );
 	}
 
 	multi method url {
 		return cmark_node_get_url( self );
 	}
 	multi method url( Str $url ) returns int32 {
 		cmark_node_set_url( self, $url );
 	}
 
 	multi method title {
 		return cmark_node_get_title( self );
 	}
 	multi method title( Str $title ) {
 		return cmark_node_set_title( self, $title );
 	}
 
 	multi method on-enter {
 		return cmark_node_get_on_enter( self );
 	}
 	multi method on-enter( Str $enter ) {
 		cmark_node_set_on_enter( self, $enter );
 	}
 
 	multi method on-exit {
 		return cmark_node_get_on_exit( self );
 	}
 	multi method on-exit( Str $enter ) {
 		return cmark_node_set_on_exit( self, $enter );
 	}
 
 	method start-line {
 		return cmark_node_get_start_line( self );
 	}
 	method start-column {
 		return cmark_node_get_start_column( self );
 	}
 	method end-line {
 		return cmark_node_get_end_line( self );
 	}
 	method end-column {
 		return cmark_node_get_end_column( self );
 	}
#`(
void cmark_node_unlink(cmark_node *node);
int cmark_node_insert_before(cmark_node *node, cmark_node *sibling);
int cmark_node_insert_after(cmark_node *node, cmark_node *sibling);
int cmark_node_replace(cmark_node *oldnode, cmark_node *newnode);
int cmark_node_prepend_child(cmark_node *node, cmark_node *child);
int cmark_node_append_child(cmark_node *node, cmark_node *child);
void cmark_consolidate_text_nodes(cmark_node *root);
)
sub cmark_node_unlink( CommonMark::Node )
    is native('cmark') { * }
sub cmark_node_insert_before( CommonMark::Node, CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_insert_after( CommonMark::Node, CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_replace( CommonMark::Node, CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_prepend_child( CommonMark::Node, CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_node_append_child( CommonMark::Node, CommonMark::Node )
    returns int32
    is native('cmark') { * }
sub cmark_consolidate_text_nodes( CommonMark::Node )
    is native('cmark') { * }

 	method unlink {
 		cmark_node_unlink( self );
 	}
 
 	method insert-before( CommonMark::Node $node ) {
 		return cmark_node_insert_before( self, $node );
 	}
 
 	method insert-after( CommonMark::Node $node ) {
 		return cmark_node_insert_after( self, $node );
 	}
 
 	method replace( CommonMark::Node $node ) {
 		return cmark_node_replace( self, $node );
 	}
 
 	method prepend-child( CommonMark::Node $node ) {
 		return cmark_node_prepend_child( self, $node );
 	}
 
 	method append-child( CommonMark::Node $node ) {
 		return cmark_node_append_child( self, $node );
 	}
 
 	method consolidate-text-nodes {
 		cmark_consolidate_text_nodes( self );
 	}

#`(
char *cmark_render_xml(cmark_node *root, int options);
char *cmark_render_html(cmark_node *root, int options);
char *cmark_render_man(cmark_node *root, int options, int width);
char *cmark_render_commonmark(cmark_node *root, int options, int width);
char *cmark_render_latex(cmark_node *root, int options, int width);
)

sub cmark_render_xml( CommonMark::Node, int32 )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_render_html( CommonMark::Node, int32 )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_render_man( CommonMark::Node, int32, int32 )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_render_commonmark( CommonMark::Node, int32, int32 )
    returns Str is encoded('utf8')
    is native('cmark') { * }
sub cmark_render_latex( CommonMark::Node, int32, int32 )
    returns Str is encoded('utf8')
    is native('cmark') { * }

 	method render-xml( int32 $options ) {
 		return cmark_render_xml( self, $options );
 	}
 	method render-html( int32 $options ) {
 		return cmark_render_html( self, $options );
 	}
 	method render-man( int32 $options, int32 $width ) {
 		return cmark_render_man( self, $options, $width );
 	}
 	method render-commonmark( int32 $options, int32 $width ) {
 		return cmark_render_commonmark( self, $options, $width );
 	}
 	method render-latex( int32 $options, int32 $width ) {
 		return cmark_render_latex( self, $options, $width );
 	}
#`(
int cmark_node_check(cmark_node *node, FILE *out);
)
sub cmark_node_check( CommonMark::Node, int32 ) # FILE pointer
    returns int32
    is native('cmark') { * }

	# XXX Not quite sure how it'll work with the FD.
 	method check( int32 $file-ID ) {
 		return cmark_node_check( self, $file-ID );
 	}
}

class CommonMark:ver<0.0.5> {

#`( The original C library calls.
char *cmark_markdown_to_html(const char *text, size_t len, int options);
int32 cmark_version(void);
const char *cmark_version_string(void);

cmark_node *cmark_parse_document(const char *buffer, size_t len, int options);
#cmark_node *cmark_parse_file(FILE *f, int options);
)

sub cmark_markdown_to_html(
	Str $text is encoded('utf8'),
	size_t $len,
	int32 $options )
    returns Str is encoded('utf8')
    is native('cmark') { * }

sub cmark_version()
    returns int32
    is native('cmark') { * }

sub cmark_version_string()
    returns Str is encoded('utf8')
    is native('cmark') { * }

sub cmark_parse_document( Str is encoded('utf8'), size_t, int32 )
    returns CommonMark::Node
    is native('cmark') { * }

 	constant CMARK_OPT_DEFAULT = 0;
 	constant CMARK_OPT_SOURCEPOS = 1 +< 1;
 	constant CMARK_OPT_HARDBREAKS = 1 +< 2;
 	constant CMARK_OPT_SAFE = 1 +< 3;
 	constant CMARK_OPT_NOBREAKS = 1 +< 4;
 	constant CMARK_OPT_NORMALIZE = 1 +< 8; # Legacy
 	constant CMARK_OPT_VALIDATE_UTF8 = 1 +< 9;
 	constant CMARK_OPT_SMART = 1 +< 10;

	method to-html( Str $text, int32 $options = CMARK_OPT_DEFAULT ) {
		my $bytes = $text.encode('UTF-8').bytes;
		return cmark_markdown_to_html($text, $bytes, $options);
	}

	method version() returns int32 {
		return cmark_version();
	}

	method version-string() {
		return cmark_version_string();
	}

	method parse-document( Str $buffer, int32 $options ) {
		my $bytes = $buffer.encode('UTF-8').bytes;
		return cmark_parse_document( $buffer, $bytes, $options );
	}
}

class CommonMark::Iterator is repr('CPointer') {
#`(
cmark_iter *cmark_iter_new(cmark_node *root);
void cmark_iter_free(cmark_iter *iter);
cmark_event_type cmark_iter_next(cmark_iter *iter);
cmark_node *cmark_iter_get_node(cmark_iter *iter);
cmark_event_type cmark_iter_get_event_type(cmark_iter *iter);
cmark_node *cmark_iter_get_root(cmark_iter *iter);
void cmark_iter_reset(cmark_iter *iter, cmark_node *current,
         cmark_event_type event_type);
)
sub cmark_iter_new( CommonMark::Node )
    returns CommonMark::Iterator
    is native('cmark') { * }
sub cmark_iter_free( CommonMark::Iterator )
    is native('cmark') { * }
sub cmark_iter_next( CommonMark::Iterator )
    returns int32
    is native('cmark') { * }
sub cmark_iter_get_node( CommonMark::Iterator )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_iter_get_event_type( CommonMark::Iterator )
    returns int32
    is native('cmark') { * }
sub cmark_iter_get_root( CommonMark::Iterator )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_iter_reset( CommonMark::Iterator, CommonMark::Node, int32 )
    is native('cmark') { * }

 	method new( :$node ) {
 		cmark_iter_new( $node );
 	}

 	submethod DESTROY {
 		cmark_iter_free( self )
 	}
 
 	method next {
 		return cmark_iter_next( self );
 	}
 
 	method node {
 		return cmark_iter_get_node( self );
 	}
 
 	method event-type {
 		return cmark_iter_get_event_type( self );
 	}
 
 	method root {
 		return cmark_iter_get_root( self );
 	}
 
 	method reset( CommonMark::Node $current, int32 $event-type ) {
 		cmark_iter_reset( self, $current, $event-type );
 	}
}

class CommonMark::Parser is repr('CPointer') {
#`(
cmark_parser *cmark_parser_new(int options);
cmark_parser *cmark_parser_new_with_mem(int options, cmark_mem *mem);
void cmark_parser_free(cmark_parser *parser);
void cmark_parser_feed(cmark_parser *parser, const char *buffer, size_t len);
cmark_node *cmark_parser_finish(cmark_parser *parser);
#cmark_node *cmark_parse_document(const char *buffer, size_t len, int options);
#cmark_node *cmark_parse_file(FILE *f, int options);
)
sub cmark_parser_new( int32 )
    returns CommonMark::Parser
    is native('cmark') { * }
#sub cmark_parser_new_with_mem( int32, CommonMark::Mem )
#    returns CommonMark::Parser
#    is native('cmark') { * }
sub cmark_parser_free( CommonMark::Parser )
    is native('cmark') { * }
sub cmark_parser_finish( CommonMark::Parser )
    returns CommonMark::Node
    is native('cmark') { * }
sub cmark_parser_feed( CommonMark::Parser, Str is encoded('utf8'), size_t )
    is native('cmark') { * }

 	method new( int32 $options ) {
 		cmark_parser_new( $options );
 	}
 	#method new-with-mem( int32 $options, CommonMark::Mem $mem ) {
 	#	cmark_parser_new_with_mem( $options, $mem );
 	#}
 	submethod DESTROY {
 		cmark_parser_free( self );
 	}
 	method finish {
 		return cmark_parser_finish( self );
 	}
 	method feed( Str $buffer ) {
 		my $bytes = $buffer.encode('UTF-8').bytes;
 		cmark_parser_feed( self, $buffer, $bytes );
 	}
}

# vim: ft=perl6
