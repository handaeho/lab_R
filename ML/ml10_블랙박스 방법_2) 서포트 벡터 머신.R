# 블랙박스 방법 : 신경망과 서포트 벡터 머신

# 2) 서포트 벡터 머신(SVM: support vector machine)

# SVM의 목표
# ○ 공간을 나눠서 양쪽에 매유 균질적인 분할을 생성하는 '초평면(hyperplane)'이라고 하는 경계를 생성하는 것
# ○ 인스턴스 기반 k-NN + 선형 회귀 모델링

# SVM의 이해
# ● MMH(Maximum Margin Hyperplane, 최대 마진 초평면)
# ○ 공간 상의 두 클래스를 가장 멀리 분리하는 초평면
# ○ SVM의 목표는 MMH를 찾는 것
# 
# ● Support Vector
# ○ 각 클래스에서 MMH에 가장 가까운 점들
# ○ 서포트 벡터를 찾으면 MMH를 정의할 수 있다.

# 비 선형 커널을 사용한 SVM
# ● 비 선형 커널
# ○ 데이터에 새로운 차원을 추가해 데이터를 분리하는 방법
# ○ 커널 트릭을 사용하면 비 선형 관계가 선형적인 관계로 나타날 수 있다.

#-----------------------------------------------------------------------------------------------------------

# letterdata 데이터로 SVM 학습

# 데이터 준비 & 확인
letters = read.csv("data/letterdata.csv")
str(letters) # 20,000개 데이터(예시), factor를 제외한 16개 특징(int 형) 존재
table(letters$letter)
head(letters)
# 특징은 가로 / 세로 차원, 흰색 대비 검정 픽셀 비율, 검정 픽셀의 평균 가로 / 세로 위치 등이 있다.
# 박스의 다양한 영역 내의 농도차는 알파벳 26개 문자를 구별하는 특징이 될 것.

# 학습 데이터 세트(80%) / 테스트 데이터 세트(20%)
letters_train = letters[1:16000, ]
letters_test = letters[16001:20000, ]
# Cf) SVM trainer는 '모든 특징이 숫자' & '특징이 아주 작은 구간'이어야 한다.

# 서포트 벡터 머신(SVM) 모델링을 위한 패키지(kernlab) 설치 & 로드
install.packages("kernlab")
library(kernlab)
search()

# SVM 모델 구현(문자 분류기 구축)
letters_classifier = ksvm(letter ~ ., 
                          data = letters_train,
                          kernel = "vanilladot",
                          C = 1)
# dot(dot product) : 벡터 내적
# vanilladot : 선형 커널 / rbfdot : 방사형 기저 / polydot : 다항 / tanhdot : 하이퍼볼릭 탄젠트 시그모이드
# C(결정 경계) : 제약 위반 비용. 즉, '소프트 마진'에 대한 페널티.  값이 커질수록 여백 좁아짐.
letters_classifier

# SVM 모델 성능 평가
letters_predict = predict(letters_classifier, letters_test, type = "response")
# type = response(예측 클래스), probabilities(예측 확률. 클래스 레벨 별로 하나의 열)
# type 파라미터의 값에 따라 예측 클래스(or 확률)의 벡터(or 행렬)를 반환함.
head(letters_predict)
table(letters_predict, letters_test$letter)
# 대각선 값은 예측된 문자가 실제 값과 일치한다고 판단한 레코드의 수를 의미. 실수한 개수도 나열됨.

# 그렇다면 모델에서 예측한 문자가 실제 문자와 얼마나 일치 하는가?
# 예측 값과 실제값이 같다면 TRUE, 다르다면 FALSE를 반환.
agreement = letters_predict == letters_test$letter
table(agreement) # FALSE 643 / TRUE 3357 
prop.table(table(agreement)) # FALSE 0.16075 / TRUE 0.83925 ~~~> 약 84% 정확도

# SVM 모델 성능 향상
# SVM 모델의 커널을 변경시켜 보자.

# rbfdot : 방사형 기저
letters_classifier_rbf = ksvm(letter ~ ., 
                          data = letters_train,
                          kernel = "rbfdot",
                          C = 1)

letters_predict_rbf = predict(letters_classifier_rbf, letters_test, type = "response")

agreement_rbf = letters_predict_rbf == letters_test$letter

prop.table(table(agreement_rbf)) # FALSE 0.0695 / TRUE 0.9305 ~~~> 약 93% 정확도 ===> 정확도 향상 성공.

# ploydot : 다항
letters_classifier_poly = ksvm(letter ~ ., 
                              data = letters_train,
                              kernel = "polydot",
                              C = 1)

letters_predict_poly = predict(letters_classifier_poly, letters_test, type = "response")

agreement_poly = letters_predict_poly == letters_test$letter

prop.table(table(agreement_poly)) # FALSE 0.16075 / TRUE 0.83925 ~~~> 약 83% 정확도

# tanhdot : 하이퍼볼릭 탄젠트 시그모이드
letters_classifier_tanh = ksvm(letter ~ ., 
                               data = letters_train,
                               kernel = "tanhdot",
                               C = 1)

letters_predict_tanh = predict(letters_classifier_tanh, letters_test, type = "response")

agreement_tanh = letters_predict_tanh == letters_test$letter

prop.table(table(agreement_tanh)) # FALSE 0.9155 / TRUE 0.0845 ~~~> 약 8% 정확도(???)

# C(결정 경계)의 변화에 따른 정확도 차이 파악
letters_classifier_rbf_c5 = ksvm(letter ~ ., 
                              data = letters_train,
                              kernel = "rbfdot",
                              C = 5)
letters_predict_rbf_c5 = predict(letters_classifier_rbf_c5, letters_test, type = "response")

agreement_rbf_c5 = letters_predict_rbf_c5 == letters_test$letter

prop.table(table(agreement_rbf_c5)) # FALSE 0.03725 / TRUE 0.96275 ~~~> 약 96% 정확도(93%에 비해 소폭 상승)

letters_classifier_rbf_c1000 = ksvm(letter ~ ., 
                                 data = letters_train,
                                 kernel = "rbfdot",
                                 C = 1000)
letters_predict_rbf_c1000 = predict(letters_classifier_rbf_c1000, letters_test, type = "response")

agreement_rbf_c1000 = letters_predict_rbf_c1000 == letters_test$letter

prop.table(table(agreement_rbf_c1000)) # FALSE 0.02875 / TRUE 0.97125 ~~~> 약 97% 정확도
