# 조건에 맞는 데이터만 추출해보자.

# 데이터프레임의 n행 m열 출력
# 데이터프레임이름[n, m]
# 행 또는 열번호를 생략하면 전체 행 또는 열을 출력한다. 
# ---> exam[1, ]라면 1행의 전체 열을 출력. exam[, 2]이라면 2열의 전체 행을 출력.
exam[1, 5] 
exam[5, ] # --- select * from exam where id = 5
exam[, 4] # --- select english from exam

# 여러개의 행 / 열을 한 번에 추출해보자
exam[1:4, ] # 1행부터 4행까지 출력.
exam[, 3:5] # 3열부터 5열까지 출력.
exam[seq(1, 20, 4), ] # id가 1부터 20까지 4씩 증가하면서 출력
exam[c(1, 10, 20), ] # id가 1번, 10번, 20번을 출력

# True / False로 데이터 추출
exam$class == 1 # class == 1이면 true, 아니면 false
exam[exam$class == 1, ] # 해당 논리에 true가 되는 모든 행을 출력.

# AND 연산자 '&' / OR 연산자 '|' 
exam[exam$class == 1 | exam$class == 2, ] # 1반이거나 2반인 학생의 모든 행을 출력.

# '%in%' 연산자 --- ~~ 안에 있으면 ~~
exam[exam$class %in% c(3, 4), ] # 3반이거나 4반인 모든 학생의 행을 출력.

# 수학 점수가 50점 이상인 학생의 id, class, math를 출력한다면?
exam[exam$math >= 50, c(1, 2, 3)] 
# -- 오라클의 'where절'에 해당되는 '조건'은 '행'에, 
# -- 'select절'에 해당되는 '컬럼명'은 '열'에 기입.

# 컬럼명이 있는 경우에는  인덱스가 아닌 컬럼명으로 사용할 수 있다.
# 과학 점수가 60점 이상인 학생의 id, class, science를 출력한다면?
exam[exam$math >= 50, c("id", "class", "science")]

# 영어 점수가 평균 이상인 학생의 id, class, english를 출력한다면?
exam[exam$english >= mean(exam$english), c("id", "class", "english")]

# 1반 학생들의 수학 점수 평균
class1 <- exam[exam$class == 1, ]
mean(class1$math)

# -------------------------------------------------------------------------------------

  # 이번에는 'ggplot2::mpg'를 이용해보자.
mpg <- as.data.frame(ggplot2::mpg)
mpg

# mpg 데이터 프레임에서 1 ~ 6행의 cty와 hwy를 출력한다면?
mpg[1:6, c("cty", "hwy")]

# mpg에서 cty가 평균 이상이고, hwy도 평균 이상인 자동차의 model, cty, hwy를 출력한다면?
mpg[mpg$cty >= mean(mpg$cty) & mpg$hwy >= mean(mpg$hwy), c("model", "cty", "hwy")]

# -------------------------------------------------------------------------------------

