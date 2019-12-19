# 나이브 베이즈 알고리즘
# = 훈련 데이터를 활용해 변수(특징) 값이 제공하는 증거를 기반으로 결과가 관측될 확률을 계산. 
# 알고리즘이 레이블이 없는 데이터에 적용될 때 결과가 관측될 확률을 이용해서 
# 새로운 변수(특징)에 가장 유력한 클래스를 예측

# 활용 분야 : 스팸메일 분류, 네트워크 침입 or 비 정상적 행위 탐지, 관찰된 증상에 대한 의학적 질병 관찰 등

# ==========================================================================================================

# 나이브 베이즈 알고리즘을 이용한 스팸 메시지 분류

# 데이터 준비
sms_raw = read.csv("data/sms_spam.csv", stringsAsFactors = F, encoding = "UTF-8")
str(sms_raw)
head(sms_raw)

# type 변수를 factor로
sms_raw$type = factor(sms_raw$type)
str(sms_raw$type)
table(sms_raw$type)
prop.table(table(sms_raw$type))

# Text Mining : sms에 포함된 단어 분석
install.packages("tm")
library(tm)
search()

# sms 전집(Corpus)을 생성
sms_corpus = VCorpus(VectorSource(sms_raw$text))

# 전집(Corpus) 확인
print(sms_corpus)
sms_corpus[[1]] # --- 구조 확인
sms_corpus[[1]]$content # --- 내용 확인
sms_corpus[[1]]$meta # --- 메타데이터 확인

# 모든 sms 내용을 소문자로 변환해보자.
# corpus 객체의 content만 소문자로 변환 
# 변환 함수가 tm 패키지 내에 없는 함수라면, tm_map(corpus, content_transformer(함수)) 형식으로 호출.
# 여기서 'tolower'함수는 tm 패키지 내에 있지 않기 때문에 content_transformer(tolower)로 호출.
# 변환 함수가 tm 패키지 내에 있는 함수라면, tm_map(corpus, 함수) 형식으로 호출
sms_corpus_clean = tm_map(x = sms_corpus, content_transformer(tolower))
sms_corpus_clean[[1]]$content
sms_corpus_clean[[1073]]$content

# 숫자 제거 tm_map(데이터프레임, removeNumbers)
sms_corpus_clean = tm_map(sms_corpus_clean, removeNumbers)
sms_corpus_clean[[1]]
sms_corpus_clean[[4]]$content

# stopwords(a, an, the, to, ...) 제거 [stopwords : 의미없는 단어들]
# tm_map(데이터프레임, removeWords, stopwords())
stopwords()
sms_corpus_clean = tm_map(sms_corpus_clean, removeWords, stopwords())
sms_corpus_clean[[1]]
sms_corpus_clean[[4]]$content
sms_corpus_clean[[1072]]$content

# Punctuation(구두점) 제거 [구두점 : , / . / ! / ? /...]
# tm_map(데이터프레임, removePunctuation)
sms_corpus_clean = tm_map(sms_corpus_clean, removePunctuation)
sms_corpus_clean[[1]]$content
sms_corpus_clean[[1072]]$content

# 단어 또는 구두점등의 제거로 발생한 불 필요한 공백 제거
# tm_map(데이터프레임, stripWhitespace)
sms_corpus_clean = tm_map(sms_corpus_clean, stripWhitespace)
sms_corpus_clean[[1072]]$content

# 형태소 분석

# 'SnowballC' 패키지 설치 & 로드
install.packages("SnowballC")
library(SnowballC)

# wordStem() : 단어의 어근과 어미를 분리해, 어근만 리턴.
wordStem(c("learn", "learning", "learned", "learner", "learns"))
# 결과 : "learn"   "learn"   "learn"   "learner" "learn" (---> learner은 명사)
wordStem(c("play", "plays", "playing", "played"))
# 결과 : "plai" "plai" "plai" "plai" (---> 완벽한것은 아님)

# stemDocument : SnowballC::wordStem()을 사용해, 같은 결과를 리턴.
sms_corpus_clean = tm_map(sms_corpus_clean, stemDocument)
sms_corpus_clean[[1072]]$content
sms_corpus_clean[[4]]$content

