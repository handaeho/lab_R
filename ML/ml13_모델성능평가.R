#  모델 성능 평가

# --------------------------------------------------------------------------------------------------------------------

# ● 분류 성능 측정
#   ○ 혼동 행렬
#   ○ 성능 척도
#     ■ 카파 통계량
#     ■ 민감도 / 특이도
#     ■ 정밀도 / 재현율
#     ■ F-척도
#   ○ 성능 트레이드오프 시각화
#     ■ ROC 곡선
# ● 미래 성능 예측
#   ○ 홀드 아웃 방법
#     ■ 교차 검증
#     ■ 부트스트랩 샘플링

# --------------------------------------------------------------------------------------------------------------------

# 1] 분류 성능 측정

# ● 분류기 정확도(classifier accuracy) ===> (정확도) = (정확한 예측 갯수) / (전체 예측 갯수)
# ● 위의 방법이 가장 좋은 측정 방법일까? 단순히 정확도만 높다고 좋은 모델일까?
# ● 분류기 성능 측정은 분류기가 의도된 목적에 맞게 성공했는 지를 반영하는 것이 좋은 측정 방법이다.
# 예를 들어, '결함 없음'을 '결함 있음'으로 분류한 것은 그나마 괜찮지만, '결함 있음'을 '결함 없음'으로 분류하는 것은 문제이다.

# --------------------------------------------------------------------------------------------------------------------

# 2] 혼동 행렬을 사용한 성능 측정

# ● TP(True Positive, 참 긍정) : 관심 클래스로 정확하게 분류
# ● TN(True Negative, 참 부정) : 관심 클래스가 아닌 클래스로 정확하게 분류
# ● FP(False Positive, 거짓 긍정) : 관심 클래스로 부정확하게 분류
# ● FN(False Negative, 거짓 부정) :관심 클래스가 아닌 클래스로 부정확하게 분류

# 정확도(Accuracy) = TP + TN / TP + TN + FP + FN
# 오류율(Error Rate) = FP + FN / TP + TN + FP + FN = 1 - Accuracy

# 카파 통계량(kappa statistic) => 우연히 정확한 예측을 할 가능성을 설명해 정확도를 조정
# Cohen’s kappa coefficient k = Pr(a) - Pr(e) / 1 - Pr(e) 
# [Pr(a): actual agreement(실제 일치) 비율 , Pr(e): expected agreement(예상 일치) 비율]
# 카파 값(k)은 0 ~ 1 범위. 1에 가까울수록 완벽 일치, 0에 가까울수록 우연히 맞춘 것.

# 민감도(sensitivity) = TP / TP + FN  : 정확히 분류된 참 긍정 예시의 비율(참 긍정 수/ 전체 긍정 수)
# 특이도(specificity) = TN / TN + FP : 정확히 분류딘 부정 예시의 비율(참 부정 수 / 전체 부정 수)

# 정밀도(precision) = TP / TP + FP : 진짜 긍정인 긍정 예시의 비율(참 긍정 수 / 참 긍정 수 + 거짓 긍정 수)
# 재현율(recall) = TP / TP + FN : 결과가 얼마나 완벽한가?(참 긍정 수 / 참긍정 + 거짓 부정)

# F-척도(F-measure) = 2 * precision * recall / recall + precision = 2 * TP / 2 * TP + FP + FN
# F-척도는 '조화 평균'을 이용해서 '정밀도'와 '재현도'를 하나의 값으로 조합한다.
# 조화 평균 : 변화율에 사용되는 평균. 비율로 해석되는 0 ~ 1 사이의 부분으로 표현되어 일반적인 산술 평균 대신에 사용됨.

# --------------------------------------------------------------------------------------------------------------------

# 3] 성능 트레이드오프 시각화

# ● ROC 곡선(Receiver Operating Characteristic curve)
# ● AUC(Area under the ROC curve)
#   ○ ROC 곡선 아래 영역의 넓이
#   ○ 1에 가까울 수록 긍정 값을 더욱 잘 식별

# 성능 트레이드오프 시각화를 위한 필요 패키지 설치 & 로드 ---> pROC::roc()
install.packages("pROC")
library(pROC)

# pROC로 시각화를 위해서는 실제 클래스 값 포함 벡터 & 긍정 클래스 추정 확률 포함 벡터가 필요.

# sms - 나이브 베이즈 알고리즘 성능 트레이드 오프 시각화
sms_roc = roc(response = sms_results$actual_type,
              predictor = sms_results$prob_spam)
plot(sms_roc, col = "blue", lwd = 3)

# sms - knn 알고리즘 성능 트레이드오프 시각화
sms_knn = read.csv("data/sms_results_knn.csv")
head(sms_knn)

sms_knn_roc = roc(response = sms_results$actual_type,
                  predictor = sms_knn$p_spam)
plot(sms_knn_roc, col = "blue", lwd = 3)

# 두개 ROC 곡선 같이 그리기(1번 plot 먼저 실행 후, add 파라미터 = TRUE)
plot(sms_knn_roc, col = "red", lwd = 3, add = T)

# --------------------------------------------------------------------------------------------------------------------

