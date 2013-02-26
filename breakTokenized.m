matObj = matfile('tokenized.mat');
display('finished loading tokenized.mat')

tokens = matObj.tokens(3,:);
save('tokens.mat', 'tokens');
display('finished saving tokens.mat')

scnt = matObj.scnt(:,:);
save('scnt.mat','scnt');
display('finished saving scnt.mat')

smap = matObj.smap(:,:);
save('smap.mat','smap');
display('finished saving smap.mat')
