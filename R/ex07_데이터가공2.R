# 데이터 전처리(가공)하기 

# dplyr 패키지의 함수들
library(dplyr)

# filter() = 행 추출  --> 오라클의 where
# select() = 열(변수) 추출 --> 오라클의 select
# arrange() = 정렬
# mutate() = 변수 추가
# summarise() = 통계치 산출
# group_by() = 집단별로 나누기 --> 오라클의 group by
# left_join() = 데이터 합치기(열)
# bind_rows() = 데이터 합치기(행)

# R에서 사용하는 기호들

# <  --- 작다
# <= --- 작거나 같다
# > --- 크다
# >= --- 크거나 같다
# == --- 같다
# != --- 같지 않다
# │ --- 또는
# & --- 그리고
# %in% --- 매칭 확인

# + --- 더하기
# - --- 빼기
# * --- 곱하기
# / --- 나누기
# ^ , ** --- 제곱
# %/% --- 나눗셈의 몫
# %% --- 나눗셈의 나머지

##########################################################################################

exam = read.csv("data_excel/csv_exam.csv")
exam
# exam 의 구조 확인.
str(exam)

# 'Filter()'를 사용해보자. 

# filter(데이터프레임이름, 검색 조건) 


# dplyr() 패키지의 모든 함수는 첫번째 파라미터가 데이터프레임 이름이며,
# 변수 이름들은 데이터프레임 이름을 생략 후, 사용하면 된다.

# 1반과 2반 학생들의 정보를 출력하면?
filter(exam, class == 1 | class == 2)
filter(exam, class %in% 1:2)
filter(exam, class %in% c(1, 2))

# 3반이 아닌 학생들의 정보을 출력하면?
filter(exam, class != 3)

# 수학 점수가 60점 이상인 학생의 정보를 출력하면?
filter(exam, exam$math >= 60)

# ----------------------------------------------------------------------------------

# dplty 패키지의 함수들을 호출하는 방법
# 1) function(data_frame, 검색 조건)
# 2) data_frame %>% function(검색 조건) --- 파이프 '%>%'은 'ctrl+shift+m' 단축 키를 이용하자.

# 1반 학생들의 정보를 출력하면?
exam %>% filter(class == 1)

# 1반 학생들 중에서 수학 점수가 평균 이상인 학생을 출력하면?
exam %>% filter(class == 1 & math >= mean(math))

#  filter() 함수의 결과를 변수에 저장.
# 1반 학생들로만 이루어진 데이터 프레임을 만들면?
class1 = exam %>%  filter(class ==1)
str(class1)

# 그렇다면 1반 학생들의 각 과목 평균 점수를 출력하면?
mean(class1$math)
mean(class1$english)
mean(class1$science)

# 실습1 !!! ===========================================================================
mpg <- as.data.frame(ggplot2::mpg)

# Q1. 자동차 배기량에 따라 고속도로 연비가 다른지 알아보려고 합니다. 
# displ(배기량)이 4 이하인 자동차와 5 이상인 자동차 중 
# 어떤 자동차의 hwy(고속도로 연비)가 평균적으로 더 높은지 알아보세요.
mpg_a <- mpg %>% filter(displ <= 4)
mpg_b <- mpg %>% filter(displ >= 5)
mean(mpg_a$hwy)
mean(mpg_b$hwy)

# Q2. 자동차 제조 회사에 따라 도시 연비가 다른지 알아보려고 합니다. 
# "audi"와 "toyota" 중 어느 manufacturer(자동차 제조 회사)의 cty(도시 연비)가 
# 평균적으로 더 높은지 알아보세요.
mau_a <- mpg %>% 
          filter(manufacturer == 'audi')
mau_b <- mpg %>% 
          filter(manufacturer == 'toyota')
mean(mau_a$cty)
mean(mau_b$cty)

# Q3. "chevrolet", "ford", "honda" 자동차의 고속도로 연비 평균을 알아보려고 합니다. 
# 이 회사들의 자동차를 추출한 뒤 hwy 전체 평균을 구해보세요.
hwy_tot_avg <- mpg %>% 
                filter(manufacturer %in% c("chevrolet", "ford", "honda"))
mean(hwy_tot_avg$hwy)
# ===========================================================================

# 데이터 프레임에서 변수를 select하기.
# dplyr::select()
# 1) select(데이터프레임이름, 컬럼명)
# 2) 데이터프레임 %>%  select(컬럼명)

# exam에서 수학 점수만 출력하면?
exam %>% select(math)

# id와 수학 점수를 출력하려면?
exam %>% select(id, math)
exam %>%  select (c(id, math))

# class를 제외한 모든 컬럼을 출력한다면?
# '-컬럼명'을 하면 해당 컬럼명과 그 정보만을 제외하고 결과가 출력된다.
exam %>%  select(id, math, english, science)
exam %>%  select(-class)

# ----------------------------------------------------------------------------------

