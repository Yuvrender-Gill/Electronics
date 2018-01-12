%Declaring a vecor x with with 100 steps
x = 0.00000001:0.1:1.99999999;


X = [x];
XR = [round(x,7, 'significant')];
absX = XR - X;
relX = rdivide(absX,X);

% Conisder y = log(x)

Y = [log(x)];
YR = [log(round(x,7, 'significant'))];
absY = YR - Y;
relY = rdivide(absY,Y);

%Calculating all the condition numbers for the given range
cond = rdivide(relY,relX);
max_cond = max(cond);
min_cond = min(cond);

M = horzcat(X', XR', relX', Y', YR' , relY' , cond');

% printing the outputs 
formatspec1 = '|| X: %d | XR: %d | relX: %d | Y: %d | YR: %d | relY: %d | Conditioning Numbers: %d ||\n ';
fprintf(formatspec1,M');
fprintf('|| Maximum Confitioning Number: %d || \n', max_cond);
fprintf('|| Minimum Confitioning Number: %d ||', min_cond);