# Document Term Matrix(DTM, 문서 단어 행렬) 만들기

# 행 : document(sms, email 등의 내용) --- i love you, how are you
# 열 : 모든 문서에서 추출한 단어들 --- i, love, you, how, are, you
# 각 값 : 문장에서 해당 단어 등장 횟수  
sms_dtm = DocumentTermMatrix(sms_corpus_clean)
str(sms_dtm)

# DTM을 이용해 학습 데이터 세트(75%) / 테스트 데이터 세트(25%) 생성.
sms_dtm_train = sms_dtm[1:4169, ]
sms_dtm_test = sms_dtm[4170:5559, ]
str(sms_dtm_train) # nrow : int 4169 / ncol : int 6539
str(sms_dtm_test) # nrow : int 1390 / ncol : int 6539

# 학습 데이터 세트 레이블 / 테스트 데이터 세트 레이블 생성
sms_train_label = sms_raw[1:4169, 1]
sms_test_label = sms_raw[4170:5559, 1]
table(sms_train_label) 
table(sms_test_label)

# DTM은 '희소행렬(Sparse Matrix)' : 행렬의 대부분 원소들의 값은 0이고, 0이 아닌 값의 원소들은 희소함.
# 그렇다면, DTM에서 자주 사용(등장)되는 단어(Term)들만 선택해보자.

# DTM에서 적어도 n번 이상 등장하는 단어 목록
freq_terms = findFreqTerms(sms_dtm_train, lowfreq = 5)

# 적어도 n번 이상 등장하는 단어들의 DTM
sms_dtm_freq_train = sms_dtm_train[, freq_terms] # 행은 sms_dtm_train의 전체 행, 열은 freq_terms의 목록으로 되는것.
sms_dtm_freq_test = sms_dtm_test[, freq_terms] # 행은 sms_dtm_test의 전체 행, 열은 freq_terms의 목록으로 되는것.
str(sms_dtm_freq_train) # nrow : int 4169 / ncol : int 1137
str(sms_dtm_freq_test) # nrow : int 1390 / ncol : int 1137
# sms_dtm_train과 sms_dtm_test에 비해 열 개수가 변화함.

# 나이브 베이즈 알고리즘 함수는 '명목형 변수'들만 처리 가능하다.
# 명목형 변수 : 크기 비교가 불가능한 범주형 변수.(ex)남자/여자, 좌파/우파 등)
# 따라서, DTM에서 각 원소의 값이 0보다 크면 "Y", 그렇지 않으면 "N" 으로 변환하자.
# 변환 함수 구현
convert_content = function(x){
  x = ifelse(x > 0, "Y", "N")
  return(x)
}

x = 123
convert_content(123)
x1 = c(1, 2, 0, 3)
convert_content(x1)

# 변환
# MARGIN = 1 ---> 함수(FUN)에 X의 '행'을 파라미터로 넘겨주겠다.
# MARGIN = 2 ---> 함수(FUN)에 X의 '열'을 파라미터로 넘겨주겠다.
sms_train = apply(X = sms_dtm_freq_train, 
                  MARGIN = 2,
                  FUN = convert_content)
sms_test = apply(X = sms_dtm_freq_test,
                 MARGIN = 2,
                 FUN = convert_content)
str(sms_train)
str(sms_test)

# 나이브 베이즈 분류 알고리즘을 구현안 패키지 설치 & 로드
install.packages("e1071")
library(e1071)

# 학습 데이터 세트를 이용해 분류기 생성
sms_classifier = naiveBayes(sms_train, sms_train_label)

# 분류기를 사용해 테스트 데이터 세트의 분류 결과 예측
sms_pred = predict(sms_classifier, sms_test)
sms_pred

table(sms_pred) #  ham 1231 / spam 159
prop.table(table(sms_pred)) # ham 0.8856115 / spam 0.1143885

# 이원교차표(크로스 테이블)
library(gmodels)
CrossTable(x = sms_test_label,
           y = sms_pred,
           prop.chisq = F)
