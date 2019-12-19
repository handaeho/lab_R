# k - NN(k-Nearest Neighbor) 알고리즘

# 위스콘신 유방암 데이터 준비
wbcd = read.csv("C:/dev/lab-R/data/wisc_bc_data.csv", stringsAsFactors = F)

# 데이터구조 확인
str(wbcd)
head(wbcd)

# 암인지 아닌지 구별할 때 필요하지 않은 환자 id는 데이터프레임에서 제외 해, 거리계산 사용 X.
wbcd = wbcd[-1] # 데이터프레임의 첫 번째 컬럼을 제외한 모든 컬럼 선택.
str(wbcd)

# 진단 결과(diagnosis) 컬럼을 범주(factor)로 만듦.
wbcd$diagnosis = factor(wbcd$diagnosis, 
                        levels = c("B", "M"),
                        labels = c("양성", "악성"))

str(wbcd$diagnosis)

# 양성 종양과 악성 종양의 개수 / 비율
table(wbcd$diagnosis) # 각각의 개수
prop.table(table(wbcd$diagnosis)) # 비율

# 각 변수들의 요약 정보(기술통계량) 확인
str(wbcd)
summary(wbcd[c("radius_mean", "area_mean", "smoothness_mean")]) # 특정 변수의 summary만 확인
# 각 변수들의 단위가 달라, 거리 계산 시 차지하는 비율이 서로 다르다.
# 각 특징이 거리 공식에 상대적으로 동일하게 기여할 수 있도록 범위를 줄이거나 늘려줘야 할 필요가 있음.

# 정규화(Normalization) & 표준화(Standardization)  

# 정규화(Normalization)

# 최소 - 최대 정규화 함수 정의
# 함수이름 = function(파라미터이름) {함수가 수행할 코드}
normalize = function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# 정규화 함수 테스트
v1 = c(1, 2, 3, 4, 5)
normalize(v1)
v2 = c(10, 20, 30, 40, 50)
normalize(v2)
v3 = c(0.1, 0.5, 0.9, 0.6, 0.01)
normalize(v3)
# 모든 데이터가 0 ~ 1 사이의 값으로 정규화 된다.

# 모든 변수들이 정규화 된 데이터 프레임으로 변환
# 현재 wbcd의 첫 번쨰 컬럼은 '진단 결과' 이므로 정규화에서는 제외
str(wbcd)
wbcd_n = as.data.frame(lapply(wbcd[2:31], normalize))
# lapply(데이터프레임이름, 함수이름) ---> 데이터프레임의 각 컬럼들을 차례로 함수의 매개 변수로 전달.

# 결과 확인
summary(wbcd_n[c("radius_mean", "area_mean", "smoothness_mean")])

# 정규화된 데이터 프레임에을 '학습 데이터 세트(469개 관찰 값)'와 
# '테스트 데이터 세트(100개 관찰 값)'로 나눔.
head(wbcd$diagnosis, n = 10)
tail(wbcd$diagnosis, n = 10)

wbcd_train = wbcd_n[1:469, ] # '학습(훈련) 데이터 세트(469개 관찰 값)'
head(wbcd_train)

wbcd_test = wbcd_n[470:569, ] # '테스트 데이터 세트(100개 관찰 값)'
head(wbcd_test)
# k - NN 알고리즘이 얼만큼의 정확도를 갖는지 테스트 하기 위한 데이터

# 학습 데이터 / 테스트 데이터의 진단 정보를 가지고 있는 vector 생성.(정답을 만드는 것)
wbcd_train_label = wbcd[1:469, 1] # 학습 데이터 정답지
table(wbcd_train_label)
prop.table(table(wbcd_train_label))

wbcd_test_label = wbcd[470:569, 1] # 테스트 데이터 정답지
table(wbcd_test_label)
prop.table(table(wbcd_test_label))

# k-NN 알고리즘을 구현한 패키지 설치
install.packages("class")

# 패키지를 메모리에 로드
library(class)

# class::knn(학습데이터, 테스트데이터, 학습데이터의정답, k값)
# k 값은 학습 데이터 개수의 제곱근 
sqrt(469)

predict = knn(train = wbcd_train, 
              test = wbcd_test,
              cl = wbcd_train_label,
              k = 21)
str(predict)
table(predict)
# wbcd_train 데이터의 답을 wbcd_train_lable에서 받아와, 
# 이를 이용해 거리 계산을 한 후, wbcd_test의 답을 예측한다.
table(wbcd_test_label)

# 실제 진단 결과와 예측 결과의 차이를 분석하기 위해, '교차이원표' 생성.
install.packages("gmodels")
library(gmodels)

# gmodels::CrossTable(행에 사용할 벡터, 열에 사용할 벡터)
CrossTable(wbcd_test_label, predict, prop.chisq = F)

# k 값의 변화에 따른 k - NN 알고리즘 결과 비교
predict = knn(train = wbcd_train,
              test = wbcd_test,
              cl = wbcd_train_label, 
              k = 1)
CrossTable(wbcd_test_label, predict, prop.chisq = F)

predict = knn(train = wbcd_train,
              test = wbcd_test,
              cl = wbcd_train_label, 
              k = 3)
CrossTable(wbcd_test_label, predict, prop.chisq = F)

predict = knn(train = wbcd_train,
              test = wbcd_test,
              cl = wbcd_train_label, 
              k = 5)
CrossTable(wbcd_test_label, predict, prop.chisq = F)

# 표준화(Standardization)  

# 변수들을 정규화 하는 대신에 표준화를 하면 예측 정확도는?
wbcd_z = as.data.frame(scale(wbcd[-1])) # --- scale(데이터프레임) : 표준화
str(wbcd_z)
summary(wbcd_z[c("radius_mean", "area_mean", "smoothness_mean")])

