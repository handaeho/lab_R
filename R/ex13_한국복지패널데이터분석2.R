# plot Viewer 새 창에 띄우기
windows()

# --------------------------------------------------------------------------------

# 한국 복지 패널 데이터 분석 2
library(dplyr)
library(ggplot2)
search()

# 저장해둔 R 데이터 파일 로드, 변수 자동 생성
load("data/welfare1.rda")

#데이터 프레임 확인
str(welfare1)

# --------------------------------------------------------------------------------

welfare1 %>% 
  select(code_job, job) %>% 
  head(30)

table(is.na(welfare1$job))

# 직업별 평균 소득 분석
income_by_job = welfare1 %>% 
  filter(!is.na(job) & !is.na(income)) %>% 
  group_by(job) %>% 
  summarise(mean = mean(income))

income_by_job    

# 평균 소득 상위 10개 직종
top10 = income_by_job %>% 
  arrange(desc(mean)) %>% 
  head(10)

top10

# 평균 소득 하위 10개 직종
low10 = income_by_job %>% 
  arrange(mean) %>% 
  head(10)

low10

# 직종별 평균 급여 상위 10개 그래프
ggplot(data = top10, mapping = aes(x = reorder(job, mean), y= mean)) +
  geom_col() + 
  coord_flip() +
  xlab("job")

# 직종별 평균 급여 하위 10개 그래프
ggplot(data = low10, mapping = aes(x = reorder(job, mean), y= mean)) +
  geom_col() + 
  coord_flip() +
  xlab("job")

# 그런데 어떤 직종에 1명만 종사하는데 800만원을 받아서 평균이 800만원이고,
# 그래서 1등이라면 올바른 데이터일까?
# 걸러내기 위해서는 어떠한 기준이 필요하다. ex) 종사자가 n명 이상인 직종

#직종별 종사자가 30명 이상인 직종의 평균 소득
job_pop = welfare1 %>% 
  filter(!is.na(income) & !is.na(job)) %>% 
  group_by(job) %>%
  summarise(count = n(), mean = mean(income)) %>% 
  filter(count >= 30) %>% 
  select(job, count, mean)

job_pop

# 그래프
ggplot(job_pop, aes(reorder(job, mean), mean)) +
  geom_col()

# 종사자가 30명 이상인 직종의 평균 소득 상위 10개 직종
top10_30 = job_pop %>%
  arrange(desc(mean)) %>% 
  head(10)

top10_30

# 그래프
ggplot(top10_30, aes(reorder(job, mean), mean)) +
  geom_col()

# 종사자가 30명 이상인 직종의 평균 소득 하위 10개 직종
low10_30 = job_pop %>% 
  arrange(mean) %>% 
  head(10)

low10_30

# 그래프
ggplot(low10_30, aes(reorder(job, mean), mean)) +
  geom_col()

# --------------------------------------------------------------------------------

# 종교 유무에 따른 이혼률을 알아보자.
class(welfare1$religion)
table(welfare1$religion)

# 종교 이름 부여
welfare1$religion = ifelse(welfare1$religion == 1, "Y", "N")
table(welfare1$religion)
qplot(welfare1$religion)

# 혼인 유뮤
class(welfare1$marriage)
table(welfare1$marriage)

# 이혼 여부 부여
welfare1$group_marriage = ifelse(welfare1$marriage == 1, "Marriage",
                                 ifelse(welfare1$marriage == 3, "Divorce", NA))
table(welfare1$marriage)
table(is.na(welfare1$marriage))
qplot(welfare1$marriage)

# 종교 여부에 따른 이혼률
religion_marriage = welfare1 %>% 
  filter(!is.na(marriage)) %>% 
  group_by(religion, marriage) %>% 
  summarise(count = n()) %>% 
  mutate(tot = sum(count)) %>% 
  mutate(divorce_pct = round((count / tot) * 100,1))

religion_marriage

# 이혼률 표 만들기
divorce = religion_marriage %>% 
  filter(marriage == "Divorce") %>% 
  select(religion, divorce_pct)
divorce

# 이혼률 그래프
ggplot(divorce, aes(religion, divorce_pct)) +
  geom_col() +
  xlab("종교 여부") + ylab("이혼률")

# 연령대 및 종교 유무에 따른 이혼률 
ageg_marriage = welfare1 %>% 
  filter(!is.na(group_marriage)) %>% 
  group_by(ageg, group_marriage) %>% 
  summarise(n = n()) %>% 
  mutate(tot = sum(n)) %>% 
  mutate(pct = round(n / tot * 100,1))

ageg_marriage

# 연령대 및 종교 유무에 따른 이혼률 그래프
# young 제외하고 divorce만 추출
ageg_divorce = ageg_marriage %>% 
  filter(ageg != "young" & group_marriage == "Divorce") %>% 
  select(ageg, pct)

ageg_divorce

ggplot(ageg_divorce, aes(ageg, pct)) +
  geom_col() 

# 연령대 및 종교 유무, 결혼 상태에 따른 이혼률 표 만들기
ageg_regligion_marriage = welfare1 %>% 
  filter(!is.na(group_marriage) & ageg != "young") %>% 
  group_by(ageg, religion, group_marriage) %>% 
  summarise(n = n()) %>% 
  mutate(tot_div = sum(n)) %>% 
  mutate(pct_div = round(n / tot_div * 100, 1))

ageg_regligion_marriage  

df_ageg_regligion_marriage = ageg_regligion_marriage  %>% 
  filter(group_marriage == "Divorce") %>% 
  select(ageg, religion, pct_div)

df_ageg_regligion_marriage

# 연령대 및 종교 유무, 결혼 상태에 따른 이혼률 그래프 그리기
ggplot(df_ageg_regligion_marriage, aes(ageg, pct_div, fill = religion)) +
  geom_col(position = "dodge")
  
  
# --------------------------------------------------------------------------------

# 지역 별 연령대 비율을 분석해보자.
class(welfare1$code_region)
table(welfare1$code_region)

# 연령대
table(welfare1$ageg)

# 지역코드에 지역명을 넣기
list_region =  data.frame(code_region = c(1:7),
                          region = c("서울",
                                     "인천/경기",
                                     "부산/경남/울산",
                                     "대구/경북",
                                     "대전/충남",
                                     "강원,충북",
                                     "광주/전남/전북/제주"))
list_region

# welfare1에 지역명 넣기
welfare1 = left_join(welfare1, list_region, id = "code_region")
welfare1 %>% 
  select(code_region, region) %>% 
  head(10)

# 지역별 연령대 비율표 만들기
region_ageg = welfare1  %>% 
  group_by(region, ageg) %>% 
  summarise(count = n()) %>% 
  mutate(tot = sum(count)) %>% 
  mutate(pct = round(count / tot * 100,2))

head(region_ageg)

region_age_range = welfare1  %>% 
  group_by(region, age_range) %>% 
  summarise(count = n()) %>% 
  mutate(tot = sum(count)) %>% 
  mutate(pct = round(count / tot * 100,2))

region_age_range

# 지역별 연령대 비율 그래프
ggplot(region_ageg, aes(region, pct, fill = ageg)) +
  geom_col() + 
  coord_flip() 

ggplot(region_age_range, aes(region, pct, fill = age_range)) +
  geom_col() + 
  coord_flip() 

# --------------------------------------------------------------------------------

save(welfare1, file = "data/welfare191001.rda")
