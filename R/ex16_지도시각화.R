# 지도 시각화를 해보자
# 지도위에 통계 값 표시하기

# 패키지 설치 & 로드
# ggplot2::map_data()함수가 지도 데이터를 처리하기 위해 필요한 패키지
install.packages("maps") 
install.packages("ggplot2") 
install.packages("mapproj") # ggplot2::coord_map()함수가 사용하는 패키지
library(ggplot2)

# 동북아시아 지도 만들기

# 지역 정보를 가지고 있는 데이터 프레임 만들기
asia_map = map_data(map = "world",
                    region = c("North Korea", 
                               "South Korea", 
                               "Japan", 
                               "china", 
                               "India"))
str(asia_map)
head(asia_map)
tail(asia_map)
# longitude(경도) : 영국 그리니치 천문대를 기준으로 동, 서 좌표
# latitude(위도) : 적도를 기준으로 남, 북 좌표
# order : 선분으로 이어질 점들의 순서
# group : 함께 연결할 위도, 경도 점들을 그룹화(나라, 주, 도시 등)

# 지도 그리기
# ggplot2 패키지를 사용 시, 
# 데이터 파라미터 : 위도, 경도 정보를 가지고 있는 map 데이터를 전달
# x축 mapping 파라미터 : long(경도)
# y축 mapping 파라미터 : lat(위도) 
# 그래프 종류 : geom_ploygon()
ggplot(data = asia_map, mapping = aes(x = long, y = lat, group = group, fill = region)) +
  geom_polygon() +
  coord_map("polyconic") 
# x 좌표와 y 좌표 간격을 다르게 설정해, 보기 좋게 만들어준다.
# "polyconic" ---> 극 지방에 맞추어 지도를 둥글게 만들어 준다

# 대한민국 지도 그리기
korea_map = map_data(map = "world",
                     region = c("South Korea" ,
                                "North Korea"))
head(korea_map)

ggplot(korea_map, aes(long, lat, group = group, fill = region)) +
  geom_polygon(color = "black") + # color를 주면 경계선을 그려준다.
  coord_map("polyconic")

# 미국 지도 그리기(주, state)
us_state = map_data(map = "state")

str(us_state)
head(us_state)
tail(us_state)

ggplot(us_state, aes(long, lat, group = group, fill = region)) +
  geom_polygon(color = "black") +
  coord_map("polyconic")

# --------------------------------------------------------------------------------

# 단계 구분도(Choropleth Map)
# • 지역별 통계치를 색깔의 차이로 표현한 지도
# • 인구나 소득 같은 특성이 지역별로 얼마나 다른지 쉽게 이해할 수 있음
 
# 미국 주별 강력 범죄율 단계 구분도 만들기

# 패키지 설치 & 로드
library(dplyr) # 데이터 전처리 위함
library(tibble) # rownames_to_column() 사용하기 위함
search()

# 데이터 프레임 구성
str(USArrests)
head(USArrests)
tail(USArrests)

# USArrests 데이터 프레임에는 각 state의 이름들이 행 이름으로 설정 되어있음.
# us_map 데이터프레임과 Join하기 위해서는 state 이름들이 데이터 프레임 변수로 있어야 한다.
us_crime = rownames_to_column(USArrests, var = "state")

# 컬럼명은 state, 변수에는 state 이름들이 추가되었다.
str(us_crime)
head(us_crime)
tail(us_crime)

# us_state의 region 변수는 모두 소문자인데, us_crime은 첫글자가 대문자.
# 따라서 모두 소문자로 바꾸어주자.
us_crime$state = tolower(us_crime$state)
head(us_crime)

# 이제 us_state와 us_crime 데이터 프레임을 Join 해보자.
state_crime = left_join(us_state, us_crime, 
                        by = c("region" = "state")) # 조인 조건에 region과 state는 같다고 알려줌.
head(state_crime)

# 지도를 그려보자