# z - score 표준화가 된 데이터 프레임을 '학습 데이터 세트' / '테스트 데이터 세트'로 나눔
train_data = wbcd_z[1:469, ] # 학습 데이터 세트
test_data = wbcd_z[470:569, ] # 테스트 데이터 세트

# 학습 데이터 세트와 테스트 데이터 세트의 정답(암 진단 정보) --- class
train_label <- wbcd[1:469, 1]
test_label <- wbcd[470:569, 1]

predict <- knn(train = train_data,
               test = test_data,
               cl = train_label,
               k = 21)
CrossTable(x = test_label,
           y = predict,
           prop.chisq = F)

# k 값 변화에 따른 결과 비교
predict <- knn(train = train_data,
               test = test_data,
               cl = train_label,
               k = 11)
CrossTable(x = test_label,
           y = predict,
           prop.chisq = F)

predict <- knn(train = train_data,
               test = test_data,
               cl = train_label,
               k = 7)
CrossTable(x = test_label,
           y = predict,
           prop.chisq = F)

# 실습) iris 종 판별하기 ===================================================================================

# cvs 파일 로드
iris = read.csv("data/Iris.csv", stringsAsFactors = F)
str(iris)

# 첫 번쨰 컬럼인 id 삭제
iris = iris[-1]
str(iris)

# 각 species 수 & 비율 확인
table(iris$Species)
prop.table(table(iris$Species)) 

# species 컬럼을 factor로 만듦
iris$Species = factor(iris$Species,
                      levels = c("Iris-setosa", "Iris-versicolor", "Iris-virginica"),
                      labels = c("setosa", "versicolor", "verginica"))

str(iris$Species)
table(iris$Species)

# 정규화 식 구현
normalize = function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# 마지막 5번째 컬럼은 '종'이므로 제외하고 정규화.
iris_n = as.data.frame(lapply(iris[1:4], normalize))

#결과 확인
summary(iris_n)
iris_n

# 현재 데이터프레임에는 종의 순서대로 들어가 있기 때문에 랜덤하게 뽑아야 한다.

# 랜덤 위한 시드값 생성
set.seed(2345)

# 75 : 25의 비율로 데이터 나눔
random_sample = sample(2, nrow(iris_n), replace = TRUE, prob = c(0.75, 0.25)) 
random_sample

# 학습(훈련) 데이터 세트
iris_train = iris[random_sample == 1, 1:4] 
iris_train

# 트레이닝 라벨
iris_train_label = iris[random_sample == 1, 5]
iris_train_label

# 테스트 데이터 세트
iris_test = iris[random_sample == 2, 1:4] 
iris_test

# 테스팅 라벨
iris_test_label = iris[random_sample == 2, 5]
iris_test_label

# k-nn 알고리즘 라이브러리 세팅
library(class)

# k-nn 알고리즘 실행
predict = knn(train = iris_train,
              test = iris_test,
              cl = iris_train_label, 
              k = 5)
CrossTable(iris_test_label, predict, prop.chisq = F)

# ==============================================================================================================

rm(list=ls())

# 다른 방법 ===================================================================================================

# cvs 파일 로드
iris = read.csv("data/Iris.csv", stringsAsFactors = F)
str(iris)

# 첫 번쨰 컬럼인 id 삭제
iris = iris[-1]
str(iris)

# 각 species 수 & 비율 확인
table(iris$Species)
prop.table(table(iris$Species)) 

# species 컬럼을 factor로 만듦
iris$Species = factor(iris$Species,
                      levels = c("Iris-setosa", "Iris-versicolor", "Iris-virginica"),
                      labels = c("setosa", "versicolor", "verginica"))

str(iris$Species)
table(iris$Species)

# Cf) -----------------------------------------------------------------------------
# sample 함수

# sample(벡터) : 벡터의 원소들을 랜덤하게 모두 추출.
v = c(1:10)
sample(v)
# sample(벡터, n) : 벡터의 원소들 중에서 n개의 원소를 랜덤하게 추출. 
sample(v, 7)
# sample(n) : 1 ~ n까지 n개의 정수를 랜덤 추출.
sample(5)
sample(150)
# -----------------------------------------------------------------------------

# 품종별로 구분된 데이터를 랜덤하게 섞은 후, 데이터 세트를 나눔.
nrow(iris)
iris_shuffled = iris[sample(nrow(iris)), ]

head(iris_shuffled)
tail(iris_shuffled)
table(iris_shuffled$Species)

# 학습 데이터 세트 / 레이블, 테스트 데이터 세트 / 레이블 준비
train_set = iris_shuffled[1:100, 1:4] # 5번 컬럼인 '종'은 제외
train_label = iris_shuffled[1:100, 5] # 5번 컬럼인 '종'만 가져오면 됨.
head(train_set)
head(train_label)

test_set = iris_shuffled[101:150, 1:4]
test_label = iris_shuffled[101:150, 5]
head(test_set)
head(test_label)

prop.table(table(train_label))
prop.table(table(test_label))

# 정규화 구현
normalize = function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# 정규화
iris_normal_train_set = as.data.frame(lapply(train_set[1:4], normalize))
iris_normal_test_set = as.data.frame(lapply(test_set[1:4], normalize))
summary(iris_normal_train_set)
summary(iris_normal_test_set)

# k-NN 알고리즘 적용
library(class)
predict = knn(train = iris_normal_train_set,
              test = iris_normal_test_set,
              cl = train_label, 
              k = 9)

# 이원교차표(크로스테이블) 적용
library(gmodels)
CrossTable(test_label, predict, prop.chisq = F)

# ==============================================================================================================