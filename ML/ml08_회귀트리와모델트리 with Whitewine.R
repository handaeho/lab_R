# 와인 품질 평가 데이터를 통한 회귀 트리와 모델 트리 학습

# 데이터 준비 & 확인
wine = read.csv("data/whitewines.csv")
str(wine) # 4898개 예시(행) / 12개 특징(열)
summary(wine)
hist(wine$quality)


# 회귀 트리를 사용하기 위한 패키지 설치 & 로드
install.packages("rpart")
library(rpart)

# 모델 훈련 위한, 학습 데이터 세트(75%) / 테스트 데이터 세트(25%)
# 현재 wine 데이터는 이미 무작위로 섞여있다. 만약, 정렬되어 있다면 sample()로 무작위 추출 필요.
wine_train = wine[1:3674, ]
wine_test = wine[3675:4898, ]

# 학습 데이터 세트를 rpart 패키지를 사용해 학습(분류기 구축)
wine_rpart = rpart(formula = quality ~ ., data = wine_train)
wine_rpart
summary(wine_rpart)
# 현재 '회귀 트리'라고 생성되었으나, 사실 회귀 공식을 사용하지는 않았다.

# 생성한 회귀 트리 시각화(트리 다이어그램)
install.packages("rpart.plot")
library(rpart.plot)
rpart.plot(wine_rpart, digits = 3)

# 모델 성능 평가 ---> predict()
predict_wine_rpart = predict(wine_rpart, wine_test)
summary(predict_wine_rpart)
summary(wine_test$quality)

# 예측된 값과 실제 값의 상관 관계 파악 ---> 모델 성능 평가 지표가 됨.
# 상관 계수 함수 cor() : 같은 길이의 두 벡터간의 관계 측정
cor(predict_wine_rpart, wine_test$quality)

# '평균 절대 오차'로 모델 성능 평가 ---> 평균적으로 예측이 실제와 얼마나 다른가?
# MAE(평균 절대 오차, Mean Absolute Error) = mean(abs(실제값 - 예측값)) ~> 실제값과 예측값 차이의 절대값의 평균
mae = function(actual, predicted){
  return(mean(abs(actual - predicted)))
}
mae(wine_test$quality, predict_wine_rpart)
# 평균적으로 예측 값과 실제 값의 차이는 0.6037949 ---> 괜찮은 성능 but, 개선의 여지 존재

# 모델 성능 개선

# 회귀 트리를 '모델 트리'로 표현해 보자.
# Model Tree = Regression Tree + Regression Modeling

# 교재 : M5 모델 트리 알고리즘 ---> RWeka::M5P()
# 실습 : Cubist::cubist() ---> 규칙 학습 기반 분류 + M5P 알고리즘 회귀 모델 (M5P의 Upgrade)

# RWeka::M5P() Ver. ------------------------------------------

# RWeka 패키지 설치 & 로드
install.packages("RWeka")
library(RWeka)

# 학습 데이터 세트를 M5P() 함수 사용해 학습(분류기 구측)
wine_m5p = M5P(formula = quality ~ ., data = wine_train)
wine_m5p
summary(wine_m5p)

# 모델 성능 평가
predict_wine_m5p = predict(wine_m5p, wine_test)
summary(predict_wine_m5p)
summary(wine_test$quality)

cor(predict_wine_m5p, wine_test$quality)
mae(wine_test$quality, predict_wine_m5p)

# ----------------------------------------------------

# Cubist::cubist() Ver. ------------------------------------------ 

# Cubist 패키지 설치 & 로드
install.packages("Cubist")
library(Cubist)

# 학습 데이터 세트를 cubist() 함수 사용해 학습(분류기 구축)
# 학습 데이터에는 레이블(클래스). 즉, 종속 변수가 포함되면 안된다.
# cubist(x = 훈련 데이터, y = 훈련 데이터 결과)
wine_cubist = cubist(x = wine_train[-12], y = wine_train$quality) 
wine_cubist
summary(wine_cubist)

# 모델 성능 평가
predict_wine_cubist = predict(wine_cubist, wine_test)
summary(predict_wine_cubist)
summary(wine_test$quality)

cor(predict_wine_cubist, wine_test$quality) # 0.640193 ---> 회귀트리의 상관 계수(0.5354775) 보다 1에 가까워짐.
mae(wine_test$quality, predict_wine_cubist) # 0.5379868 ---> 회귀 트리 모델(0.6037949)보다 예측 값과 실제 값 차이 감소.

# ----------------------------------------------------

