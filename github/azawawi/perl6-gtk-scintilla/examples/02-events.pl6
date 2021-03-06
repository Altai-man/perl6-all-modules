#!/usr/bin/env perl6

use v6;

use lib $*PROGRAM.parent.parent.child("lib").Str;
use GTK::Simple::App;
use GTK::Simple::VBox;
use GTK::Simple::Button;
use GTK::Scintilla;
use GTK::Scintilla::Editor;

my $app = GTK::Simple::App.new( title => "GTK::Scintilla Events Demo" );

my $editor = GTK::Scintilla::Editor.new;
$editor.size-request(500, 300);
$app.set-content(GTK::Simple::VBox.new(
    $editor,
    my $insert-text-top-button    = GTK::Simple::Button.new(
        :label("Insert Top")
    ),
    my $insert-text-bottom-button = GTK::Simple::Button.new(
        :label("Insert Bottom")
    ),
    my $zoom-in-button            = GTK::Simple::Button.new(
        :label("Zoom In")
    ),
    my $zoom-out-button           = GTK::Simple::Button.new(
        :label("Zoom Out")
    ),
));

$insert-text-top-button.clicked.tap: {
    $editor.insert-text(0, "# a top comment\n");
};

$insert-text-bottom-button.clicked.tap: {
    my $length = $editor.text-length;
    say "Length: $length";
    $editor.insert-text($length, "# a bottom comment\n");
};

$zoom-in-button.clicked.tap: {
    $editor.zoom-in;
};

$zoom-out-button.clicked.tap: {
    $editor.zoom-out;
};

# Long line API
$editor.edge-mode(Line);
printf("edge-mode   = %s\n",   $editor.edge-mode.perl);
$editor.edge-column(80);
printf("edge-column = %d\n",   $editor.edge-column);
printf("edge-color  = 0x%x\n", $editor.edge-color);

# Zoom API
$editor.zoom(10);
printf("zoom    = %d\n", $editor.zoom());

$editor.style-clear-all;
$editor.lexer(SCLEX_PERL);
$editor.style-foreground(SCE_PL_COMMENTLINE, 0x008000);
$editor.style-foreground(SCE_PL_POD,         0x008000);
$editor.style-foreground(SCE_PL_NUMBER,      0x808000);
$editor.style-foreground(SCE_PL_WORD,        0x800000);
$editor.style-foreground(SCE_PL_STRING,      0x800080);
$editor.style-foreground(SCE_PL_OPERATOR, 1);
$editor.style-bold(SCE_PL_COMMENTLINE, True);
$editor.text(q{
# A Perl comment
use Modern::Perl;

say "Events Demo";
});

printf("Line #1 length = %d\n", $editor.line-length(1));
printf("Line #1 text = '%s'\n", $editor.line(1));

$editor.save-point;

$editor.show;
$app.run;
