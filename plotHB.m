function nHbT = plotHB(t, hbtime, bgnT, endT)
nHbT = 0;
for i = 1:size(hbtime,1)
    
    if (hbtime(i,1)>=bgnT{1,2} && hbtime(i,1)<=endT{1,2})
        
        nHbT = nHbT+1;
        verticle(hbtime(i,1), 'red')
        
    end
end
end