# 블랙박스 방법 : 신경망과 서포트 벡터 머신

# 1) 신경망(Neural Network)

# ANN(Artificial Neural Network) : 입력 신호와 출력 신호 사이의 관계를 모델링

# ● 활성 함수 => 뉴런의 결합된 Input을 하나의 Output으로 변환.
# ● 네트워크 토폴로지(Network Topology) => 모델의 계층 수와 뉴런 수, 연결 방식을 설명.
# ---> 단층 네트워크 ~> 1개 layer의 입력 노드 / 출력 노드 가짐
#      다층 네트워크 ~> 1개 layer의 입력 노드, 출력 노드에 은닉 노드 layer를 가짐.
#      DNN(Deep Neural Network, 깊은 신경망) ~> 다중 은닉 layer를 갖는 신경망
#      Deep Learning(심층 학습) ~> DNN을 훈련
#      순환망(Recurrent Network), 피드백 네트워크(Feedback Network) ~> 루프를 이용해, 양 방향으로 신호 이동
# ● 훈련 알고리즘 => Input에 비례해서 뉴런을 억제하거나 흥분시키기 위한 연결 가중치 설정 명시.

# 신경망 훈련 알고리즘 - 오차역전파(backpropagation)
# ● 순방향 단계(forward phase): 입력 계층부터 출력 계층까지 뉴런이 순차적으로 활성화되면서 
# 도중에 뉴런의 가중치와 활성함수가 적용됨. 마지막 계층에 도달하면 출력 신호가 생성됨.
# ● 역방향 단계(backward phase): 순방향 단계에서 만들어진 네트워크 출력 신호를 
# 훈련 데이터의 실제 목표 값과 비교. 네트워크 출력 신호와 실제 값의 차로 오차가 만들어지면 
# 네트워크에서 역방향으로 전파돼 뉴런 사이에 연결 가중치를 수정하고 미래의 오차를 줄임.
# ● 위의 두 순환 주기(epoch)를 여러 번 반복함.
# ● 경사 하강법(gradient descent): 알고리즘이 가중치를 수정하는 방법

# ----------------------------------------------------------------------------------------------------------

# 예제 : ANN으로 콘크리트 강도 모델링

# Cf) 함수 그리기----------------------------------------
# curve(expr = 식, from = 범위 시작 값, to = 범위 끝 값)

# f(x) = 2x + 1(단, -5 <= x <= 5)] 
curve(expr = 2 * x + 1, from = -5, to = 5)
# Sigmoid 함수 f(x) = 1 / (1 + exp(-x))
curve(expr = 1 / (1 + exp(-x)), from = -10, to = 10) 
# Hyperboloc Tangent f(x) = tanh(x)
curve(expr = tanh(x), from = -5, to = 5)

# --------------------------------------------------------

# 데이터 준비 & 확인
concreate = read.csv("data/concrete.csv")
str(concreate)
summary(concreate)
summary(concreate$strength) 
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 2.33   23.71   34.45   35.82   46.13   82.60 

# 정규화 : 실제값 -> 0 ~ 1 사이의 값
# 표준화 : z-score 표준화(평균, 표준편차)

# 신경망은 입력 데이터가 0 주변의 범위에서 best. 따라서 입력 데이터를 0 ~ 1 범위로 정규화 해야한다.
# 데이터 정규화 함수 구현
normalize = function(x){
  return((x - min(x)) / (max(x) - min(x)))
}

# concreate 데이터 프레임 정규화
concreate_normal = as.data.frame(lapply(concreate, normalize))
summary(concreate_normal)
summary(concreate_normal$strength)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.0000  0.2664  0.4001  0.4172  0.5457  1.0000 

# 학습 데이터 세트(75%) / 테스트 데이터 세트(25%)
# 이미 무작위 순서로 데이터가 존재함. 만약 순서대로 정렬 되어있다면 랜덤 샘플링 필요.
concreate_train = concreate_normal[1:773, ]
concreate_test = concreate_normal[774:1030, ]

# 다층 순방향 신경망을 이용한 데이터 모델링

# 패키지 설치 & 로드
install.packages("neuralnet")
library(neuralnet)

# 모델 트레이닝
# m = neuralnet(formula = 모델링될 데이터프레임 변수 ~ 모델에서 사용할 특징, data = 데이터프레임, hidden = 히든 layer 수)
concreate_neuralnet = neuralnet(formula = strength ~ ., 
                                data = concreate_normal,
                                hidden = 1)
plot(concreate_neuralnet)
# 특징별로 Input이 있고, 각 연결에 가중치, '1'로 레이블 된 바이어스 항, 1개의 Output을 가짐.
# 바이어스 항 = 숫자 상수. 해당 노드의 값이 위, 아래쪽으로 평행 이동함. (like 절편)
# 오차 제곱 합(SSE, Sum of Squared Errors) : sum(예측 값 - 실제 값)^2 ~> SSE는 낮을수록 예측 성능이 좋다.
# 현재 ERROR : 6.9911298, STEPS : 2382

