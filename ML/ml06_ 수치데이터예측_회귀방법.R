# 수치 데이터 예측 : 회귀(Regression) 방법

# 수치 관계의 크기와 강도를 모델링하는 기법인 회귀(Regression)에 사용되는 기본 통계 원칙
# ● 회귀 분석을 위한 데이터 준비와 회귀 모델을 추정하고 해석하는 방법
# ● 수치 예측 작업에 의사결정 트리 분류기를 적용하는 회귀 트리와 모델 트리라고 하는 한쌍의 하이브리드 기법

#---------------------------------------------------------------------------------------------------------

# 1) 단순 선형 회귀(Simple Linear Regression)
# = 하나의 종속 변수(y)와 하나의 독립(설명) 변수(x) 간의 관계를 다음 방정식 형태의 직선으로 정의하는 것
# y = α + βx (α: y 절편(intersection), β: 기울기(slope))
# 일반적으로 최소제곱법(least squared method)를 사용해 α와 β를 결정

# 아들의 키는 아빠의 키에 영향을 받을까?

# 데이터 준비 & 확인
heights = read.csv("data/heights.csv")
str(heights)
head(heights)
tail(heights)
# 아들 키 : y / 아빠 키 : x

# 데이터 분포(father, son)
summary(heights)
hist(heights$father)
hist(heights$son)
boxplot(heights$father)
boxplot(heights$son)

# 산점도 그래프(Scatter plot)
plot(heights, col= rgb(0.7, 0.2, 0.2, 0.5)) # col = (red, green, blue, 불투명도)
abline(h = mean(heights$son)) # heights$son의 mean이 수평 보조선으로 plot에 출력, h : 수평 / v : 수직
abline(v = mean(heights$father))

# lm() : Linear Regression Model(선형 회귀 모델)
lm_heights = lm(formula = son ~ father, 
                data = heights)
lm_heights
# Coefficients: (Intercept) 86.1026 / father  0.5139
# Intercept 86.1026 ---> y절편, father 0.5139 ---> father에 대한 son의 기울기
summary(lm_heights) # Pr(>|t|) ---> 우연히 해당 값과 일치할 확률. 낮을수록 좋다.   

# 선형 모델에서 찾은 계수를 이용해, 선형 모델 그래프 추가
abline(a = 86.10257, b = 0.51391)

# ggplot2를 이용해서 그릴수도 있다.
library(ggplot2)
ggplot(data = heights, 
       mapping = aes(x = father, y = son)) +
  geom_point(color = rgb(0.7, 0.2, 0.2, 0.5)) +
  geom_hline(yintercept = mean(heights$son), linetype = "dashed", color = "darkblue") +
  geom_vline(xintercept = mean(heights$father), linetype = "dashed", color = "darkblue") +
  stat_smooth(method = "lm")

#---------------------------------------------------------------------------------------------------------

# OLS: Ordinary Least Squares
# =  OLS 회귀의 목표는 잔차(오차)들의 제곱합을 최소화하도록 기울기 β를 결정하는 것

# 선형 회귀 모델식 : y = α + βx
# α = y - βx, α = mean(y) - β * mean(x)
# ~> 선형 회귀 평균 그래프는 x와 y의 평균을 반드시 지나간다. 따라서, β를 알면 α를 알 수 있다.
# β = 공분산(x,y) / 분산(x)
m_x = mean(heights$father)
m_y = mean(heights$son)

cov_xy = cov(heights$father, heights$son) # x,y의 공분산
var_x = var(heights$father) # x의 분산

b = cov_xy / var_x
a = m_y - b * m_x # α = mean(y) - β * mean(x)

# 피어슨 상관 계수(Pearson's Correlation Coefficient) ---> cor(x, y)
# 상관 관계 : 변수들간의 관계가 직선에 가깝게 따르는 정도
# -1 <= Corr <= 1, 극값은 완벽한 선형 관계, 0에 가까울수록 선형 관계 없음.
cor_xy = cor(heights$father, heights$son)

#---------------------------------------------------------------------------------------------------------

# Challenger호 데이터를 통한 선형 회귀 학습

# 데이터 준비 & 확인
launch = read.csv("data/challenger.csv")
str(launch)
head(launch)
summary(launch)

# 1) 단순 선형 회귀 ~> 1개 독립 변수에 따른 종속 변수의 변화
# y : distress_ct / x : temperature
plot(launch$temperature, launch$distress_ct)

# 단순 선형 회귀 모델
lm_launch = lm(formula = distress_ct ~ temperature, data = launch)
lm_launch # (Intercept) 3.69841 / temperature -0.04754
summary(lm_launch)

a = lm_launch$coefficients[1] # 단순 선형 모델의 y절편(3.69841)
a
b = lm_launch$coefficients[2] # 단순 선형 모델의 기울기(-0.04754)
b

# 단순 선형 회귀 모델 그래프 추가
abline(a, b, col = "blue")

# 2) 다중 선형 회귀 ~> 복수개의 독립 변수에 따른 종속 변수의 변화
# y ~ x1 + x2 + x3 + ...
# y : distress_ct / x1 : temperature / x2 : field_check_pressure / x3 : flight_num
str(launch)
lm_launch = lm(formula = distress_ct ~ ., data = launch)
summary(lm_launch)

#---------------------------------------------------------------------------------------------------------
