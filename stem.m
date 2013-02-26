
%load('smap.mat')
stemmedSmap = cellfun(@(x) porterStemmer(x), smap, 'UniformOutput', false);
[smapUnique, uniqToSmap, smapToUniq] = unique(stemmedSmap, 'first');
save('stemmedSmap.mat', 'smapUnique', 'uniqToSmap',...
     'smapToUniq', 'stemmedSmap')

