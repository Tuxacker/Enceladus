package parser;

use strict;
use warnings;

sub prep_function{
	my $input = $_[0];
	my @stack;
	
	@stack = split(//, $input);
	
	for(my $i = 1; $i <= $#stack; $i++){
		if($stack[$i] =~ /\d/ && $stack[$i-1] =~ /\d/){
			$stack[$i-1] = $stack[$i-1] * 10 + $stack[$i];
			splice(@stack,$i,1);
			$i--;
		}
	}
	return @stack;
}

sub shunting_yard{
	my @input = @_;
	my @stack;
	my @op;
	
	foreach my $token (@input){
		if($token =~ /\d|x|e/){
			push(@stack, $token);
		} elsif($token =~ /l|q|b|s|c/){
			push(@op, $token);
		} elsif($token =~ /\+|-|\*|\/|\^/){
			my $marker = marker_hash();
			$token .= $marker;
			#push(@stack, "," . $marker);
			while(defined $op[0] && precedence($token) < precedence($op[$#op])){
				if ($op[$#op] =~ /\(/) {last;}
				push(@stack, pop(@op));
			}
			push(@stack, "," . $marker);
			push(@op, $token);
		} elsif($token =~ /\(/){
			$token .= marker_hash();
			push(@op, $token);
			push(@stack, $token);
		} elsif($token =~ /\)/){
			while(defined $op[0] && $op[$#op] !~ /\(/){
				push(@stack, pop(@op));
			}
			if(!defined $op[0]){
				print "[Grammatical Error] Syntax Error (Code 1): Missing Parenthesis\n";
			}
			push(@stack, pop(@op));
			#pop(@op);		
			if(defined $op[0] && $op[$#op] =~ /l|q|b|s|c/){
				push(@stack, pop(@op));	
			}
		}
	}
	for(my $i = $#op; $i >= 0; $i--){
		print "[Grammatical Error] Syntax Error (Code 2): Missing Parenthesis\n" if $op[$i] =~ /\(|\)/;
		push(@stack, pop(@op));
	}
	return @stack;
}

sub precedence{
	my $op = $_[0];

	if($op =~ /\+|-/){
		return 2;
	} elsif($op =~ /\*|\//){
		return 3;
	} elsif($op =~ /\^/){
		return 4;
	} else {
		return 5;	
	}
}

sub marker_hash{
	return int(rand(5000)) + 2000;
}

sub cleanup_internal{
	my @input = @_;
	
	for(my $i = 1; $i <= $#input; $i++){
		if($input[$i] =~ /,|\(/){
			splice(@input,$i,1);
			$i--;
		}
		if($input[$i] =~ /\+|-|\*|\/|\^/){
			while($input[$i] =~ /\d/){
				$input[$i] =~ s/\d//;
			}
		}
	}
	return @input;
}

return (1);