# state 별, 살인 사건 발생률
ggplot(state_crime, aes(long, lat, group = group, fill = Murder)) +
  geom_polygon(color = "black") +
  coord_map("polyconic") +
  scale_fill_continuous(low = "white", high = "darkred")
# 발생률은 연속적인 값이기 때문에 scale_fill_continuous를 사용.
# 발생률이 낮은곳은 흰색, 높은곳은 파란색으로 

# state 별, 폭력 사건 발생률
ggplot(state_crime, aes(long, lat, group = group, fill = Assault)) +
  geom_polygon(color = "black") +
  coord_map("polyconic") +
  scale_fill_continuous(low = "white", high = "blue")

# state 별, 강간 사건 발생률
ggplot(state_crime, aes(long, lat, group = group, fill = Rape)) +
  geom_polygon(color = "black") +
  coord_map("polyconic") +
  scale_fill_continuous(low = "white", high = "black")


# ggiraphExtra 패키지를 이용해 단계 구분도 그리기
install.packages("ggiraphExtra")
library(ggiraphExtra)

ggChoropleth(data = us_crime,
             mapping = aes(fill = Murder,
                           map_id = state),
             map = us_state)

# ggChoropleth()의 변수들
# data : 통계값이 들어있는 데이터 프레임
# map : 지도를 그릴 수 있는 데이터 프레임(위도, 경도, 지역, 그룹 등을 가짐)
# mapping 
# 1) map_id : 데이터와 map을 join 할 수 있는 통계 데이터 프레임의 변수 이름.
#    map의 region과 일치하는 데이터 변수.
# 2) fill : 지도의 각 그룹을 색으로 채울 변수.(살인 사건 발생률 등)

ggChoropleth(data = us_crime, map = us_state,
             mapping = aes(fill = Murder,
                           map_id = state),
             interactive = T)
# interactive = T로 설정하고, 지역에 마우스을 올리면 지역명과 해당 수치가 나온다.

# --------------------------------------------------------------------------------

# 문자 인코딩, 변환 관련 기능 패키지 설치
install.packages("stringi")

# 개발자 도구 설치
install.packages("devtools")

# 대한민국 시도별 인구, 결핵 환자 수 단계 구분도 만들기

# Github에서 데이터 다운로드
devtools::install_github("cardiomoon/kormaps2014")

# install.packages() ---> R 공식 홈페이지에서 다운로드
# devtools::install_github ---> Github.com에서 다운로드

# 필요 패키지 로드
library(kormaps2014)
library(ggplot2)
library(dplyr)
library(ggiraphExtra)
search()

# kormaps2014 패키지의 인구 조사 데이터 프레임
str(korea_map)

# str(korpop1)
# 그런데 데이터 프레임의 컬럼 이름들이 한글이어서 제대로 보이지가 않는다.
str(changeCode(korpop1))
# kormaps2014::changeCode() 
# ---> 데이터 프레임의 컬럼(변수)이름이 한글인 것을 처리해줌.

head(korpop1)

head(changeCode(korpop1)) # 거주지역, 인구, 주거형태, ...

# 컬럼 이름이 한글이면 에러가 날 수 있어, 영어로 변경한다.
korpop1 = rename(korpop1, 
                 name = 행정구역별_읍면동,
                 pop = 총인구_명)
korpop1

# korpop1(거주지역, 인구)를 그려보자.
ggChoropleth(data = korpop1, map = kormap1,
             mapping = aes(fill = pop, map_id = code, tooltip = name),
             interactive = T)

# tbc : 결핵 환자 수 데이터 프레임
head(changeCode(tbc))

ggChoropleth(data = tbc, map = kormap1,
             mapping = aes(fill = NewPts, map_id = code, tooltip = name1),
             interactive = T)

tbc2015 = tbc %>% 
  filter(year == 2015)

ggChoropleth(data = tbc2015, map = kormap1,
             mapping = aes(fill = NewPts, map_id = code,
                           tooltip = name),
             interactive = T)
