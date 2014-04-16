#!"C:\xampp\perl\bin\perl.exe"

use strict;
use warnings;

use lexer;
use parser;
use diff;

use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

my $q = new CGI;

print $q->header;
print $q->start_html(
	-title => "An example web page",
	-style => { 
 	-src => 'css/main.css' 
 	},
);

print "<img src=\"img/logo.png\" align=\"middle\" class=\"displayed\">";
print "Please type in your function:";
print $q->start_form(-name=>'query', -method=>'get');
print $q->textfield(-name=>'input',-size=>100, -maxlength=>200);
print $q->submit(-name=>'send', -value=>'Submit');
print $q->end_form;

if (defined($q->param('input'))){
my $in = $q->param('input');
my $expr = diff::derive_main($in);

print "The first derivate of $in is $expr";
}

print $q->end_html;



exit 0;