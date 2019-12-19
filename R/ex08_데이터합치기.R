# 데이터를 합쳐보자.
# 오라클의 'Join'과 같다.

# 방법 1) '가로'로 합치기. 즉, '컬럼'을 이어붙이는 것. 
# 관계형 DB처럼 여러 테이블에 나누어져 있는 데이터들을 'Join'해서 하나의 데이터 프레임으로 만듦. 

# 방법 2) '세로'로 합치기. 즉, '행'을 이어붙이는 것.
# 하나의 데이터의 행의 개수가 너무 많아서 여러 파일로 나누어져 있을 경우, 다시 하나로 만드는 것.

# ---------------------------------------------------------------------------------------------------
  
# 1) '가로'로 합치기 --- '컬럼'을 이어붙이기. 
# join(데이터프레임1, 데이터프레임2, by = "컬럼이름")

# Join의 종류
# 'Join'을 이용해 두 데이터 프레임을 하나의 데이터프레임으로 합칠수 있다.
# [주의] by에 변수명을 지정할 때 변수명 앞 뒤에 더블쿼텟 ("") 입력
df1 <- data.frame(id = c(1, 2, 3, 4), var1 = c(11, 22, 33, 44))
df1
df2 <- data.frame(id = c(1, 2, 3, 5), var2 = c(50, 60, 70, 80))
df2

# (1) inner_join()
inner_join(df1, df2, by = "id")

# (2) left_join()
left_join(df1, df2, by = "id")

# (3) right_join()
right_join(df1, df2, by = "id")

# (4) full_join()
full_join(df1, df2, by = "id")

# 최종성적 = 중간성적 + 기말성적
test1 = data.frame(id = c(1, 2, 3, 4, 5),
                   mid_score = c(60, 70, 80, 90, 100))
test2 = data.frame(id = c(1, 2, 3, 4, 5),
                   fin_score = c(100, 90, 80, 70, 60))

# id를 기준으로 합치려면?
total = left_join(test1, test2, by = "id")
total

# 다른 데이터를 활용해 변수를 추가하려면?
# exam에 담임 선생님을 추가하려면?
exam = read.csv("data_excel/csv_exam.csv")
head(exam)

name = data.frame(class = c(1, 2, 3, 4, 5),
                  teacher = c("han", "lee", "kim", "park", "choi"))

exam_new = left_join(exam, name, by = "class")
head(exam_new)

# ---------------------------------------------------------------------------------------------------
  
# 2) '세로'로 합치기 --- '행'을 이어붙이기.
# bind_row(데이터프레임1, 데이터프레임2)

# 학생 1 ~ 5번 시험 성적 데이터 생성.
group_a = data.frame(id = c(1, 2, 3, 4, 5),
                     score = c(100, 90, 80, 70, 60))
group_a

# 학생 6 ~ 10번 시험 성적 데이터 생성.
group_b = data.frame(id = c(6, 7, 8, 9, 10),
                     score = c(60, 70, 80, 90, 100))
group_b

# group_a와 group_b를 합쳐 모든 학생의 시험 성적을 출력하려면?
group_all = bind_rows(group_a, group_b)
group_all

# 실습 1!!! ========================================================================================

library(dplyr)
mpg = as.data.frame(ggplot2::mpg)

# mpg 데이터의 fl 변수는 자동차에 사용하는 연료(fuel)를 의미합니다. 
# 이 정보를 이용해서 연료와 가격으로 구성된 데이터 프레임을 만들어 보세요.
fuel = data.frame(fl = c("c", "d", "e", "p", "r"),
                  price = c(2.35, 2.38, 2.11, 2.76, 2.22),
                  stringsAsFactors = F)
fuel

# Q1. mpg 데이터에는 연료 종류를 나타낸 fl 변수는 있지만 연료 가격을 나타낸 변수는 없습니다. 
# 위에서 만든 fuel 데이터를 이용해서 mpg 데이터에 price_fl(연료 가격) 변수를 추가하세요.
mpg_fl = left_join(mpg, fuel, by = "fl")
head(mpg_fl)

# Q2. 연료 가격 변수가 잘 추가됐는지 확인하기 위해서 model, fl, price_fl 변수를 추출해 
# 앞부분 5 행을 출력해 보세요.
mpg_fl %>% 
  select(model, fl, price) %>% 
    head(5)

# ========================================================================================

# 분석 도전!!! ========================================================================================

# 미국 동북중부 437개 지역의 인구통계 정보를 담고 있는 midwest 데이터를 사용해 데이터 분석 문제를
# 해결해 보세요. midwest는 ggplot2 패키지에 들어 있습니다.
library(dplyr)
midwest1 = as.data.frame(ggplot2::midwest)
midwest1

# 문제 1. popadults 는 해당 지역의 성인 인구, poptotal 은 전체 인구를 나타냅니다. midwest 데이터에
# '전체 인구 대비 미성년 인구 백분율' 변수를 추가하세요.
midwest1 = midwest1 %>% 
            mutate(teenage = (poptotal - popadults) / poptotal * 100)
head(midwest1)

# 문제 2. 미성년 인구 백분율이 가장 높은 상위 5 개 county(지역)의 미성년 인구 백분율을 출력하세요.
midwest1 %>% 
  arrange(desc(teenage)) %>% 
    select(county, teenage) %>% 
      head(5)

# 문제 3. 분류표의 기준에 따라 미성년 비율 등급 변수를 추가하고, 
# 각 등급에 몇 개의 지역이 있는지 알아보세요.
# 분류 기준 - large 40% 이상 / middle 30% ~ 40% 미만 / small 30% 미만
midwest1 = midwest1 %>% 
            mutate(teenage_grade = ifelse(teenage >= 40, "large",
                                      ifelse(teenage >= 30, "middle", "small")))
table(midwest1$teenage_grade)

# 문제4. popasian은 해당 지역의 아시아인 인구를 나타냅니다. 
# '전체 인구 대비 아시아인 인구 백분율' 변수를 추가하고, 
# 하위 10개 지역의 state(주), county(지역명), 아시아인 인구 백분율을 출력하세요.
midwest1 %>% 
  mutate(asian_ratio = (popasian / poptotal) * 100) %>%
    arrange(asian_ratio) %>% 
      head(10) %>% 
        select(state, county, asian_ratio)

# ========================================================================================