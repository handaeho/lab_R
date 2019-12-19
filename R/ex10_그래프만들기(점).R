# R로 그래프를 만들어 보자.

# ggplot = grammar of graph(그래프 그리기 문법)
install.packages("ggplot2")
library(ggplot2)

# ggplot2 레이어 구조
# 1 단계 : 배경(축) 설정.
# 2 단계 : 그래프 추가 (점 / 막대 / 선 등)
# 3 단계 : 설정 추가 (축 범위, 색, 표식 등)
 
# ggplot2 패키지의 mpg 데이터프레임 구조 확인
str(mpg)

# 배기량(displ)과 시내주행연비(cty)간의 관계를 파악하려면?
summary(mpg$displ)
summary(mpg$cty)

# 1 단계) 그레프를 그릴 데이터(데이터 프레임),좌표축 설정
g = ggplot(data = mpg, mapping = aes(x = displ, y = cty))

# 2 단계) 그래프 종류 선택
g = g + geom_point() # 좌표축 + 그래프
g

# 1 단계와 2 단계를 합치면?
g = ggplot(data = mpg, aes(x = displ, y = hwy)) + geom_point()
g

# 3 단계) 설정 추가
g = g + xlim(3, 6) # x축 범위를 1.6 ~ 7에서 3 ~ 6으로 지정.
g

# 1, 2, 3 단계를 모두 합치면? 
g = ggplot(mpg, aes(displ, cty)) + geom_point() + ylim(10, 30)
g

# 실습 1!!! ========================================================================================

# mpg 데이터와 midwest 데이터를 이용해서 분석 문제를 해결해 보세요.
mpg = as.data.frame(ggplot2::mpg)
midwest = as.data.frame(ggplot2::midwest)

# Q1. mpg 데이터의 cty(도시 연비)와 hwy(고속도로 연비) 간에 어떤 관계가 있는지 알아보려고 합니다.
# x 축은 cty, y 축은 hwy 로 된 산점도를 만들어 보세요.
g1 = ggplot(mpg, aes(cty, hwy)) + 
      geom_point()
g1

# Q2. 미국 지역별 인구통계 정보를 담은 ggplot2 패키지의 midwest 데이터를 이용해서 
# 전체 인구와 아시아인 인구 간에 어떤 관계가 있는지 알아보려고 합니다. 
# x 축은 poptotal(전체 인구), y 축은 popasian(아시아인 인구)으로 된 산점도를 만들어 보세요.
# 전체 인구는 50 만 명 이하, 아시아인 인구는 1 만 명 이하인 지역만 산점도에 표시되게 설정하세요
g2 = ggplot(midwest, aes(poptotal, popasian)) + 
      geom_point() + 
        xlim(1, 500000) +
          ylim(1, 10000)
g2

# ========================================================================================

str(mpg)

table(mpg$cyl) # cyl는 4, 5, 6, 8이라는 경우만 있다.

ggplot(mpg, aes(cyl, cty)) +
  geom_point()
# 그래서 cyl이 x축이 되면 그래프가 x = 4, 5, 6, 8에 몰려 나타나서 구분이 힘들다. 

# 그럼 구분이 가능하게 하려면?

# 색깔 주기 --- color = 변수, color = as.factot(변수) ~~~ 색이 더 다양해짐.
ggplot(mpg, aes(displ, cty, color = as.factor(cyl))) + 
  geom_point()
# 또한, 색을 줌으로써 3개의 변수에 대해 1개의 그래프로 구분이 가능하다.

# 점 모양 바꾸기 --- shape = 변수, shape = as.factor(변수) ~~~ 모양이 더 다양해짐. 
ggplot(mpg, aes(displ, cty, color = as.factor(cyl), shape = as.factor(drv))) + 
  geom_point()

# ---------------------------------------------------------------------------------------------------