# 4] 미래 성능 예측

# ● Holdout Method
#   - 훈련 데이터 셋 ~~~> 모델 생성
#   - 테스트 데이터 셋 ~~~> 모델 평가를 위한 예측
# 홀드아웃 방법이 미래 성능에 대한 실제 정확한 추정치를 얻으려면, 테스트 데이터 셋에 대한 성능이 모델에 영향을 미치면 안됨.
# 따라서 '검증 데이터 세트'를 사용 할 수 있게 원래 데이터를 나누는 것이 좋음.

# ● k-fold CV(Cross Validation, 교차 검증)
# 데이터를 무작위로 k로 나누어 '폴드'라고 불리는 랜덤 파티션으로 완전히 분리한다.(k의 default = 10)
# 10 폴드 구성시, 데이터는 90 : 10으로 나뉘어 모델은 90%에 대해 구축되고, 10%는 모델 평가에 사용된다.
# 모델을 훈련하고 평가하는 절차가 10개의 다른 훈련/테스트 조합으로 10회 발생하면, 전체 폴드의 평균 성능이 보고됨.
# caret 패키지의 createFolds() 함수 이용

# ● Bootstrap Sampling(부트스트랩 샘플링)
# k-폴드 교차 검증의 대안.
# 아주 큰 집합의 속성을 추정하기 위해, 데이터의 랜덤 샘플을 사용하는 통계적 방법.
# 여러개의 무작위로 선택된 훈련 데이터 셋과 테스트 데이터 셋을 생성하고, 성능 통계를 추정하기 위해 사용.
#  k-폴드 교차검증과의 차이점?
# => 교차 검증 : 데이터를 여러 파티션으로 나눌때, 각 예시가 파티션에 단 한 번만 나타남.
#    부트스트랩 : '복원 샘플링' 과정을 거쳐 예시가 여러번 선택 될 수 있음.
# 부트스트랩은 n개의 예시로 구성된 원래 데이터 셋으로부터 한 개 이상의 새로운 데이터 셋을 생성하며, 
# 생성된 훈련 데이터 셋 또한 n개의 예시를 포함하고, 일부는 반복된다. 
# 그런 다음 대응되는 테스트 데이터 셋은 훈련 데이터 셋에 선택되지 않은 예시에서 구성된다.

# --------------------------------------------------------------------------------------------------------------------

# 모델 성능 평가

# model = naiveBayes(훈련 데이터, ...)
# predicted = predict(model, 테스트 데이터, type ="...")

sms_results = read.csv("data/sms_results.csv")
head(sms_results)

library(dplyr)

sms_results %>% 
  filter(prob_spam > 0.4 & prob_spam < 0.6) %>% 
  head(10)

# 스팸 분류에서 예측 확률이 50% 근처라면(예측하기 애매한 경우) 모델이 잘못 예측할 가능성이 높다.

# 실제 값과 예측 값이 다른 경우 
# 모델은 99%라고 예측 했으나, 틀리는 경우도 존재한다.
sms_results %>% 
  filter(actual_type != predict_type) %>% 
  head(10)

# 혼동 행렬(Confusion Matrix)을 이용한 성능 평가
table(sms_results$actual_type, sms_results$predict_type)
#       ham spam
# ham  1203    4
# spam   31  152

# 이원교차표
library(gmodels)
CrossTable(sms_results$actual_type, sms_results$predict_type)

# kappa 통계량 계산
# Pr(a): 실제 일치(actual agreement) 비율
# TN + TP
pr_a <- 0.865 + 0.109
pr_a
# Pr(e): 예상 일치(expected agreement) 비율
# 독립 사건이라는 가정 아래에서
# P(실제 스팸) x P(예측 스팸) + P(실제 햄) x P(예측 햄)
pr_e <- (0.022 + 0.109)*(0.003 + 0.109) + (0.865 + 0.003)*(0.865 + 0.022)
kappa <- (pr_a - pr_e) / (1 - pr_e)

# caret 패키지 : Classification And REgression Training(분류 & 회귀 트레이닝)
install.packages("caret")
library(caret)

# confusionMatrix(data = 예측 값, reference = 실제 값, positive = 값)
confusionMatrix(data = sms_results$predict_type, 
                reference = sms_results$actual_type,
                positive = "spam") 
# data = 예측 결과, reference = 실제 결과
# Positive Predictive Value -> 정밀도(Precision)

# 민감도
sensitivity(data = sms_results$predict_type,
            reference = sms_results$actual_type,
            positive = "spam") # 0.8306011

# 특이도
specificity(data = sms_results$predict_type,
            reference = sms_results$actual_type,
            negative = "ham") # 0.996686

# 정밀도
precision(data = sms_results$predict_type,
          reference = sms_results$actual_type,
          relevant = "spam") # 0.974359

# F-척도 = 2 * precision * recall / recall + precision
F_meas(data = sms_results$predict_type,
       reference = sms_results$actual_type,
       relevant = "spam") # 0.8967552
f = (2 * 0.974359 * 0.8306011) / (0.974359 + 0.8306011) # F-척도 구하는 공식
f # 0.8967552

