rm(list = ls())

windows()

# col() 그래프에 변수 추가하기
# 3개 이상의 변수를 한 그래프에서 표현해 보자.
exam = read.csv("data_excel/csv_exam.csv")
str(exam)                
head(exam)
tail(exam)

exam_by_class = exam %>% 
  group_by(class) %>% 
  summarise(math = mean(math),
            english = mean(english),
            science = mean(science))

exam_by_class

# x축 : 반, y축 : 과목점수로 그래프 그리기
ggplot(exam_by_class, aes(class, math)) +
  geom_col()
# 이 그래프는 한 번에 1 과목 점수밖에 표현 할수 없다.

# 한 그래프에 3과목 점수를 모두 표현하려면?

# 패키지 & 라이브러리 설치
install.packages("tidyr")
library(tidyr)

# tidyr::gather() 함수
# pivoting(= melting)을 해준다. 즉, 행과 열을 바꾸어 준다. 행 -> 열, 열 -> 행.
df = exam_by_class %>% 
  gather(key = "subject", value = "mean", -class)

df

# gather() 함수를 적용시킨 df를 그래프로 그리면
ggplot(df, aes(class, mean, fill = subject)) +
  geom_col(position = "dodge")

# gather() 함수의 다른 예제
exam_by_class %>% 
  gather("var", "value", science)
# math, english는 유지되고 science는 var, value로 바뀌었다.(pivoting 됨)

exam_by_class %>% 
  gather("var", "value", english, science)
# math는 유지되고 english, science는 var, value로 바뀌었다.(pivoting 됨)

