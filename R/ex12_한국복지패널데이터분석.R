# # 한국 복지 패널 데이터 분석 1

rm(list = ls())

# 통계 전용 프로그램 SPSS에서 만들어진 sav파일을 읽어서
# 데이터 프레임을 생성하려면 foreign 패키지가 필요
install.packages('foreign')

# 분석에 필요한 패키지들을 검색 경로(메모리)에 로드
library(foreign)
library(readxl)
library(dplyr)
library(ggplot2)
search()
# to.data.frame -- R에서 사용할 수 있는 데이터 프레임으로 변경할 것인가?
# to.data.frame = T -- default 값은 F이므로 T로 바꿔야 한다.

# --------------------------------------------------------------------------------

# SPSS에서 사용하는 sav파일을 R에서 사용할 수 있는
# data.frame 타입으로 변환
raw_welfare1 = read.spss(file = 'data/Koweps_hpc10_2015_beta1.sav',
                        to.data.frame=T)

# 원본 데이터 프레임을 복사 
welfare1 = raw_welfare1

# 데이터 구조 확인 
str(welfare1)
table(welfare1$h10_g3) #성별
table(welfare1$h10_g4) #태어난 연도 
table(welfare1$h10_g10) #혼인 상태
table(welfare1$h10_reg7) # 지역 

# 변수 이름들을 분석하기 쉽게 변경 
# rename(데이터프레임, 바꿀 이름 = 원래 변수 이름)
# h10_g3 : 성별 = gender
# h10_g4 : 태어난 연도 = birth
# h10_g10 : 혼인 여부 = marriage
# h10_g11 : 종교 = religion
# h10_eco9 : 직종코드 = code_job
# p1002_8aq1 : 월 급여 = income
# h10_reg7 : 7개 지역(지역,서울/수도권/경남/...) = code_region

welfare1 = welfare1 %>% 
  rename(gender = h10_g3,
         birth=h10_g4,
         marriage=h10_g10,
         religion=h10_g11,
         code_job=h10_eco9,
         income=p1002_8aq1,
         code_region=h10_reg7)

# 성별에 따른 월급 차이?
table(welfare1$gender) # 성별 도수분포표
# 성별 변수에는 이상치가 없다.
# 만약에 이상치가 있는 경우에는 이상치르 NA로 처리
welfare1$gender = ifelse(welfare1$gender %in% c(1,2),
                        welfare1$gender,NA)


# welfare1와 df_jobs 데이터 프레임을 조인
welfare1 = welfare1 %>% 
  left_join(x = welfare1, y = df_jobs, by = "code_job")
head(welfare1)


# 성별은 질적 변수(qualitive variable):
# 1,2라는 숫자의 크기가 중요한게 아니라, 남/여 구분이 중요.
# gender 변수를 factor로 만듦. factor --> 카테고리로 만든다.
welfare1$gender = factor(welfare1$gender,
                        levels = c(1,2),
                        labels = c('남자','여자'))

table(welfare1$gender)
summary(welfare1$gender)
class(welfare1$gender)

ggplot(data = welfare1, mapping = aes(x=gender, fill = gender)) +
  geom_bar()
# 막대 그래프에서 색깔 넣어주기 aes()함수 안에서 fill = 을 사용하면 된다.  
# 점이나 선을 색깔을 채울때에는 color() 막대는 fill
# 질적변수 / 양적변수 ---책 읽어보기 

# --------------------------------------------------------------------------------

# 월 급여 
table(welfare1$income)
class(welfare1$income) # income변수의 데이터 타입은 숫자 타입이다. --> 양적변수(quantative variable)
# income 변수의 요약 정보
summary(welfare1$income)
# income 변수의 값이 9999인 경우는 한달 급여를 응답하지 않은 경우임  -> 이상치 처리를 해야 한다.
# summary 함수를 사용해서 이상치가 없음을 확인.
welfare1$income = ifelse(welfare1$income > 0 & welfare1$income < 9999,welfare1$income,NA)
summary(welfare1$income)

# 성별 평균 한달 급여
welfare1 %>% 
  group_by(gender) %>% 
  summarize(income_by_gender = mean(income, na.rm = T))

