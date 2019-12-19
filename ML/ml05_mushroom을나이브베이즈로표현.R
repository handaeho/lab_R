# mushroom을 나이브베이즈로 나타내보자.

# 데이터 준비
mushroom_naive = read.csv("data/mushrooms.csv")
str(mushroom_naive)

# 분류에 필요하지 않은 특징인 'veil_type' 제거.(factor가 1개만 존재)
mushroom_naive$veil_type = NULL
str(mushroom_naive)

# 버섯들의 클래스(분류 label) ---> type 변수
table(mushroom_naive$type)
prop.table(table(mushroom_naive$type))
# 식용 버섯 : 독 버섯 = 약 52 : 48

# 학습 데이터 세트와 테스트 데이터 세트 구성
mushroom_train = mushroom_naive[1:6000, c(2:23)]
mushroom_train_label = mushroom_naive[1:6000, 1]
head(mushroom_train_label, 100)

mushroom_test = mushroom_naive[6001:8124, c(2:23)]
mushroom_test_label = mushroom_naive[6001:8124, 1]
head(mushroom_test_label, 100)

# ---------- sample() Ver. ---------- (train : test = 75 : 25)
sample_count = round(nrow(mushroom_naive) * 0.75) # nrow : 데이터프레임의 행 개수
set.seed(123)
sample_rows = sample(nrow(mushroom_naive), sample_count)
sample_rows

mushroom_sample_train = mushroom_naive[sample_rows, ]
mushroom_sample_train_label = mushroom_sample_train$type
mushroom_sample_train = mushroom_sample_train[-1]
table(mushroom_sample_train_label)
prop.table(table(mushroom_sample_train_label))

mushroom_sample_test = mushroom_naive[-sample_rows, ]
mushroom_sample_test_label = mushroom_sample_test$type
mushroom_sample_test = mushroom_sample_test[-1]
str(mushroom_sample_test_label)
table(mushroom_sample_test_label)
prop.table(table(mushroom_sample_test_label))

# 나이브 베이즈 알고리즘 적용
library(e1071)

mushroom_classifier = naiveBayes(mushroom_train, mushroom_train_label)

# ---------- sample() Ver. ----------
classifier = naiveBayes(mushroom_sample_train, mushroom_sample_train_label)
summary(classifier)

# 분류기를 사용해 테스트 데이터 세트의 분류 결과 예측
mushroom_pred = predict(mushroom_classifier, mushroom_test)
table(mushroom_pred)
prop.table(table(mushroom_pred))

# ---------- sample() Ver. ----------
mushroom_sample_pred = predict(classifier, mushroom_sample_test)
table(mushroom_sample_pred)
prop.table(table(mushroom_sample_pred))

# Croos Table 이용해 확인
library(gmodels)

CrossTable(x = mushroom_test_label,
           y = mushroom_pred,
           prop.chisq = F)

# # ---------- sample() Ver. ----------
CrossTable(x = mushroom_sample_test_label,
           y = mushroom_sample_pred,
           prop.chisq = F)

# 모델 성능 향상을 위해 라플라스 추정을 사용해보자.
mushroom_classifier_laplace = naiveBayes(mushroom_train, mushroom_train_label,
                                         laplace = 1)

mushroom_pred_laplace = predict(mushroom_classifier_laplace, mushroom_test)

table(mushroom_pred_laplace)
prop.table(table(mushroom_pred_laplace))

# # ---------- sample() Ver. ----------
classifier_laplace = naiveBayes(mushroom_sample_train, mushroom_sample_train_label,
                                laplace = 0.1)

mushroom_sample_pred_laplace = predict(classifier_laplace,mushroom_sample_test)
table(mushroom_sample_pred_laplace)
prop.table(table(mushroom_sample_pred_laplace))

# Croos Table 이용해 확인
CrossTable(x = mushroom_test_label,
           y = mushroom_pred_laplace,
           prop.chisq = F)

# ---------- sample() Ver. ----------
CrossTable(x = mushroom_sample_test_label,
           y = mushroom_sample_pred_laplace,
           prop.chisq = F)
