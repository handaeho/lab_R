# 데이터를 정제해보자.

# ===============================================================================================
# 1] 결측치 정제. 즉, 빠진 데이터를 정제하려면?
# 결측치 = 누락된 값, 비어있는 값 ---> 함수를 쓸 수 없고, 분석 결과가 왜곡된다. 따라서 제거 필요.

# 먼저 결측치를 만들어보자.
# 결측치 표기 = NA --- 대문자여야 한다.
df = data.frame(gender = c("M", "F", NA, "M", "F"),
                score = c(5, 4, 3, NA, 6))
df

# 데이터 프레임 구조 파악
str(df)
# 기술통계량 확인
summary(df)

# is.na() = NA인 경우 True, 아니면 False를 리턴. 
is.na(df) # 데이터 프레임의 각 변수의 NA 여부를 리턴.
is.na(df$gender)
is.na(df$score)

# NA를 제거하기 위해서는 !is.na()를 사용하면 된다.
df %>% 
  filter(!is.na(gender))
df %>% 
  filter(!is.na(gender) & !is.na(score)) 

# NA가 하나라도 있으면 제거하기 위해서는 na.omit()을 사용한다.
# 단, 필요한 데이터까지 제거 될 수 있으니 주의.
df_omit = na.omit(df)

# ---------------------------------------------------------------------------------------------------

# df 데이터 프레임에서 성별, 점수의 평균을 출력하려면?
df %>% 
  group_by(gender) %>% 
    summarise(mean = mean(score)) # --- 연산 시, NA 값 때문에 결과값이 부정확하다.

df %>% 
  filter(!is.na(gender) & !is.na(score)) %>% 
    group_by(gender) %>% 
      summarise(mean = mean(score)) # NA값을 제거하고 연산해서 결과가 정확하다.

# score의 NA를 지우고 평균 계산 하려면?
mean(df$score, na.rm = T)

df %>% 
  group_by(gender) %>% 
    summarise(mean = mean(score, na.rm = T))

# table() = 도수분포표
table(is.na(df$gender))
table(is.na(df))

# ---------------------------------------------------------------------------------------------------

# 결측치를 대체하려면?
# 1) 0으로 대체
df$score = ifelse(is.na(df$score), 0, df$score)
df
df %>% 
  group_by(gender) %>% 
    summarise(mean = mean(score))

# 2) 평균값으로 대체
df[4, 2] = NA # df의 4행 2열을 NA로 --- df[4, "score"] = NA와 같다.
df

# NA를 제외한 평균값 구하기
avg = mean(df$score, na.rm = T)
avg
df$score = ifelse(is.na(df$score), avg, df$score)
df
df %>% 
  group_by(gender) %>% 
    summarise(mean = mean(score))

# 실습 1!!! ========================================================================================

# mpg 데이터 원본에는결측치가 없습니다. 
# 우선 mpg 데이터를 불러와 몇 개의 값을 결측치로 만들겠습니다. 
mpg = as.data.frame(ggplot2::mpg)
mpg[c(65, 124, 131, 153, 212), "hwy"] = NA
mpg

# Q1. drv(구동방식)별로 hwy(고속도로 연비) 평균이 어떻게 다른지 알아보려고 합니다. 
# 분석을 하기 전에 우선 두 변수에 결측치가 있는지 확인해야 합니다. 
# drv 변수와 hwy 변수에 결측치가 몇 개 있는지 알아보세요.
table(is.na(mpg$drv))
table(is.na(mpg$hwy))

# Q2. filter()를 이용해 hwy 변수의 결측치를 제외하고, 어떤 구동방식의 hwy 평균이 높은지 알아보세요.
# 하나의 dplyr 구문으로 만들어야 합니다.
mpg %>% 
  filter(!is.na(hwy)) %>%
    group_by(drv) %>% 
      summarise(avg_hwy = mean(hwy)) %>% 
        arrange(desc(avg_hwy))

# ========================================================================================

# 2] 이상치 정제. 즉, 이상한 데이터를 정제하려면?
# 이상치 = 정상 범주에서 크게 벗어난 값. ---> 분석 결과가 왜곡된다. 따라서 제거 필요.
# 종류 1) 존재할 수 없는 값. --- 0, 1 값만 나와야하는데 3이 나왔다.
# 종류 2) 극단적인 값. --- 몸무게 변수에 9999kg