# '%>%'(파이프 연산자)를 사용한 함수 연쇄 호출

# 1반 학생들의 id, math를 출력해보자.

# 1) 반 학생들만 있는 데이터프레임을 생성하려면?
class1 = exam %>% filter(class == 1)

# 2) 1반 학생의 id, math만 출력하려면?
class1 %>% select(id, math)

# 3) 그렇다면 두 문장을 합칠수 없을까?
class2 = exam %>% 
  filter(class == 1) %>% 
    select(id, class, math)
class2

# exam에서 class == 1에 해당하는 결과를 select에게 넘겨주어 최종 결과를 리턴한다.
# ' %>% '은 파이프 연산자. 즉, 여러 대상의 '연결'을 의미.
# 대상이 많으면 많을수록 필터링을 먼저하고 출력하는 것이 좋다.

# 수학, 영어, 과학을 출력. 단, 앞에 있는 6건만 출력하려면?
exam %>% 
  head() %>% 
    select(math, english, science)

# 실습2 !!! ===========================================================================

mpg <- as.data.frame(ggplot2::mpg)

# Q1. mpg 데이터는 11 개 변수로 구성되어 있습니다. 이 중 일부만 추출해서 분석에 활용하려고 합니다. 
# mpg 데이터에서 class(자동차 종류), cty(도시 연비) 변수를 추출해 새로운 데이터를 만드세요. 
# 새로 만든 데이터의 일부를 출력해서 두 변수로만 구성되어 있는지 확인하세요.
mpg_new = mpg %>% 
  select(class, cty)
mpg_new

# Q2. 자동차 종류에 따라 도시 연비가 다른지 알아보려고 합니다. 
# 앞에서 추출한 데이터로 class(자동차 종류)가 "suv"인 자동차와 "compact"인 자동차 중,
# 어떤 자동차의 cty(도시 연비)가 더 높은지 알아보세요.
class_suv = mpg_new %>% 
  filter(class == "suv")
class_comp = mpg_new %>% 
  filter(class == "compact")
mean(class_suv$cty)
mean(class_comp$cty)

# ===========================================================================

# 데이터를 정렬하기
# arrange(데이터프레임, 컬럼이름1, 컬럼이름2, ...)
# 또는 데이터프레임 %>% arrange(컬럼이름1, 컬럼이름2, ...)
# default는 오름차순.
# 내림차순 정렬은 'desc'를 추가한다.

# 수학 점수에 따라 정렬하려면? 
arrange(exam, math)
exam %>% arrange(math)

# 내림차순으로 하면?
arrange(exam, desc(math))
exam %>% arrange(desc(math))

# 반과 수학점수를 오름차순 정렬하면?
arrange(exam, class, math)
exam %>% arrange(class, math)

# 실습3 !!! ===========================================================================

# "audi"에서 생산한 자동차 중에 어떤 자동차 모델의 hwy(고속도로 연비)가 높은지 알아보자.
# "audi"에서 생산한 자동차 중 hwy가 1~5위에 해당하는 자동차의 데이터를 출력하세요.
mpg %>% 
  filter(manufacturer == "audi") %>% 
    arrange(desc(hwy)) %>% head(5)

# ===========================================================================

# 파생변수를 추가해보자.

# 1) 데이터프레임$추가할컬럼 <- 식 
# --- 이 방식은 원본 데이터 프레임 자체가 변경된다.
exam2 <-exam
exam2$total <- exam2$math + exam2$english + exam2$science
exam2
# 2) mutate(데이터프레임, 추가할 컬럼 = 식) 
# --- 이 방식은 원본의 복사본을 만들어 변경하기 때문에 원본은 변하지 않는다.
# --- 따라서 결과를 원본이나 다른곳에 저장하지 않으면 사라짐.
exam %>% 
  mutate(total = math + english + science) %>% 
    head()

# 여러 파생 변수를 한 번에 추가하려면?
# exam에서 과목 점수의 총합을 total, 평균을 avg라고 하고 출력하면?
exam %>% 
  mutate(total = math + english + science, avg = trunc(total / 3)) %>% 
    head()
    
# cf) ceiling = 정수 올림 & 정수 리턴
#     floor = 정수 내림 & 정수 리턴
#     trunc = 소수점 절삭 & 정수 리턴
#     round = 반올림, 소수점 이하 자리수 지정 필요

# mutate()에 ifelse()를 적용하려면?
exam %>% 
  mutate(result = ifelse(science >= 60, "Pass", "Fail")) %>% 
    head()

exam %>% 
  mutate(result = ifelse(math >= 40 & 
                           english >= 40 & 
                            science >= 40 & 
                              ((math + english + science) / 3) >= 60, "pass", "fail"))

# 실습4 !!! ===========================================================================

