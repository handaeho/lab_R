# 모델 성능 개선

# Decision Trees(의사 결정 나무)

# 데이터 준비
credit = read.csv("data/credit.csv", encoding = "UTF-8")
str(credit)

# modelLookup(" ") => C5.0 모델(의사 결정 트리)에서 성능 향상을 위해 변경 가능한 파라미터 리스트를 보여준다.
library(caret)
modelLookup("C5.0")
#   model  parameter                 label forReg forClass probModel
# 1  C5.0    trials # Boosting Iterations  FALSE     TRUE      TRUE
# 2  C5.0     model            Model Type  FALSE     TRUE      TRUE
# 3  C5.0    winnow                Winnow  FALSE     TRUE      TRUE

modelLookup("knn")
#   model  parameter      label forReg forClass probModel
# 1   knn         k #Neighbors   TRUE     TRUE      TRUE

# train() => 자동으로 최고의 모델을 식별하고, 튜닝 파라미터(아래는 C5.0)를 사용해서 전체 입력 데이터셋에 대해 모델을 구축.
set.seed(1021)
m = train(default ~ ., data = credit, method = "C5.0")
str(m)
m
# C5.0 
# 
# 1000 samples
# 16 predictor
# 2 classes: 'no', 'yes' 
# 
# No pre-processing
# Resampling: Bootstrapped (25 reps) 
# Summary of sample sizes: 1000, 1000, 1000, 1000, 1000, 1000, ... 
# Resampling results across tuning parameters:

# model  winnow  trials  Accuracy   Kappa    
# rules  FALSE    1      0.6829141  0.2508423
# rules  FALSE   10      0.7158501  0.3266497
# rules  FALSE   20      0.7304502  0.3533030
# rules   TRUE    1      0.6863801  0.2601408
# rules   TRUE   10      0.7104499  0.3146436
# rules   TRUE   20      0.7216992  0.3304315
# tree   FALSE    1      0.6816089  0.2330451
# tree   FALSE   10      0.7215476  0.2930498
# tree   FALSE   20      0.7308596  0.3163173
# tree    TRUE    1      0.6853617  0.2465922
# tree    TRUE   10      0.7205940  0.2932229
# tree    TRUE   20      0.7289123  0.3117728
# ~~~> 12개의 모델이 C5.0 튜닝 파라미터 model, trials, winnow의 조합을 토대로 테스트 됨. 
#      각 후보 모델의 정확도와 카파 통계의 평균, 표준편차도 나옴.

# Accuracy was used to select the optimal model using the largest value.
# The final values used for the model were trials = 20, model = tree and winnow = FALSE.
# ~~~> 가장 큰 정확도를 갖는 모델이 선택됨. 이 모델은 20회 시행과 winnow = FALSE 설정을 갖는  의사 결정 트리를 사용.

# 만들어진 모델 예측
m_predict = predict(m, credit)
table(m_predict, credit$default)
# m_predict  no  yes
#        no  700   2
#       yes   0  298 ~~~> 예측 값과 실제 값을 비교한 혼동 행렬.

# 예측 클래스
head(predict(m, credit))
# [1] no  yes no  no  yes no 
# Levels: no yes

# 각 쿨래스의 추정 확률 
head(predict(m, credit, type = "prob"))
#          no        yes
# 1 0.9606970 0.03930299
# 2 0.1388444 0.86115561
# 3 1.0000000 0.00000000
# 4 0.7720279 0.22797208
# 5 0.2948062 0.70519385
# 6 0.8583715 0.14162851

# 튜닝 절차 자동화 
# => trainControl(method = "리샘플링할 방법", number = 추가 옵션 및 디폴트 값, selectionFunction = "다양한 후보 중, 최적의 모델 선택 함수")
ctrl = trainControl(method = "cv", number = 10, selectionFunction = "oneSE") # 10 폴드 교차검증(cv)
ctrl # caret::train 함수의 제어조건 생성

# 제공된 값의 모든 조합으로 데이터 프레임을 만듦 => expand.grid()
grid = expand.grid(model = "tree",
                   trials = c(1, 5, 10, 15, 20, 25, 30, 35),
                   winnow = F)
grid # 1x8 데이터 프레임 생성

grid2 = expand.grid(model = c("tree", "rules"),
                    trials = c(1, 5, 10, 15, 20, 25),
                    winnow = F)
grid2

set.seed(1021)
m = train(default ~ ., data = credit, method = "C5.0",
          metric = "Kappa", # 모델 평가 함수(oneSE)가 Kappa 통계량을 사용한다.
          trControl = ctrl, 
          tuneGrid = grid)
m
# C5.0 
# 
# 1000 samples
# 16 predictor
# 2 classes: 'no', 'yes' 
# 
# No pre-processing
# Resampling: Cross-Validated (10 fold) 
# Summary of sample sizes: 900, 900, 900, 900, 900, 900, ... ~~~> 900개 샘플 사이즈(10 폴드 교차 검증 사용했기 때문)
# Resampling results across tuning parameters:
#   
# trials  Accuracy  Kappa    
# 1       0.718     0.2764791
# 5       0.724     0.3034678
# 10      0.734     0.3142227
# 15      0.723     0.2866231
# 20      0.731     0.3186682
# 25      0.726     0.3035680
# 30      0.731     0.3127099
# 35      0.734     0.3191232 ~~~> 8개 후보 모델(grid 8개 설정했기 때문)
# 
# Tuning parameter 'model' was held constant at a value of tree
# Tuning parameter 'winnow' was held constant at a value of FALSE ~~~> model & winnow는 상수로 고정되었음
# Kappa was used to select the optimal model using  the one SE rule.
# The final values used for the model were trials = 5, model = tree and winnow = FALSE. ~~~> 성능이 비슷하다면 trials 수가 더 적은것이 성능이 좋다.