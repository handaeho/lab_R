# Data Frame
# 컬럼(열)은 '속성', 로우(행)은 '한 개체의 정보'.
# 열이 증가한다. -> 속성이 증가한다.(성별, 이름 --> 성별, 이름, 나이, 주소)
# 행이 증가한다. -> 개체의 정보가 증가한다.(10명의 정보 --> 100명의 정보)

# Global env.에 저장된 변수들 리스트 -> ls()
ls()
# 변수 삭제 -> rm()
rm(list = ls()) # 모든 전역 변수 삭제

# 데이터 입력해 데이터 프레임을 만들어보자.

# 데이터프레임이름 <- data.frame(입력할 값이 저장된 변수이름1, 변수이름2, ...)
# 각 변수들에 저장된 데이터의 개수는 일치해야함. (각 행과 열의 수가 동일 해야함)
english <- c(90, 80, 70, 60)
math <- c(50, 60, 100, 20)
df_midterm <- data.frame(english, math)
df_midterm

# df_midterm에 열 추가 하기.
class <- c(1, 1, 2, 2)
df_midterm <- data.frame(english, math, class)
df_midterm

# 특정 열의 평균 구하기. -> mean(데이터프레임이름$컬렴이름)
mean(df_midterm$english)
mean(df_midterm$math)

# 데이터 프레임 한 번에 만들기.
df_finalterm <- data.frame(english = c(90, 80, 70, 60),
                           math = c(50, 60, 70, 80),
                           class = c(1, 1, 2, 2))
df_finalterm

# 예제 1.
df_goods <- data.frame('제품' = c('사과', '딸기', '수박'),
                       '가격' = c(1800, 1500, 3000),
                       '판매량' = c(24,38, 13))
df_goods

mean(df_goods$가격)
mean(df_goods$판매량)




