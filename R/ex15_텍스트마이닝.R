# Text Mining
# Word cloud

# 필요 패키지 설치
install.packages("rJava")
install.packages("memoise")
install.packages("KoNLP") # KoNLP : Korean Natural Languague Processing
install.packages("stringr")
install.packages("wordcloud")

# 패키지를 메모리에 로드
library(KoNLP)
library(dplyr)
library(stringr)
library(wordcloud)
search()

# 사전(Dictionary) 설정
useNIADic()
useSejongDic()
useSystemDic()

# 데이터 준비
txt = readLines("data/hiphop.txt") # 텍스트 파일을 한 줄씩 읽어 txt에 저장.
str(txt) # txt는 배열이 됨.
head(txt)
txt[1:10]
txt[1001:1010]

# 특수문자 제거
# 정규 표현식 \\W : '특수문자'를 의미한다.
txt = str_replace_all(txt, "\\W", " ")
head(txt)

# --------------------------------------------------------------------------------

# 가장 많이 사용된 단어를 알아보자.

# 명사 추출
nouns = extractNoun(txt)
str(nouns)
head(nouns)
# 

# 추출한 명사 리스트를 문자열 벡터로 변환, 단어별 빈도표 생성.
wordcount = table(unlist(nouns))
# unlist() : 행렬로 이루어진 테이블의 구성요소를 쭉 나열해 줌.
wordcount

# wordcount 테이블을 데이터 프레임으로 변환.
df = as.data.frame(wordcount, stringsAsFactors = F)
head(df)
tail(df)

# 데이터 프레임 분석이 쉽게 변수 이름을 변경
df = rename(df, word = Var1, freq = Freq)
tail(df)

# word 길이가 2자 이상인것만 선택
df = filter(df, nchar(word) >= 2)
str(df)
tail(df)

# 가장 자주 쓰인 단어 20개
top20 = df %>% 
  arrange(desc(freq)) %>% 
  head(20)

top20

# 가장 덜 쓰인 단어 20개
low20 = df %>% 
  arrange(freq) %>% 
  head(20)

low20


# 이를 이용해, wordcloud를 그려보자.

# 팔레트 설정 : brewer.pal(색상개수, "색상목록")
pal = brewer.pal(8, "Dark2") # --- Dark2 색상 목록에서 8개 색 선택

# wordcloud는 생성 할 때마다 랜덤하게 만들어 지는데,
# 실행할 때마다 같은 결과를 얻기 위해서
set.seed(1234) # 숫자는 아무 값이나 상관없음

# wordcloud 생성
wordcloud(words = df$word,   # 그려줄 글자(단어)
          freq = df$freq,   # 단어의 빈도 수
          min.freq = 2,   # 최소 빈도 수(적어도 2회 이상 나온 단어만 그림)
          max.words = 200,   # wordcloud에 보여줄 단어 최대 개수
          random.order = F,   # 단어 배치를 랜덤하게 할 것인가? T / F
          rot.per = 0.2,   # 회전 단어 비율
          scale = c(4, 0.5),   # 단어 크기 비율(0.5 ~ 4 크기 사용)
          colors = pal)   # 색상 목록
# --------------------------------------------------------------------------------

# 국정원 트윗 텍스트 마이닝

# 데이터 로드
twit = read.csv("data/twitter.csv",
                header = T,
                stringsAsFactors = F,
                fileEncoding = "UTF-8")
twit

# 변수 명 변경
twit = rename(twit, no = 번호,
              id = 계정이름,
              date = 작성일,
              tw = 내용)

# 특수문자 제거
twit$tw = str_replace_all(twit$tw, "\\W", " ")

head(twit)

# 명사 추출
tw_nouns = extractNoun(twit$tw)

# 추출한 명사 리스트를 문자열 벡터로 변환, 단어별 빈도표 생성
wordcount = table(unlist(tw_nouns))
wordcount

# 데이터 프레임으로 변환
df_word = as.data.frame(wordcount, stringsAsFactors = F)
df_word

# 변수명 수정
df_word = rename(df_word, word = Var1,
               freq = Freq)

# 두글자 이상 & 사용 빈도수 상위 20개 이상 단어 추출.
df_word = filter(df_word, nchar(word) >= 2)
top20 = df_word %>% 
  arrange(desc(freq)) %>% 
  head(20)

top20

# wordcloud 그리기

# 팔레트 설정 : brewer.pal(색상개수, "색상목록")
pal = brewer.pal(8, "Dark2") # --- Dark2 색상 목록에서 8개 색 선택

# wordcloud는 생성 할 때마다 랜덤하게 만들어 지는데,
# 실행할 때마다 같은 결과를 얻기 위해서
set.seed(1234) # 숫자는 아무 값이나 상관없음

# wordcloud 생성
wordcloud(words = df_word$word,   # 그려줄 글자(단어)
          freq = df_word$freq,   # 단어의 빈도 수
          min.freq = 10,   # 최소 빈도 수
          max.words = 200,   # wordcloud에 보여줄 단어 최대 개수
          random.order = F,   # 단어 배치를 랜덤하게 할 것인가? T / F
          rot.per = 0.1,   # 회전 단어 비율
          scale = c(6, 0.2),   # 단어 크기 비율
          colors = pal)   # 색상 목록
