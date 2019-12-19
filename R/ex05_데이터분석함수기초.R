# head() = 데이터 앞부분 출력
# tail() = 데이터 뒷부분 출력
# View() = 뷰어창에서 데이터 확인 -- V는 대문자로 사용해야한다.
# dim() = 데이터 차원 출력
# str() = 데이터 속성 출력
# summary() = 요약통계량 출력

#############################################################################################

# csv 파일로 데이터프레임 생성
exam <- read.csv("data_excel/csv_exam.csv")

# 데이터 프레임의 모든 데이터 출력
exam

# Viewer창에 데이터 출력
View(exam)

# 데이터 앞부분 출력 
# head(데이터프레임이름, [n = 숫자]) -- n은 앞에서부터 n행까지 출력. defualt 값은 6.
head(exam) # 앞에서부터 6행까지 출력
head(exam, 10) # 앞에서부터 10행까지 출력
head(exam, 3) # 앞에서부터 3행까지 출력

# 데이터 뒷부분 출력
# tail(데이터프레임이름, [n = 숫자]) -- n은 뒤에서부터 n행 출력. defualt 값은 6
tail(exam) # 뒤에서부터 6행 출력
tail(exam, 10) # 뒤에서부터 10행 출력
tail(exam, 3) # 뒤에서부터 3행 출력

# 데이터 차원 출력(몇행(관측치 개수) 몇열(변수 개수)인지 알아보기)
# dim(데이터프레임이름) -- 결과 : 행 열
dim(exam) # -- 결과 20 5

# 속성 파악하기 -- 각 컬럼의 데이터 타입과 각각에 저장된 값 출력
# str(데이터프레임이름) 
str(exam) 
# -- 결과 
# data.frame':	20 obs. of  5 variables:  
# id : int 1 2 3 4 5 6 7 8 9 10 ...  
# class : int 1 1 1 1 2 2 2 2 3 3..
# math   : int  50 60 45 30 25 50 80 90 20 50 ...
# english: int  98 97 86 98 80 89 90 78 98 98 ...
# science: int  50 60 78 58 65 98 45 25 15 45 ...

# 요약통계량 출력 -- 컬럼 값을 정렬(오름차순)해, 
# min, max, mean, median(1/2(50%)지점 값), 1st Qu.(1/4(25%)지점 값), 3rd Qu.(3/4(75%)지점 값)을 보여준다.
# summary(데이터프레임이름) 
summary(exam)
# -- 결과 
#     id            class        math          english        science     
# Min.   : 1.00   Min.   :1   Min.   :20.00   Min.   :56.0   Min.   :12.00  
# 1st Qu.: 5.75   1st Qu.:2   1st Qu.:45.75   1st Qu.:78.0   1st Qu.:45.00  
# Median :10.50   Median :3   Median :54.00   Median :86.5   Median :62.50  
# Mean   :10.50   Mean   :3   Mean   :57.45   Mean   :84.9   Mean   :59.45  
# 3rd Qu.:15.25   3rd Qu.:4   3rd Qu.:75.75   3rd Qu.:98.0   3rd Qu.:78.00  
# Max.   :20.00   Max.   :5   Max.   :90.00   Max.   :98.0   Max.   :98.00  

#############################################################################################

# ggplot2의 mpg데이터를 데이터프레임 형태로 불러오기.

# as.data.from(변수)
# = 변수가 데이터 프레임이면, 데이터 프레임을 반환하고, 
# 데이터 프레임이 아니지만 데이터 프레임으로 변환 가능하면, 데이터프레임을 생성해 리턴.
mpg <- as.data.frame((ggplot2 :: mpg))
mpg

# mpg 데이터 파악하기.
head(mpg) # 앞부분 출력

tail(mpg) # 뒷부분 출력

View(mpg) # Viewer창에 출력

dim(mpg) # 차원(행렬 수) 파악

str(mpg) # 데이터 속성 확인

summary(mpg) # 요약통계량 출력

#############################################################################################

# 변수 이름 바꾸기.

# 데이터 가공 위한 dplyr 패키지 설치 & 로드.
install.packages("dplyr")
library(dplyr)

# 데이터 프레임 생성.
df_raw <- data.frame(var1 = c(1, 2, 1),
                     var2 = c(2, 3, 2))
df_raw

# 데이터 프레임 복사본 만들기.
df_new <- df_raw
df_new

# 변수명 바꾸기 & 비교

# rename(데이터프레임이름, 바꿀변수이름 = 기존변수이름)

# dplyr::rename 함수는 새로운 데이터 프레임을 생성해 '복사본을 리턴'함. 따라서 원본을 수정하지 않음.
# 원본 데이터 프레임을 수정하고 싶다면, 
# 원본데이터프레임이름 <- rename(원본데이터프레임이름, 바꿀변수이름 = 기존변수이름)로 써주어야 함.

df_new <- rename(df_new, v2 = var2) # var2를 v2로 수정

df_raw
df_new


# 예제 -----------------------------------------------------------------------------
# 1번. ggplot2 패키지의 mpg 데이터 사용 위해 불러 온 후, 복사본 생성.
mpg <- as.data.frame(ggplot2::mpg)
mpg_new <- mpg
mpg_new