# 모델 성능 평가 ---> compute() 함수
# compute() => $neurons : 계층별로 뉴런 저장 / $net.result : 예측 값 저장
model_result = compute(concreate_neuralnet, concreate_test[1:8])
head(model_result)
summary(model_result)
predicted_strength = model_result$net.result

# 예측 결과와 실제 값의 상관 계수(두 수치 벡터간의 상관 관계 파악)
cor(predicted_strength, concreate_test$strength) # 0.80825

# 모델 성능 개선
# hidden 파라미터를 증가시켜, hidden layer 추가
concreate_neuralnet_upgrade = neuralnet(formula = strength ~ ., 
                                data = concreate_normal,
                                hidden = 5)
plot(concreate_neuralnet_upgrade)
# 현재 ERROR : 2.318101, STEPS : 24112

# 개선된 모델 성능 평가
upgrade_model_result = compute(concreate_neuralnet_upgrade, concreate_test[1:8])
upgrade_predicted_strength = upgrade_model_result$net.result

# 개선된 모델의 예측 결과와 실제 값의 상관 계수(두 수치 벡터간의 상관 관계 파악)
cor(upgrade_predicted_strength, concreate_test$strength) # 0.9409482

# hidden layer 1개 = ERROR : 6.9911298, STEPS : 2382 / cor : 0.80
# hidden layer 5개 = ERROR : 2.318101, STEPS : 24112 / cor : 0.94
# hidden layer를 추가함으로서, 성능 개선 확인 가능.

# 평균 절대 오차(MAE) 계산 함수를 구현하고, 예측 값과 실제 값 비교
# 예측 값 = predict_strength, upgrade_predict_strength / 실제 값 = concreate_test$strength

# MAE 계산 함수 
error_func = function(actual, predicted){
  return(mean(abs(actual - predicted)))
}

# 개선 전, MAE(hidden layer = 1)
error_strength = error_func(concreate_test$strength, predicted_strength)
error_strength # 0.09275353

# 개선 후, MAE(hidden layer = 5)
upgrade_error_strength = error_func(concreate_test$strength, upgrade_predicted_strength)
upgrade_error_strength # 0.05195321

# 역 정규화를 해서, 실제 데이터 프레임(concreate)과 비교

# 역 정규화 함수 구현
reverse_normalize = function(x){
  max_str = max(concreate$strength)
  min_str = min(concreate$strength)
  return(x * (max_str - min_str) + min_str)
}

# 역 정규화
concreate_reverse_normal = reverse_normalize(predicted_strength)
summary(concreate_reverse_normal)

concreate_reverse_normal_5 = reverse_normalize(upgrade_predicted_strength)
summary(concreate_reverse_normal_5)

# 역 정규화 데이터 프레임
# data.frame(컬럼이름1 = 실제 값, 컬럼이름2 = hidden layer 1개 예측 값, 컬럼이름3 = hidden layer 5개 예측 값)
# as.data.frame(데이터프레임으로 변환 & 생성이 가능한 값값)
actual_predict_df = data.frame(actual = concreate[774:1030, 9],
                               predict1 = concreate_reverse_normal,
                               predict2 = concreate_reverse_normal_5)
head(actual_predict_df, 10)

# 역 정규화 데이터 상관 계수
cor(actual_predict_df$actual, actual_predict_df$predict1) 
# 실제 값과 hidden layer 1개 예측 값의 상관 계수 = 0.80
cor(actual_predict_df$actual, actual_predict_df$predict2) 
# 실제 값과 hidden layer 1개 예측 값의 상관 계수 = 0.94
# 정규화 된 데이터의 cor()과 역 정규화 데이터의 cor()은 같아야 한다.

set.seed(12345)

# softsum : log 계산
softsum = function(x){
  log(1 + exp(x))
} 

# softsum 그리기
curve(expr = softsum, from = -5, to = 5)

# act.fct ---> 활성 함수 변경 가능
concreate_neuralnet_softsum = neuralnet(formula = strength ~ ., 
                                        data = concreate_train,
                                        hidden = c(5, 3), # step 1 node 수, step 2 node 수
                                        act.fct = softsum,
                                        stepmax = 1000000000)
plot(concreate_neuralnet_softsum)

concreate_neuralnet_logistic = neuralnet(formula = strength ~ ., 
                                         data = concreate_train,
                                         hidden = c(5, 3), # step 1 node 수, step 2 node 수
                                         act.fct = "logistic")
plot(concreate_neuralnet_logistic)

concreate_neuralnet_tanh = neuralnet(formula = strength ~ ., 
                                     data = concreate_normal,
                                     hidden = 5,
                                     act.fct = "tanh")
plot(concreate_neuralnet_tanh)
