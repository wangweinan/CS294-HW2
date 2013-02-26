% Sentiment Scorer with Linear Regression

%load('data/tokenized.mat')

%load('tokens.mat', 'tokens');
%load('scnt.mat', 'scnt');
%load('smap.mat', 'smap');

%load('stopwords.mat', 'stopWordIndexes');
%load('stemmedSmap.mat', 'smapUnique', 'uniqToSmap',...
%     'smapToUniq', 'stemmedSmap');

dictSize = length(smap);

% tokens is a 3xN matrix, but the first two rows are useless.
% Get rid of the first two rows.
% This should reduce the amount of memory required significantly.
tokens = tokens(3, :);

% Find the token index for the common tokens.
%TOKEN_REVIEW_BEGIN = strcmp('<review>', smap);
%TOKEN_REVIEW_END = strcmp('</review>', smap);
TOKEN_RATING_BEGIN = strcmp('<rating>', smap);
%TOKEN_RATING_END = strcmp('</rating>', smap);
TOKEN_REVIEW_TEXT_BEGIN = strcmp('<review_text>', smap);
TOKEN_REVIEW_TEXT_END = strcmp('</review_text>', smap);

% Extract rating positions and find the total number of reviews.
reviewTextBeginPositions = find(tokens == TOKEN_REVIEW_TEXT_BEGIN);
reviewTextEndPositions = find(tokens == TOKEN_REVIEW_TEXT_END);
numReviews = length(reviewTextBeginPositions);

Xdefault = sparse(1 + dictSize, numReviews);
XnoStopWord = sparse(1 + dictSize, numReviews);
Xstemmed = sparse(1 + dictSize, numReviews);

map = containers.Map('KeyType', 'char', 'ValueType', 'logical');
uniqueReviews = logical([]);

for i = 1 : numReviews
    
    % report progress
    if mod(i, 10000) == 0
        i
        length(uniqueReviews)
    end
    
    reviewTexts = tokens(reviewTextBeginPositions(i) : ...
                         reviewTextEndPositions(i));
    
    % skip the review if it has been observed before.
    hashkey = mat2str(reviewTexts(1 : min(10, end)));
    if ~isKey(map, hashkey)
        map(hashkey) = true;
        uniqueReviews = [uniqueReviews; i];
        
        % stop words
        reviewStopWords = double(setdiff(reviewTexts, stopWordIndexes));
        
        % stemming
        textLen = length(reviewTexts);
        reviewStemmed = ones(textLen);
        for j = 1 : textLen
            reviewStemmed(j) = smapToUniq(reviewTexts(j));
        end
        
        Xdefault(:, i) = [1; sparse(double(reviewTexts), 1, 1, ...
            dictSize, 1)];
        Xstemmed(:, i) = [1; sparse(double(reviewStemmed), 1, 1, ...
            dictSize, 1)];
        Xstopwords(:, i) = [1; sparse(double(reviewStopWords), 1, 1, ...
            dictSize, 1)];
    end
end

display('uniqueReviews: ')
display(length(uniqueReviews))

% process y.
% Extract ratings (assume all ratings are integers).
ratingPositions = find(tokens == TOKEN_RATING_BEGIN);
y = cell2mat(smap(tokens(ratingPositions + 1))) - '0';
yuniq = y(uniqueReviews);


Xuniq = Xdefault(:, uniqueReviews);
save('data/model-default.mat', 'Xuniq', 'yuniq');

Xuniq = Xstemmed(:, uniqueReviews);
save('data/model-stemmed.mat', 'Xuniq', 'yuniq');

Xuniq = Xstopwords(:, uniqueReviews);
save('data/model-stopwords.mat', 'Xuniq', 'yuniq');




