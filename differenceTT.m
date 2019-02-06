function dif = differenceTT(t, tone, tap, bgnT, endT)
dif = [];
difs = 1;
for i = 1:size(tap,1)
    if tap(i)>=bgnT{t,2} && tap(i)<=endT{t,2}
        
        [~,idx] = min(abs(tone(:)-tap(i)));
        dif(difs,1) = tap(i)-tone(idx);
        difs = difs + 1;
    end
end
end