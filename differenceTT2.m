function dif = differenceTT2(t, tone, tap, bgnT, endT)
dif = [];
difs = 1;
ploc = 0;

for i = 1:size(tap,1)
    if tap(i)>=bgnT{t,2} && tap(i)<=endT{t,2}
        w = tap(i)-tone(:);
        [~, loc] = min(w(w > 0));
        if abs(loc-ploc) > 0.01
            dif(difs,1) = min(w(w > 0));
            difs = difs + 1;
            ploc = loc;
        end
    end
end
end