# Red Wine 품질 데이터를 이용한 회귀 트리 / 모델 트리 학습

# 데이터 준비 & 확인
redwine = read.csv("data/redwines.csv")
str(redwine)

# 모델 훈련 위한 학습 데이터 세트(75%) / 테스트 데이터 세트(25%)
1599 * 0.75 # = 1199.25
red_train = redwine[1:1199, ]
red_test = redwine[1200:1599, ]

# 학습 데이터 세트를 rpart 패키지를 사용해 학습(분류기 구축)
red_rpart = rpart(quality ~ ., data = red_train)
red_rpart
summary(red_rpart)

# 생성한 회귀 트리 시각화(트리 다이어그램)
rpart.plot(red_rpart)

# 모델 성능 평가 ---> predict()
predict_red_rpart  = predict(red_rpart, red_test)
summary(predict_red_rpart)
summary(redwine$quality)

# 모델 평가 위해, 상관 계수 구하기
cor(predict_red_rpart, red_test$quality) # 0.598743

# MRE(평균 절대 오차)를 통한 모델 평가
mae = function(actual, predicted){
  return(mean(abs(actual - predicted)))
}
mae(predict_red_rpart, red_test$quality) # 0.5378421

# 회귀 트리를 모델 트리로 확장
# Cubist::cubist() 
red_cubist = cubist(x = red_train[-12], y = red_train$quality)
red_cubist
summary(red_cubist)

# 모델 성능 평가
predict_red_cubist = predict(red_cubist, red_test)
summary(predict_red_cubist)
summary(red_test$quality)

# 상관 계수 / MRE
cor(predict_red_cubist, red_test$quality) # 0.6715268
mae(red_test$quality, predict_red_cubist) # 0.4532385