# 2번. 복사본 데이터를 이용해서 cty는 city로, hwy는 highway로 변수명을 수정.
mpg_new <- rename(mpg_new, city = cty)
mpg_new <- rename(mpg_new, highway = hwy)

# 3번. 데이터 일부를 출력해서 변수명이 바뀌었는지 확인.
head(mpg_new)
# ----------------------------------------------------------------------------------

# 새로운 변수 추가하기.
# 데이터프레임이름$추가할변수 <- 벡터(값)
df_score <- data.frame(id = c(1, 2, 3),
                       math = c(90, 80, 100),
                       kor = c(70, 80, 90))
df_score

# 총점을 추가해보자.
df_score$total <- df_score$math + df_score$kor
df_score


# 파생변수 만들기.
df <- data.frame(v1 = c(4, 3, 8),
                 v2 = c(2, 6, 1))
df

# 파생변수 생성.
df$var_sum <- df$v1 + df$v2
df$var_mean <- (df$v1 + df$v2) / 2

df

# mpg_new에서 '통합평균연비(total)'라는 파생변수를 만들어보자.
mpg_new$total <- (mpg_new$city + mpg_new$highway) / 2

head(mpg_new)

# 조건 함수(ifelse)를 활용한 파생변수 만들기.
# ifelse(조건식, 조건에맞을때, 조건에 맞지 않을때)
# ifelse 안에 또 ifelse문을 사용 할 수 있다.
x <- 100
result <- ifelse(x > 0, "positive", "negative")
result

x1 <- -100
result1 <- ifelse(x1 > 0, "positive", "negative")
result1

x2 <- 0
result2 <- ifelse(x2 > 0, "positive", 
                  ifelse(x2 == 0, "zero", "negative"))
result2

# ifelse 함수는 스칼라(단일변수)뿐만 아닌 벡터(데이터프레임, 컬럼)에도 적용이 가능하다.
df <- data.frame(id = c(1, 2, 3, 4, 5),
                 score = c(100, 95, 88, 73, 61))
df
df$grade1 <- ifelse(df$score >= 80, "pass", "fail")
df$grade2 <- ifelse(df$score >= 90, "A",
                    ifelse(df$score >= 80, "B",
                           ifelse(df$score >= 70, "C",
                                  ifelse(df$score > 60, "D", "F"))))
df

# mpg_new의 total 기술통계량 확인.
summary(mpg_new$total)

# 히스토그램 생성하기.
hist(mpg_new$total)

# 조건 함수로 통합 연비 평균에 대한 등급을 판정 해보자.
mpg_new$grade <- ifelse(mpg_new$total >= 30, 1, 
                        ifelse(mpg_new$total >= 20, 2, 3))
head(mpg_new, 20)

# 등급에 대한 히스토그램 생성.
hist(mpg_new$grade)


# 빈도표를 활용한 등급별 자동차 수를 알아보자.
# 등급별 빈도표 생성.(= 등급별 도수분포표)
table(mpg_new$grade)

# 등급별 자동차 수에대한 막대그래프를 생성해보자.
#ggplot2를 메모리에 로드.
library(ggplot2)
# 등급별 자동차수 빈도 막대 그래프 생성.
qplot(mpg_new$grade)

# 분석 도전! ===============================================================================

# ggplot2 패키지에는 미국 동북중부 437개 지역의 인구통계 정보를 담은 
# midwest라는 데이터가 포함되어있다. midwest 데이터를 사용해 데이터 분석 문제를 해결해보자.
library(ggplot2)

# 1. ggplot2 의 midwest 데이터를 데이터 프레임 형태로 불러와서 데이터의 특성을 파악.
midwest_ex <- as.data.frame(midwest)
midwest_ex
head(midwest_ex)
tail(midwest_ex)
View(midwest_ex)
dim(midwest_ex)
str(midwest_ex)
summary(midwest_ex)

# 2. poptotal(전체 인구)을 total 로, popasian(아시아 인구)을 asian 으로 변수명을 수정.
library(dplyr)
midwest_ex <- rename(midwest_ex, total = poptotal)
midwest_ex <- rename(midwest_ex, asian = popasian)
head(midwest_ex)

# 3.  total, asian 변수를 이용해 '전체 인구 대비 아시아 인구 백분율' 파생변수를 만들고, 
# 히스토그램을 만들어 도시들이 어떻게 분포하는지 살펴보아라.
midwest_ex$asian_per_total <- (midwest_ex$asian / midwest_ex$total) * 100
hist(midwest_ex$asian_per_total)

# 4.  아시아 인구 백분율 전체 평균을 구하고, 평균을 초과하면 "large", 
# 그 외에는 "small"을 부여하는 파생변수를 만들어라.
mean(midwest_ex$asian_per_total)
midwest_ex$group <- ifelse(midwest_ex$asian_per_total > 0.4872462, "large", "small")

# 5. "large"와 "small"에 해당하는 지역이 얼마나 되는지, 
# 빈도표와 빈도 막대 그래프를 만들어 확인
table(midwest_ex$group)
qplot(midwest_ex$group)

# ===============================================================================
