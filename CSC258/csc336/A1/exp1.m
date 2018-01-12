for z = -25:25
    y = [z, exp1(z), exp(z), (exp1(z) - exp(z))/exp(z)];
    formatspec = '| X: %d | exp1(x): %d | exp(x): %d | Relative Error: %d | \n';
    fprintf(formatspec,y);
   
end

function out = exp1(x)

n = 0;
expo = 1;
prev_sum = 0;
while prev_sum ~= expo
    prev_sum = prev_sum + ((x^n)/(factorial(n)));
    n = n+1;
    expo = expo + ((x^n)/(factorial(n)));
end
out = expo;

end