income_by_gender = welfare1 %>% 
  filter(!is.na(income)) %>% 
  group_by(gender) %>% 
  summarize(mean=mean(income))

income_by_gender

ggplot(data=income_by_gender,mapping = aes(x=gender,y=mean,fill = gender))+
  geom_col()

# 급여 분포
ggplot(welfare1, aes(income)) + 
  geom_bar(width = 100) # width : 막대 1개의 폭
# geom_bar() : 데이터프레임을 그대로 사용, x축만 지정. y축 지정 안함.  count 자동으로
# geom_col() : 새로운 데이터프레임을 만들고 x축과 y축을 지정.

# --------------------------------------------------------------------------------

# 연령에 따른 월급 차이 분석
# 출생연도 도수분포표
table(welfare1$birth)
# 데이터에는 출생연도는 있지만 연령은 없다.

# NA 여부 확인
table(is.na(welfare1$birth))
# NA 없음

# welfare1 데이터 프레임의 age 변수 추가(조사 시점(2015년) 기준)
welfare1$age = 2015 - welfare1$birth
table(welfare1$age)
summary(welfare1$age)

# 연령 분포
ggplot(welfare1, aes(age)) +
  geom_bar()
# 구간이 촘촘해서 알아보기 어려움
# age의 구간을 나누어보자.
income_by_age = welfare1 %>% 
  filter(!is.na (income)) %>% # income = NA를 제외
  group_by(age) %>% 
  summarise(mean = mean(income))
head(income_by_age)
tail(income_by_age)

ggplot(income_by_age, aes(age, mean)) +
  geom_col()

ggplot(income_by_age, aes(age, mean)) +
  geom_line()

# 성별과 연령에 따른 급여 통계
income_gender_age = welfare1 %>% 
  filter(!is.na(income)) %>% 
  group_by(age, gender) %>% 
  summarise(mean = mean(income))
head(income_gender_age)
tail(income_gender_age)

ggplot(income_gender_age, aes(age, mean, color = gender)) +
  geom_line()

# 어느 연령대의 급여가 가장 많을까?
# 30세 미만(young), 60세 미만(middle), 60세 이상(old)
welfare1 = welfare1 %>% 
  mutate(ageg = ifelse(age < 30, "young",
                       ifelse(age <60, "middle", "old")))
table(welfare1$ageg)

# ageg 변수를 질적 변수(순서형 변수, ordinal)로 만들면
welfare1$ageg = factor(welfare1$ageg,
                      levels = c("young", "middle","old"))

ggplot(welfare1, aes(ageg)) +
  geom_bar()

# --------------------------------------------------------------------------------

# 연령대별 평균 급여
income_by_ageg = welfare1 %>% 
  filter(!is.na(income)) %>% 
  group_by(ageg) %>% 
  summarise(mean = mean(income))

income_by_ageg

ggplot(data = income_by_ageg, mapping = aes(x = ageg, y = mean)) +
  geom_col()

# young, middle, old 순서대로 그래프 그리기
ggplot(data = income_by_ageg, mapping = aes(x = ageg, y = mean)) +
  geom_col() + 
  scale_x_discrete(limits = c("young", "middle", "old"))

# 연령대와 성별에 따른 급여
income_by_ageg_gender = welfare1 %>% 
  filter(!is.na(income)) %>% 
  group_by(ageg, gender) %>% 
  summarise(mean = mean(income))

income_by_ageg_gender

# --------------------------------------------------------------------------------

# 연령대와 성별에 따른 급여 그래프
ggplot(data = income_by_ageg_gender, 
       mapping = aes(x = ageg, y = mean, fill = gender)) +
  geom_col(position = "dodge") 
# position = "dodge" : 남 / 여를 각각의 막대에 나타낼 수 있다
# position = "stack" : 남 / 여를  같은 막대 안에 나타낸다

# 연령대(welfare1$age_range)별 인구 수, 평균급여, 성별에 따른 평균 급여
# age < 20 : "age10"
# age < 30 : "age20:
# age < 40 : "age30"
# age < 50 : "age40"
# age < 60 : "age50"
# age < 70 : "age60"
# age < 80 : "age70"
# age >= 80 : "age80"
welfare1 = welfare1 %>% 
  mutate(age_range = ifelse(age < 20, "age10",
                            ifelse(age <30, "age20",
                                   ifelse(age < 40, "age40",
                                          ifelse(age < 50, "age40",
                                                 ifelse(age < 60, "age50",
                                                        ifelse(age < 70, "age60",
                                                               ifelse(age < 80, "age70", "age80"))))))))
