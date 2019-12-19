# 막대 그래프 그리기
search()
library(dplyr) # 데이터 가공 & 정제 위한 패키지
library(ggplot2) # 그래프 그리기 위한 패키지

#---------------------------------------------------------------------------------------------------------

## ggplot2 패키지의 mpg 데이터 프레임 구조 확인
str(mpg)

# 구동방식에 따른 시내 주행 연비 비교
df_mpg = mpg %>% 
          group_by(drv) %>% 
            summarise(mean = mean(cty))
df_mpg

# 막대 그래프 --- geom_col()
ggplot(df_mpg, aes(drv, mean)) + 
  geom_col()

# 막대 그래프를 x축 크기 순으로 정렬
# reorder(정렬할 데이터, 정렬 기준)
ggplot(df_mpg, aes(reorder(drv, mean), mean)) +
  geom_col() # 오름차순

ggplot(df_mpg, aes(reorder(drv, -mean), mean)) +
  geom_col() # 내림차순


# 구동방식에 따른 고속도로 연비 비교
df_mpg2 = mpg %>% 
            group_by(drv) %>% 
              summarise(mean = mean(hwy))
df_mpg2

# 그래프
ggplot(df_mpg2, aes(drv, mean)) +
  geom_col()

# 그래프 정렬
ggplot(df_mpg2, aes(reorder(drv, mean), mean)) +
  geom_col() # 오름차순

ggplot(df_mpg2, aes(reorder(drv, -mean), mean)) + 
  geom_col() +
  xlab("구동방식") + 
  ylab("고속도로 평균 연비")

# geom_bar() -- x축은 연속 변수(구간 등), y축은 빈도 또는 크기 등을 의미 할 때 사용.
ggplot(mpg, aes(hwy)) +
  geom_bar() # x축만 주었는데, y축이 자동으로 count가 된다.

# geom_bar()의 x축에서 사용될 수 있는 변수
# 1) 범주형 변수 --- 바로 count 가능. (ex) mpg의 class)
# 2) 연속적인 변수 --- 구간을 나누어, 구간 안에 포함된 개수를 count. (ex) mpg의 cty, hwy)
# geom_bar()를 사용할 때는 x축 변수만 mapping 해주면 된다.

# geom_col()은 어떤 변수의 크기를 그래프화 한다. ex) 성별에 따른 급여 등.
# geom_col()을 사용할 때는 x,y를 모두 mapping 해야한다.

#---------------------------------------------------------------------------------------------------------

# geom_col() VS geom_bar()
# • 평균 막대 그래프 : 데이터를 요약한 '평균표를 먼저 만든 후' 평균표를 이용해 그래프 생성 - geom_col()
# • 빈도 막대 그래프 : '별도로 표를 만들지 않고' 원자료를 이용해 바로 그래프 생성 - geom_bar()

#---------------------------------------------------------------------------------------------------------

# 실습 1!!! ========================================================================================

# Q1. 어떤 회사에서 생산한 "suv" 차종의 도시 연비가 높은지 알아보려고 합니다. 
# "suv" 차종을 대상으로 평균 cty(도시 연비)가 가장 높은 회사 다섯 곳을 막대 그래프로 표현해 보세요. 
# 막대는 연비 가 높은 순으로 정렬하세요.
df = mpg %>% 
      filter(class == "suv") %>% 
      group_by(manufacturer) %>% 
      summarise(mean_cty = mean(cty)) %>%
      arrange(desc(mean_cty)) %>% 
      head(5)
df      

ggplot(df, aes(reorder(manufacturer, -mean_cty), mean_cty)) +
  geom_col()

# Q2. 자동차 중에서 어떤 class(자동차 종류)가 가장 많은지 알아보려고 합니다. 
# 자동차 종류별 빈도를 표현한 막대 그래프를 만들어 보세요.
ggplot(mpg, aes(class)) +
  geom_bar()

# table() --- 도수분포표
t = table(mpg$class)

t["compact"]
t["suv"]
ggplot(mpg, aes(reorder(class, table(class)[class]))) + 
  geom_bar()
# count를 이용해 정렬하는 경우에, class를 reordre하고, table(class)를 기준으로 정렬한다.
# 그리고 인자 값(index)으로는 class를 준다.

# 다른 방법
df = as.data.frame(table(mpg$class))
df

ggplot(df, aes(reorder(Var1, -Freq), Freq)) +
  geom_col()


# ========================================================================================

# 선 그래프 그리기
# 선 그래프(Line Chart) : 데이터를 선으로 표현한 그래프
# 시계열 그래프(Time Series Chart) : 일정 시간 간격을 두고 나열된 시계열 데이터(Time Series Data)를
# 선으로 표현한 그래프. 환율, 주가지수 등 경제 지표가 시간에 따라 어떻게 변하는지 표현할 때 활용

# ggplot2::economics 데이터 프레임을 이용해보자.
str(economics)
head(economics)
tail(economics)

# 시간에 따른 실업자수(unemploy)의 변화
ggplot(economics, aes(date, unemploy)) +
  geom_line()

# 시간에 따른 인구(pop) 변화
ggplot(economics, aes(date, pop)) +
  geom_line()

df = as.data.frame(economics)
df

# df 데이터 프레임에서 인구대비 실업자 비율 변수(unemp_ratio) 추가
df = df %>% 
  mutate(unemp_ratio = (unemploy / pop) * 100)

# 그래프
ggplot(df, aes(date, unemp_ratio)) + 
  geom_line()

# 시간에 따른 개인 저축률(psavert) 변화
ggplot(economics, aes(date, psavert)) +
  geom_line()

# 두 개의 line 그래프를 한 차트에서 출력하자.
# 시간에 따른 실업률(y)과 저축률(x)의 상관 관계
ggplot(df, aes(x = date)) +  # --- 공통 데이터 / 축 설정
  geom_line(aes(y = unemp_ratio, color = "red")) + # --- 그래프종류, 데이터 설정
  geom_line(aes(y = psavert, color = "blue"))

str(df)

# 실업률(unemp_ratio)과 평균 실업 기간(uempmed)과의 관계 파악
ggplot(df, aes(x= date)) + 
  geom_line(aes(y = unemp_ratio, color = "red")) +
  geom_line(aes(y = uempmed, color ="blue")) 
  
