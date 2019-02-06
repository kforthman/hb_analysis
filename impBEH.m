function BEHdata = impBEH(sub, ses, R, inDirect)
BEHdata = myImportTaps(sub, ses, R, inDirect);
BEHdata = table2dataset(BEHdata);
BEHdata.result = nominal(BEHdata.result);