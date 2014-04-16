#!"C:\xampp\perl\bin\perl.exe"

package lexer;

use strict;
use warnings;

#ln 	= l
#e  	= e
#sqrt   = q
#cbrt   = b
#sin	= s
#cos	= c


sub function_split{
	my $input = $_[0];
	
	return my @func = ($`, $') if $input =~ /=/ or die "[Lexical Error] Invalid Statement: No \'=\' found\n";
}

sub header_check{
	my $input = $_[0];
	my $name;
	my $variable;
	
	$name = $1 if $input =~ /(\w+)/ or die "[Lexical Error] Invalid Statement: Wrong function name\n";
	$variable = $1 if $input =~ /\(([A-Za-z])\)/ or die "[Lexical Error] Invalid Statement: No brackets or invalid variable name\n";
	return my @header = ($name, $variable);
}

sub token_prep{
	my $input = $_[0];
	my $var = $_[1];
	
	$input =~ s/\s// while $input =~ /\s/;
	$input =~ s/$var/x/i;
	$input =~ s/ln/l/ while $input =~ /ln/;
	$input =~ s/sqrt/q/ while $input =~ /sqrt/;
	$input =~ s/cbrt/b/ while $input =~ /cbrt/;
	$input =~ s/sin/s/ while $input =~ /sin/;
	$input =~ s/cos/c/ while $input =~ /cos/;
	$input =~ s/(\d)x/$1*x/ix while $input =~ /(\d)x/;
	$input =~ s/^-/0-/ix while $input =~ /^-/;
	$input =~ s/\(-/(0-/ix while $input =~ /\(-/;
	return $input;
}

return (1);