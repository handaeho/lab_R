# Insurance(미국 의료비 데이터)를 통한 다중 선형 회귀 학습

# 데이터 준비 & 확인
insurance = read.csv("data/insurance.csv")
str(insurance)
summary(insurance)
head(insurance)

# expenses(의료비) 항목 분석 
summary(insurance$expenses)
hist(insurance$expenses)
boxplot(insurance$expenses)

# 다른 항목 분석
table(insurance$region)
table(insurance$sex)
table(insurance$smoker)
table(insurance$children)
summary(insurance$age)
summary(insurance$bmi)

# 상관 계수 ---> cor(a, b)
# cor = cov(a, b) / (a의 표준편차 * b의 표준편차)
cor(insurance$bmi, insurance$expenses)

# 상관 계수들로만 이루어진 행렬 ---> 상관 행렬
cor(insurance[c("age", "bmi", "children", "expenses")]) # 수치형 변수만 허용됨.

# 산포도 행렬 ~> 모델링 전에 변수 간의 관계를 시각적으로 파악하기 위함.
pairs(insurance[c("age", "bmi", "children", "expenses")])

# 더 다양한 산포도 행렬
install.packages("psych")
library(psych)
pairs.panels(insurance[c("age", "bmi", "children", "expenses")])            

# 다중 회귀 분석 모델링
# y(종속 변수) => expenses / x1 ~ x6(독립 변수) => age, sex, bmi, children, smoker, region
ins_model = lm(expenses ~ ., data = insurance)
ins_model
summary(ins_model)

# 모델 성능 개선 

# (1) 선형 회귀 모델에 '비선형 관계'를 추가.
# expenses는 전 age에 걸쳐 선형으로 일정하지 않을 것. 따라서 나이의 비선형 항을 추가.
insurance$age2 = insurance$age^2
head(insurance[c("age", "age2")])

# (2) 수치 변수를 이진 지시 변수로 변환.
# bmi가 정상이 아닌 사람들은 높은 의료비와 강한 연관이 있을것.
# 따라서 bmi가 30 이상이면 1, 아니면 0으로 표현
insurance$bmi30 = ifelse(insurance$bmi >= 30, 1, 0)
head(insurance[c("bmi","bmi30")])

# (3) 상호 작용 영향 추가
# 비만과 흡연은 상호 작용 할까? 만약 한다면 의료비에 대한 영향은?
# 표현식 : bmi * smoker
# 별도의 변수 추가는 필요하지 않음. 모델링 시, 추가하면 된다.
 
# 개선된 회귀 모델링
ins_model2 = lm(expenses ~ age + age2 + children + bmi + sex +bmi30 * smoker + region, data = insurance)
summary(ins_model2)

# 기존 모델 : Multiple R-squared:  0.7509,	Adjusted R-squared:  0.7494
# 개선 모델 : Multiple R-squared:  0.8664,	Adjusted R-squared:  0.8653 
# 또한, age에 비해 age2는 훨씬 유의미 해졌으며, bmi30 역시 유의미하다.
# 그리고 [bmi30:smokeryes 19810.1534 604.6769  32.762  < 2e-16 ***] 를 통해 
# 흡연자이면서 bmi가 30 이상이라면 expenses를 추가로 연간 약 $19810를 추가 지출한다.
