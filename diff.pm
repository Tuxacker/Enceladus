#!"C:\xampp\perl\bin\perl.exe"

package diff;

use Time::HiRes;
use parser;
use strict;
use warnings;

sub differentiate{
	my @di = @_;
	my $lt;
	my $rt;
	
	while($di[$#di] =~ /,|\(/){
		pop(@di);
	}
	
	print "\n-------------\nDifferentiating Node:";
	print_array(@di);
	print " - Operator: $di[$#di]\n\n";
	
	# Differentiation of static functions
	if($di[$#di] =~ /l|q|b|s|c/){
		$rt = $#di - 1;
		$lt = get_beginning($rt, \@di);
			
		my @temp = @di[$lt .. $rt];
		my @ctemp = cleanup(@temp);
		
		print "Differentiating static function: $di[$#di], Parameters: ";
		print_array(@temp);
		print "\n";
		
		#ln(x)
		if($di[$#di] =~ /l/){	
			if(scalar(@ctemp) == 1){
				print "Differentiating ln\n";
				if($ctemp[0] =~ /x/){
					return ("1", "x", "/");
				} else {return;}
			} else {
				print "Chaining ln\n";
				my @dtemp = differentiate(@temp); 
				unshift(@dtemp, "/");
				unshift(@dtemp, @ctemp);
				unshift(@dtemp, "1");
				push(@dtemp, "*");
				return @dtemp;
			} 
		}
		
		
		
		#sqrt(x)
		elsif($di[$#di] =~ /q/){
			print "Differentiating sqrt\n";	
			if(scalar(@ctemp) == 1){
				if($ctemp[0] =~ /x/){
					return ("1", "x", "q", "2", "*", "/");
				} else {return;}
			} else {
				print "Chaining sqrt\n";	
				my @dtemp = differentiate(@temp); 
				unshift(@dtemp, ("q", "2", "*", "/"));
				unshift(@dtemp, @ctemp);
				unshift(@dtemp, "1");
				push(@dtemp, "*");
				return @dtemp;
			} 
		}
		
		
		
		#cbrt(x)
		elsif($di[$#di] =~ /b/){
			die "Not yet implemented!";
		}
		
		
		
		#sin(x)
		elsif($di[$#di] =~ /s/){
			print "Differentiating sin\n";	
			if(scalar(@ctemp) == 1){
				if($ctemp[0] =~ /x/){
					return ("x", "c");
				} else {return;}
			} else {
				print "Chaining sin\n";	
				my @dtemp = differentiate(@temp); 
				unshift(@dtemp, "c");
				unshift(@dtemp, @ctemp);
				push(@dtemp, "*");
				return @dtemp;
			}
		}
		
		
		
		#cos(x)
		elsif($di[$#di] =~ /c/){
			print "Differentiating cos\n";	
			if(scalar(@ctemp) == 1){
				if($ctemp[0] =~ /x/){
					return ("0", "1", "-", "x", "s", "*");
				} else {return;}
			} else {
				print "Chaining cos\n";	
				my @dtemp = differentiate(@temp); 
				unshift(@dtemp, ("s", "*"));
				unshift(@dtemp, @ctemp);
				unshift(@dtemp, ("0", "1", "-"));
				push(@dtemp, "*");
				return @dtemp;
			}
		}
	}
	
	
	
	#x^n and a^x
	elsif($di[$#di] =~ /\^/){	
		$rt = $#di;
		$lt = get_beginning($rt, \@di);
			
		my @exptemp = @di[$lt .. $rt-1];
		my @cexptemp = cleanup(@exptemp);
		
		my @basetemp = @di[0 .. $lt];
		my @cbasetemp = cleanup(@basetemp);
		
		
		
		#x^n
		if(scalar(@cexptemp) == 1 && $cexptemp[0] =~ /\d/){
			if(scalar(@cbasetemp) == 1){
				print "Differentiating x^n\n";
				if($cbasetemp[0] =~ /x/){
					return ("x", $cexptemp[0] - 1, "^", $cexptemp[0], "*");
				} else {return;}
			} else {
				print "Chaining x^n\n";
				my @dtemp = differentiate(@basetemp); 
				unshift(@dtemp, ($cexptemp[0] - 1, "^", $cexptemp[0], "*"));
				unshift(@dtemp, @cbasetemp);
				push(@dtemp, "*");
				return @dtemp;	
			}
		} elsif(scalar(@cbasetemp) > 1){
			die "Error: Complexity cap exceeded!";
		}
		
		
		
		#a^x
		elsif(scalar(@cexptemp) == 1 && $cexptemp[0] =~ /x/){
			if($basetemp[0] =~ /e/){
				print "Differentiating e^x\n";
				return ("e", "x", "^");
			} elsif($basetemp[0] =~ /\d/){
				print "Differentiating a^x\n";
				return ($basetemp[0], "x", "^", $basetemp[0], "l", "*");
			} else {
				die "Illegal Expression Error!";
			}
		} else{
			if($basetemp[0] =~ /e/){
				print "Chaining e^x\n";
				my @dtemp = differentiate(@exptemp); 
				unshift(@dtemp, "^");
				unshift(@dtemp, @cexptemp);
				unshift(@dtemp, "e");
				push(@dtemp, "*");
				return @dtemp;
			} elsif($basetemp[0] =~ /\d/){
				print "Chaining a^x\n";
				my @dtemp = differentiate(@basetemp); 
				unshift(@dtemp, "^");
				unshift(@dtemp, @cbasetemp);
				unshift(@dtemp,  $basetemp[0]);
				push(@dtemp, ("*", $basetemp[0], "l", "*"));
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		}
	}
	
	
	
	#g(x) * h(x)
	elsif($di[$#di] =~ /\*/){
		print "Differentiating n*m\n";	
		$rt = $#di;
		$lt = get_beginning($rt, \@di);
			
		my @btemp = @di[$lt .. $rt-1];
		my @cbtemp = cleanup(@btemp);
		
		my @atemp = @di[0 .. $lt];
		my @catemp = cleanup(@atemp);
		
		if(scalar(@catemp) == 1 && scalar(@catemp) == 1){
			print "n=1, m=1\n";
			if($catemp[0] =~ /\d/ && $cbtemp[0] =~ /\d/){
				return;
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /\d/){
				return ($cbtemp[0]);
			} elsif($catemp[0] =~ /\d/ && $cbtemp[0] =~ /x/){
				return ($catemp[0]);
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /x/){
				return ("x", "2", "*");
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@catemp) == 1){
			print "n=1, m>1\n";
			if($catemp[0] =~ /\d/){
				my @dtemp = differentiate(@btemp); 
				push(@dtemp, ($catemp[0], "*"));
				return @dtemp;
			} elsif($catemp[0] =~ /x/){
				my @dtemp = differentiate(@btemp); 
				push(@dtemp, ("x", "*"));
				push(@dtemp, @cbtemp);
				push(@dtemp, "+");
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@cbtemp) == 1){
			print "n>1, m=1\n";
			if($cbtemp[0] =~ /\d/){
				my @dtemp = differentiate(@atemp); 
				push(@dtemp, $cbtemp[0], "*");
				return @dtemp;
			} elsif($cbtemp[0] =~ /x/){
				my @dtemp = differentiate(@atemp); 
				push(@dtemp, ("x", "*"));
				push(@dtemp, @catemp);
				push(@dtemp, "+");
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} else {
			print "n>1, m>1\n";
			my @ftemp = differentiate(@btemp); 
			my @dtemp = differentiate(@atemp);
			push(@dtemp, @cbtemp);
			push(@dtemp, "*");
			push(@dtemp, @ftemp);
			push(@dtemp, @catemp);
			push(@dtemp, ("*", "+"));
			return @dtemp;				 
		}
	}
	
	
	
	#g(x) / h(x)
	elsif($di[$#di] =~ /\//){
		print "Differentiating n/m\n";	
		$rt = $#di;
		$lt = get_beginning($rt, \@di);
			
		my @btemp = @di[$lt .. $rt-1];
		my @cbtemp = cleanup(@btemp);
		
		my @atemp = @di[0 .. $lt];
		my @catemp = cleanup(@atemp);
		
		if(scalar(@catemp) == 1 && scalar(@catemp) == 1){
			print "n=1, m=1\n";
			if($catemp[0] =~ /\d/ && $cbtemp[0] =~ /\d/){
				return;
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /\d/){
				return ("1", $cbtemp[0], "/");
			} elsif($catemp[0] =~ /\d/ && $cbtemp[0] =~ /x/){
				return ("0", "1", "x", "2", "^", "/", $catemp[0], "*", "-");
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /x/){
				return (1);
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@catemp) == 1){
			print "n=1, m>1\n";
			if($catemp[0] =~ /\d/){
				my @dtemp = differentiate(@btemp);
				unshift(@dtemp, ("/", "^", "2"));
				unshift(@dtemp, @cbtemp);
				unshift(@dtemp, ("1", "0"));  
				push(@dtemp, ($catemp[0], "*", "*", "-"));
				return @dtemp;
			} elsif($catemp[0] =~ /x/){
				my @dtemp = differentiate(@btemp);
				unshift(@dtemp, ("/", "^", "2"));
				unshift(@dtemp, @cbtemp);
				unshift(@dtemp, ("1", "0"));  
				push(@dtemp, ("x", "*", "*", "-", "1"));
				unshift(@dtemp, @cbtemp);
				unshift(@dtemp, ("/", "+"));
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@cbtemp) == 1){
			print "n>1, m=1\n";
			if($cbtemp[0] =~ /\d/){
				my @dtemp = differentiate(@atemp); 
				push(@dtemp, $cbtemp[0], "/");
				return @dtemp;
			} elsif($cbtemp[0] =~ /x/){
				my @dtemp = differentiate(@atemp); 
				push(@dtemp, ("1", "x", "/", "*"));
				push(@dtemp, @catemp);
				push(@dtemp, ("0", "1", "x", "2", "^", "/", "-", "*", "+"));
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} else {
			print "n>1, m>1\n";
			my @ftemp = differentiate(@btemp); 
			my @dtemp = differentiate(@atemp);
			push(@dtemp, @cbtemp);
			push(@dtemp, "*");
			push(@dtemp, @ftemp);
			push(@dtemp, @catemp);
			push(@dtemp, ("*", "-"));
			push(@dtemp, @cbtemp);
			push(@dtemp, ("2", "^", "/"));
			return @dtemp;				 
		}
	}
	
	
	
	#g(x) + h(x)
	elsif($di[$#di] =~ /\+/){
		print "Differentiating n+m\n";	
		$rt = $#di;
		$lt = get_beginning($rt, \@di);
		print "Operand Separator at ID: $lt\n";
			
		my @btemp = @di[$lt .. $rt-1];
		my @cbtemp = cleanup(@btemp);
		
		my @atemp = @di[0 .. $lt];
		my @catemp = cleanup(@atemp);
		
		if(scalar(@catemp) == 1 && scalar(@catemp) == 1){
			print "n=1, m=1\n";
			if($catemp[0] =~ /\d/ && $cbtemp[0] =~ /\d/){
				return;
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /\d/){
				return ("1");
			} elsif($catemp[0] =~ /\d/ && $cbtemp[0] =~ /x/){
				return ("1");
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /x/){
				return ("2");
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@catemp) == 1){
			print "n=1, m>1\n";
			if($catemp[0] =~ /\d/){
				return differentiate(@btemp);
			} elsif($catemp[0] =~ /x/){
				my @dtemp = differentiate(@btemp); 
				push(@dtemp, ("1", "+"));
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@cbtemp) == 1){
			print "n>1, m=1  $cbtemp[0]\n";
			if($cbtemp[0] =~ /\d/){
				return differentiate(@atemp);
			} elsif($cbtemp[0] =~ /x/){
				my @dtemp = differentiate(@atemp); 
				push(@dtemp, ("1", "+"));
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} else{
			print "n>1, m>1\n";
			my @dtemp = differentiate(@atemp); 
			push(@dtemp, differentiate(@btemp));
			push(@dtemp, "+");
			return @dtemp;
		}
	}
	
	
	
	#g(x) - h(x)
	elsif($di[$#di] =~ /-/){
		print "Differentiating n-m\n";	
		$rt = $#di;
		$lt = get_beginning($rt, \@di);
			
		my @btemp = @di[$lt .. $rt-1];
		my @cbtemp = cleanup(@btemp);
		
		my @atemp = @di[0 .. $lt];
		my @catemp = cleanup(@atemp);
		
		if(scalar(@catemp) == 1 && scalar(@catemp) == 1){
			print "n=1, m=1\n";
			if($catemp[0] =~ /\d/ && $cbtemp[0] =~ /\d/){
				return;
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /\d/){
				return ("1");
			} elsif($catemp[0] =~ /\d/ && $cbtemp[0] =~ /x/){
				return ("0", "1", "-");
			} elsif($catemp[0] =~ /x/ && $cbtemp[0] =~ /x/){
				return;
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@catemp) == 1){
			print "n=1, m>1\n";
			if($catemp[0] =~ /\d/){
				my @dtemp = differentiate(@btemp);
				unshift(@dtemp, "0");
				push(@dtemp, "-");
			} elsif($catemp[0] =~ /x/){
				my @dtemp = differentiate(@btemp); 
				unshift(@dtemp, "1");
				push(@dtemp, "-");
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} elsif(scalar(@cbtemp) == 1){
			print "n>1, m=1\n";
			if($cbtemp[0] =~ /\d/){
				return differentiate(@atemp);
			} elsif($cbtemp[0] =~ /x/){
				my @dtemp = differentiate(@atemp); 
				push(@dtemp, ("1", "-"));
				return @dtemp;
			} else {
				die "Illegal Expression Error!";
			}
		} else{
			print "n>1, m>1\n";
			my @dtemp = differentiate(@atemp); 
			push(@dtemp, differentiate(@btemp));
			push(@dtemp, "-");
			return @dtemp;
		}
	} else {
		die "Internal Error (code 5), aborting...";
	}
}





sub get_beginning{
	print "\nCalling Subroutine:\n";
	my $rtid = $_[0];
	print "Right Index: $rtid\n";
	my @expr = @{$_[1]};
	print "Source Array: ";
	print_array(@expr);
	print "\nValue of $rtid: $expr[$rtid], ";
	my $id;
	
	if($expr[$rtid] =~ /.(\d\d\d\d)/){
		$id = $1;
		print "Operator ID: $id\n";
	} else {die "Internal Error (code 3), aborting...";}
	
	for(my $i = --$rtid; $i >= 0; $i--){
		if($expr[$i] =~ /$id/){
			print "Found ID $id at Index $i with value: $expr[$i]\n\n";
			return $i;
		}
	}
	die "Internal Error (code 4), aborting...";
}


sub reverse_notation{
	my @input = @_;
	my @stack;
	
	foreach my $token(@input){
		if($token =~ /\d|x|e/){
			push(@stack, $token);
		} elsif($token =~ /\+|-|\*|\/|\^/){
			if(scalar(@stack) < 2){
				die "Internal Error (code 6), aborting...";
			}
			my $right = pop(@stack);
			my $left = pop(@stack);
			push(@stack, "("."$left"."$token"."$right".")");
		} elsif($token =~ /l|q|b|s|c/){
			my $arg = pop(@stack);
			push(@stack, "$token"."("."$arg".")");
		} else {
			die "Invalid Token Error!";
		}
	}
	
	if(scalar(@stack) > 1){
		die "Internal Error (code 7), aborting...";
	}
	return $stack[0];
}


sub cleanup{
	my @input = @_;
	
	for(my $i = 0; $i <= $#input; $i++){
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

sub print_array{
	my @input = @_;
	foreach my $t (@input){
		print "[$t]";
	}
}

sub derive_main{
	open(my $log, '>', 'last_expr.txt');
	select $log;
	my $in = $_[0];
	my @func = lexer::function_split($in);
	my @header = lexer::header_check($func[0]);
	my $expr = lexer::token_prep($func[1], $header[1]);
	$expr = diff::reverse_notation(diff::differentiate(parser::shunting_yard(parser::prep_function($expr))));
	select STDOUT;
	$expr =~ s/x/$header[1]/;
	$expr = $header[0] . "(" . $header[1] . ")=" . $expr;
	return $expr;
}

return (1);