# 연령대 별 인구수 그래프
table(welfare1$age_range)

# 연령대 별 평균 급여
income_by_age_range = welfare1 %>% 
  filter(!is.na(income)) %>% 
  group_by(age_range) %>% 
  summarise(mean_age_range = mean(income))
income_by_age_range 

# --------------------------------------------------------------------------------

# 연령대 별 성별에 따른 평균 급여
income_by_age_range_gender = welfare1 %>% 
  filter(!is.na(income)) %>% 
  group_by(gender, age_range) %>% 
  summarise(mean_age_range_gender = mean(income))
income_by_age_range_gender 

# 연령대 별 인구수 그래프
ggplot(welfare1, aes(age_range)) +
  geom_bar()

# 연령대 별 평균 급여 그래프
ggplot(income_by_age_range, aes(age_range, mean_age_range, fill = age_range)) +
  geom_col()

# 연령대 별 성별에 따른 평균 급여 그래프
ggplot(income_by_age_range_gender, aes(age_range, mean_age_range_gender, fill = gender)) +
  geom_col(position = "dodge") +
  theme_wsj() +
  scale_fill_manual(values = c("darkgreen", "hotpink"))

library(ggthemes)
install.packages('ggthemes')

# --------------------------------------------------------------------------------

# 직업별 급여 차이
class(welfare1$code_job)
head(welfare1$code_job)
tail(welfare1$code_job)
summary(welfare1$code_job)

# 엑셀 파일에 정리된 code_job, job를 새로운 데이터 프레임으로 생성.
df_jobs = read_excel("data/Koweps_Codebook.xlsx", sheet = 2)
head(df_jobs)
tail(df_jobs)
str(df_jobs)

# welfare1와 df_jobs 데이터 프레임 조인
welfare1 = left_join(welfare1, df_jobs, by = "code_job")

str(welfare1)

welfare1 %>% 
  select(code_job, job) %>% 
  head(10)

welfare1 %>% 
  select(code_job, job) %>% 
  tail(10)

table(welfare1$code_job)

# NA를 제거해보자
job_top10 = welfare1 %>% 
  filter(!is.na(code_job)) %>% 
  group_by(job) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count)) %>% 
  head(10)

job_top10

# 그래프 그리기
ggplot(job_top10, aes(reorder(job, -count), count)) +
  geom_col()
  
# --------------------------------------------------------------------------------

# 남성들이 가장 많이 종사하는 직종 10개를 찾아 그래프를 그려보자.
job_male = welfare1 %>% 
  filter(!is.na(code_job) & gender == "남자") %>% 
  group_by(job, gender) %>% 
  summarise(count = n()) %>%
  arrange(desc(count)) %>% 
  head(10)

ggplot(job_male, aes(reorder(job, -count), count)) +
  geom_col() +
  coord_flip() + # 가로 그래프 출력
  xlab("직종") + ylab("인구수") # x축, y축 레이블 변경

# --------------------------------------------------------------------------------

# 여성들이 가장 많이 종사하는 직종 10개를 찾아 그래프를 그려보자.
job_female = welfare1 %>% 
  filter(!is.na(code_job) & gender == "여자") %>% 
  group_by(job, gender) %>% 
  summarise(count = n()) %>%
  arrange(desc(count)) %>% 
  head(10)  
  
ggplot(job_female, aes(reorder(job, -count), count)) +
  geom_col() +
  coord_flip() + # 가로 그래프 출력
  xlab("직종") + ylab("인구수") # x축, y축 레이블 변경

# --------------------------------------------------------------------------------

# 데이터 가공을 했었던 welfare1 데이터 프레임을 
# R에서 사용하는 데이터 파일 형식(.rda)으로 저장
save(welfare1, file = "data/welfare1.rda")

# 기존 welfare1 지우기
rm(welfare1)

# welfare1 불러오기
load("data/welfare1.rda")
str(welfare1)

