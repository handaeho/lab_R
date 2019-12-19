# 필요 패키지 설치 & 로드
install.packages("plotly")
library(plotly)
library(ggplot2)
library(dplyr)
search()

# ggplot2에서 제공하는 학습용 mpg 데이터 프레임(자동차 관련 데이터)
str(mpg)

# 배기량과 고속도로 연비, 구동방식과의 관계
g = ggplot(mpg, aes(displ, hwy, color = drv)) +
    geom_point()

# plotly::ggplotly(ggplot 객체) ---> interactive = T 설정으로 그래프가 그려진다.
ggplotly(g)

# 구동 방식 별 boxplot
g = ggplot(data = mpg, mapping = aes(x = drv, y = hwy)) +
    geom_boxplot()

ggplotly(g)

# diamonds 데이터 프레임(다이아몬드에 관한 데이터)
str(diamonds)

# 다이아몬드 등급과 투명도에 따른 개수 분포 막대 그래프
g = ggplot(diamonds, aes(cut, fill = clarity)) +
    geom_bar(position = "dodge")

ggplotly(g)

# economics 데이터프레임
str(economics)

# 시간에 따른 개인 저축률의 변화 선 그래프 ---> 시계열 그래프
g = ggplot(economics, aes(date, psavert)) +
  geom_line()

ggplotly(g)

# 시계열 데이터에 대한 더 많은 기능을 가진 패키지 설치 & 로드
install.packages("dygraphs")
library(xts)
library(dygraphs)

# dygraphs 패키지를 이용해 시계열 데이터 그래프 그리기
eco_pasvert = xts(x = economics$psavert, order.by = economics$date)
str(eco_pasvert)
dygraph(eco_pasvert) %>%  dyRangeSelector()
# dyRangeSelector() : 구간 확대 기능

# 실업률 변수 추가
economics = ggplot2::economics
economics$unemprt = (economics$unemploy / economics$pop) * 100
head(economics$unemprt)

eco_unemprt = xts(x = economics$unemprt, order.by = economics$date)
str(eco_unemprt)
head(eco_unemprt)
dygraph(eco_unemprt) %>% dyRangeSelector()

# dyGraph에서 시계열 그래프를 2개 이상 그리려면?
data = cbind(eco_pasvert, eco_unemprt)
str(data)
head(data)
# cbind() : 두 개의 데이터를 컬럼으로 바인드한다.

# 2개의 데이터를 1개의 그래프로 그리기
dygraph(data) %>% dyRangeSelector()