# Q1. mpg 데이터 복사본을 만들고, cty 와 hwy 를 더한 '합산 연비 변수'를 추가하세요.
mpg_ex <- as.data.frame(mpg)
mpg_ex
mpg_ex = mpg_ex %>% 
          mutate(tot_y = cty + hwy)

# Q2. 앞에서 만든 '합산 연비 변수'를 2 로 나눠 '평균 연비 변수'를 추가세요.
mpg_ex = mpg_ex %>% 
          mutate(avg_y = tot_y / 2)

# Q3. '평균 연비 변수'가 가장 높은 자동차 3 종의 데이터를 출력하세요.
mpg_ex %>% 
  arrange(desc(avg_y)) %>% 
    head(3)

# Q4. 1~3 번 문제를 해결할 수 있는 하나로 연결된 dplyr 구문을 만들어 출력하세요. 
# 데이터는 복사본 대신 mpg 원본을 이용하세요.
mpg %>% 
  mutate(tot_y = cty + hwy, avg_y = tot_y / 2) %>% 
    arrange(desc(avg_y)) %>% 
      head(3)

# ===========================================================================

# 집단별로 요약을 해보자.

# mean() = 평균
# sd() = 표준편차
# sum() = 합계
# median() = 중앙값
# min() = 최솟값
# max() = 최댓값
# n() = 빈도

# 요약(Summarise) --- 벡터를 스칼라로 만들어 준다. (통계 함수를 적용하기 위함)
# 데이터프레임 %>% summarise(새로운컬럼명 = 조건식)
exam %>% 
  summarise(mean_math = mean(math))

# 집단화(Group_By)
# 데이터프레임 %>% group_by(대상 집단이 될 컬럼명)
exam %>% 
  group_by(class) %>% 
    summarise(mean_math = mean(math))

exam %>% 
  group_by(class) %>% 
  summarise(mean_math = mean(math), # math 평균
            mean_english = mean(english)) %>% 
  arrange(mean_english)

# 여러 요약통계량을 한번에 출력하려면?
exam %>% 
  group_by(class) %>% 
    summarise(mean_math = mean(math), # math 평균
              sum_math = sum(math), # math 합계
              median_math = median(math), # math 중간값
              n = n()) # 학생 수

# 집단을 각 집단별로 다시 만들려면?
mpg %>% 
  group_by(manufacturer, drv) %>% 
    summarise(mean_cty = mean(cty)) %>% 
      head(10)

# 예제 ------------------------------------------------------------------------------
# 회사별로 "suv" 자동차의 도시 및 고속도로 통합 연비 평균을 구해 내림차순으로 정렬하고, 
# 1~5위까지 출력해보자.
mpg <- as.data.frame(ggplot2::mpg)

mpg %>% 
  group_by(manufacturer) %>% 
    filter(class == "suv") %>% 
      mutate(tot = (cty + hwy) / 2) %>% 
        summarise(mean_tot = mean(tot)) %>% 
          arrange(desc(mean_tot)) %>% 
            head(5)

library(dplyr)
mpg = as.data.frame(ggplot2::mpg)

#제조사별 자동차 모델 개수
mpg %>% 
  group_by(manufacturer) %>% 
  summarise(count = n())

# 자동차 종류별 모델 개수
mpg %>% 
  group_by(class) %>% 
  summarise(count = n())

#  ------------------------------------------------------------------------------

# 실습5 !!! ===========================================================================

# Q1. mpg 데이터의 class 는 "suv", "compact" 등 자동차를 특징에 따라 일곱 종류로 분류한 변수입니다.
# 어떤 차종의 연비가 높은지 비교해보려고 합니다. class 별 cty 평균을 구해보세요.
mpg %>% 
  group_by(class) %>%
    summarise(cty_avg = mean(cty))

# Q2. 앞 문제의 출력 결과는 class 값 알파벳 순으로 정렬되어 있습니다. 
# 어떤 차종의 도시 연비가 높은지 쉽게 알아볼 수 있도록 cty 평균이 높은 순으로 정렬해 출력하세요.
mpg %>% 
  group_by(class) %>%
    summarise(cty_avg = mean(cty)) %>% 
      arrange(desc(cty_avg))

# Q3. 어떤 회사 자동차의 hwy(고속도로 연비)가 가장 높은지 알아보려고 합니다. 
# hwy 평균이 가장 높은 회사 세 곳을 출력하세요.
mpg %>% 
  group_by(manufacturer) %>% 
    summarise(mean_hwy = mean(hwy)) %>%
      arrange(desc(mean_hwy)) %>% 
        head(3)

# Q4. 어떤 회사에서 "compact"(경차) 차종을 가장 많이 생산하는지 알아보려고 합니다. 
# 각 회사별 "compact" 차종 수를 내림차순으로 정렬해 출력하세요.
mpg %>% 
  group_by(manufacturer) %>% 
    filter(class == "compact") %>% 
      summarise(count = n()) %>% 
        arrange(desc(count))

# ===========================================================================