movie_rating = data.frame(rating = c(5, 4, 3, 4, 5, 3, 10))
movie_rating
# 이때 점수는 1 ~ 5점까지만 가능하다면, 10점은 이상치가 된다.

mean(movie_rating$rating) # 이상치인 10점 때문에 평균이 부정확하다.

# 이상치를 결측치(NA)로 대체
movie_rating$rating = ifelse(movie_rating$rating %in% (1: 5), movie_rating$rating, NA)
movie_rating

mean(movie_rating$rating, na.rm = T) # 이상치를 NA로 대체한 뒤, 제거하고 평균을 계산하면 정확하다.

# ---------------------------------------------------------------------------------------------------

# Outlier --- botplot의 'IOR'에 대해 이해해야 한다.
mpg = as.data.frame(ggplot2::mpg)
summary(mpg$hwy)

# boxplot & 통계치 출력
boxplot(mpg$hwy)
boxplot(mpg$hwy) $ stats

# stats[1, 1] = 아래쪽 수염의 위치
# stats[1, 5] = 위쪽 수염의 위치
# boxplot에서 수염 범위를 벗어난 데이터들을 'Outlier'라고 한다.
# 이런 outlier들을 NA로 처리하고 통계 처리를 하자.

mean(mpg$hwy) # --- outlier가 포함된 평균. 23.44017

# outlier를 NA로 대체
mpg$hwy = ifelse(mpg$hwy < 12 | mpg$hwy > 37, NA, mpg$hwy) 
# NA 개수 확인
table(is.na(mpg$hwy))

mean(mpg$hwy, na.rm = T) # --- outlier이 제거된 평균. 23.18615

mpg %>% 
  group_(drv) %>% 
    summarise(mean_hwy = mean(hwy, na.rm = T))

# 실습 2!!! ========================================================================================

# 우선 mpg 데이터를 불러와서 일부러 이상치를 만들겠습니다. 
# drv(구동방식) 변수의 값은 4(사륜구동), f(전륜구동), r(후륜구동) 세 종류로 되어있습니다. 
# 몇 개의 행에 존재할 수 없는 값 k를 할당하겠습니다. 
# cty(도시 연비) 변수도 몇 개의 행에 극단적으로 크거나 작은 값을 할당하겠습니다.
mpg = as.data.frame(ggplot2::mpg)
mpg[c(10, 14, 58, 93), "drv"] = "k"
mpg[c(29, 43, 129, 203), "cty"] = c(3, 4, 39, 42)

# 이상치가 들어있는 mpg 데이터를 활용해서 문제를 해결해보세요.
# 구동방식별로 도시 연비가 다른지 알아보려고 합니다. 
# 분석을 하려면 우선 두 변수에 이상치가 있는지 확인하려고 합니다.

# Q1. drv 에 이상치가 있는지 확인하세요. 이상치를 결측 처리한 다음 이상치가 사라졌는지 확인하세요. 
# 결측 처리 할 때는 %in% 기호를 활용하세요.
table(mpg$drv)
mpg$drv = ifelse(mpg$drv %in% c("4", "f", "r"), mpg$drv, NA) 
table(mpg$drv)  

# Q2. 상자 그림을 이용해서 cty 에 이상치가 있는지 확인하세요.
# 상자 그림의 통계치를 이용해 정상 범위를 벗어난 값을 결측 처리한 후 
# 다시 상자 그림을 만들어 이상치가 사라졌는지 확인하세요.
boxplot(mpg$cty)
boxplot(mpg$cty) $ stats # ---정상 범위 : 9 ~ 26
mpg$cty = ifelse(mpg$cty < 9 | mpg$cty > 26, NA, mpg$cty)
boxplot(mpg$cty)

# Q3. 두 변수의 이상치를 결측처리 했으니 이제 분석할 차례입니다.
# 이상치를 제외한 다음 drv 별로 cty 평균이 어떻게 다른지 알아보세요. 
# 하나의 dplyr 구문으로 만들어야 합니다.
mpg %>% 
  filter(!is.na(drv) & !is.na(cty)) %>% 
    group_by(drv) %>% 
      summarise(mean_cty = mean(cty))

# ========================================================================================

