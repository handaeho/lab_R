# 분할 정복: 의사결정 트리와 규칙 기반의 분류
# = 트리와 규칙이 데이터를 관심있는 세그먼트로 탐욕스럽게 분할하는 방법
# C5.0, 1R, RIPPER 알고리즘을 포함하는 가장 보편적인 의사결정 트리(decisionmtree)와 분류 규칙 학습자(rule learner)
# 위험 은행 대출과 독버섯 식별과 같은 실제 분류 작업을 수행하기 위한 알고리즘 사용 방법

# 의사결정 트리(decision tree)의 장점
# = 대다수의 의사결정 트리 알고리즘은 모델이 생성된 이후 생성된 구조를 사람이 읽을 수 있는 형식으로 출력.
# 모델이 어떻게, 왜 특정 작업에 잘 작동하는지 또는 잘 작동하지 않는지에 대한 통찰력이 제공.
# 즉, 의사결정 트리는 왜그랬는지, 어떻게 그렇게 결정했는지에 대해 명확하게 보여준다.


# 의사 결정 트리 가지치기(Pruning)
# = 의사 결정 트리가 너무 크게 자라면 트리가 만든 많은 결정들이 너무 세분화돼 학습 데이터에 모델이 과적합됨.
# 가지치기(Pruning): 테스트 데이터에 일반화가 잘 될 수 있도록 트리의 크기를 줄이는 것.
# 1) 사전 가지치기(Pre-pruning): 결정(decision)이 특정 갯수에 도달하거나 결정 노드가 포함하는 
# 관찰값(observation, example) 갯수가 아주 작은 숫자가 되면 트리의 성장을 멈추는 것.
# --- 트리가 크게 자랐다면 학습할 수도 있었을 중요한 패턴을 놓치게 될 지 알 방법이 없다는 단점이 있다.
# 2) 사후 가지치기(Post-pruning): 의도적으로 트리를 아주 크게 자라게 한 후 트리 크기를 적절한 수준으로 줄이기위해 잎 노드를 자름.
# --- 사전 가지치기보다 효율적. C5.0 알고리즘에서 사용됨.

# --------------------------------------------------------------------------------------------------------------

# C5.0 알고리즘 활용 예제: 은행의 위험 대출 식별

# 데이터 프레임 생성 & 구조 및 내용 확인
credit = read.csv("data/credit.csv", encoding = "UTF-8")
str(credit)
head(credit)

# 대출 상황 능력과 관계가 있는 변수들은?
# 범주형 변수(특징) ---> table()로 확인 / 수치형 변수(특징) ---> summary()로 확인
table(credit$checking_balance)
table(credit$savings_balance)
table(credit$employment_duration)

summary(credit$months_loan_duration)
summary(credit$amount)

# 대출 상환 채무 불이행(default) 상태
table(credit$default)

# 한편, 현재 데이터들이 정렬되어 있지는 않다.
head(credit$amount, 10)
tail(credit$amount, 10)
head(credit$default, 10)
tail(credit$default, 10)
# Cf) 정렬 데이터를 랜덤 샘플링 하려면, sample()을 사용하면 된다.

# 학습 데이터 세트(90%)와 테스트 데이터 세트(10%) 준비
rows = sample(1000, 900)
train_set = credit[rows, ]
test_set = credit[-rows, ] # train_set의 rows를 제외한 나머지들을 행으로

# 학습 데이터 세트와 테스트 데이터 세트에서 default 비율 확인
prop.table(table(train_set$default))
prop.table(table(test_set$default))

# 의사결정 트리를 사용하기 위한 필요 패키지 설치 & 라이브러리 로드
install.packages("C50")
library(C50)
search()

# train_set를 이용해 의사결정 트리 기반 예측 모델 생성.

# C50::C5.0(train, class, trials = 1, costs = NULL) 함수
# train : 학습 데이터 세트
# class : 학습 데이터 세트 레이블(학습데이터세트에 대한 정답(분류))
# trials, costs : 모델 성능 개선을 위한 옵션(trials = 1, costs = NULL이 default값)
# --- trials => 적응형 부스팅(Adaptive boosting, AdaBoost): 여러개의 의사결정 트리를 만들어서 각 예시에 대해
#               최고의 클래스를 투표하게 만드는 과정.(1 ~ 100)
# --- costs => 비용 행렬(Cost matrix). 오류 유형에 페널티를 줌. 
#              원본 행렬에 대해 행과 열이 서로 바뀐 행렬 형태로 들어가야하며, 행렬의 원소가 페널티.
# 혼동 행렬(confusion matrix) : 모델이 학습 데이터에서 부정확하게 분류한 레코드를 보여주는 교차표
credit_model = C5.0(train_set[-17], train_set$default, trials = 1, costs = NULL) 
# 또한, 학습 데이터 세트에서는 데이터의 레이블(class)가 제거되어야 한다.
# 따라서 train에는 가장 마지막 컬럼인 default 제거, class에는 레이블인 deflaut 컬럼 적용.
credit_model
summary(credit_model)

# 만든 모델을 이용해서 test_set 예측, 평가
# stats::predict(model, 테스트데이터세트)
credit_predict = predict(credit_model, test_set)

# 이원교차표(크로스 테이블)을 이용해 결과 확인
library(gmodels)
CrossTable(x = test_set$default, 
           y = credit_predict)
# Column Total |        79 |        21 |       100 | 
#              |     0.790 |     0.210 |           | 
# 100개 예측 시, 79명은 채무 정상 이행, 21명은 채무 불이행으로 예측함.

# 모델 성능 개선

# 1) 의사 결정 트리 개수 변경(trials 변경) ---> AdaBoost
credit_boost = C5.0(train_set[-17], train_set$default, trials = 10, costs = NULL)
credit_boost
summary(credit_boost)

# AdaBoost를 적용한 모델 성능 평가
credit_boost_predict = predict(credit_boost, test_set)
table(credit_boost_predict)

CrossTable(x = test_set$default,
           y = credit_boost_predict)


# 2) 비용 행렬 사용(costs 사용) ---> costs matrix

# 비용 행렬의 행과 열 이름 지정.
matrix_dimname = list(predict = c("no", "yes"),
              actual = c("no", "yes"))

# 비용 행렬 생성
cost_matrix = matrix(data = c(0, 1, 4, 0), # 행렬을 채울때는 열부터 채운다.
                     nrow = 2,
                     byrow = F, # byrow는 F가 기본값이며, 이 때문에 열부터 채우는것. T로 주면 행부터 채운다.
                     dimnames = matrix_dimname)
cost_matrix

# 모델에 적용
credit_cost = C5.0(train_set[-17], train_set$default, trials = 1, costs = cost_matrix)
credit_cost
summary(credit_cost)

# costs matrix를 적용한 모델 성능 평가
credit_cost_predict = predict(credit_cost, test_set)
table(credit_cost_predict)

CrossTable(x = test_set$default,
           y = credit_cost_predict,
           prop.chisq = F,
           prop.c = F,
           prop.r = F)

# --------------------------------------------------------------------------------------------------------------

# 분류 규칙(Classification Rules)
# --- 규칙(rules): A가 발생하면, B가 발생한다.(If A, then B.)
# --- 규칙 학습자(rule learner) 응용 사례
# ○ 기계 장비에 고장을 유발하는 조건의 식별
# ○ 고객 세분화를 위한 그룹의 주요 특징 기술
# ○ 주식 시장에서 큰 폭의 주가 하락이나 주가 상승에 선행하는 조건을 찾는 일

# 분리 정복(Separate and Conquer)
# = 여러 대상 중, 기준(규칙)을 선정하고 기준(규칙)에 맞는 대상들만을 골라 '분리'한다.
# 단계가 진행될수록, 세분화된 새로운 기준(규칙)을 적용한다.

# 1) 1R Algorithm(One Rule, OneR): 하나의 규칙만 선택
# => 각 특징(변수)에 대해 유사한 값을 기준으로 데이터를 분리.
#    각 세그먼트에 대해 대다수 클래스를 예측
#    기준(규칙)은 대상의 특징에 기반을 두고 최소 오류율을 갖도록 선정한다. (단일규칙, One Rule) 

# 2) RIPPER(Repeated Increment Pruning to Produce Error Reduction) 알고리즘
# => 전체 데이터 세트에서 아주 복잡한 규칙을 기른다.
#    사전 가지치기(pre-pruning)와 사후 가지치기(post-pruning) 방법을 조합해 가지치기한다. 즉, 규칙을 가지치기 하는것.
#    최적화
#    의사 결정 트리의 성능과 비슷하거나 더 나은 규칙을 생성


# --- 의사결정 트리: 분할 정복(Divide and conquer)
# --- 규칙 학습: 분리 정복(Seperate and conquer)

# 분할 정복 VS 분리 정복
# 1) 분할에 의해 생성된 파티션은 재정복되지 않고 단지 하위 분할만 된다. 즉, 트리는 이전 결정의 이력에 의해 영원히 제약된다.
# 2) 분리 정복으로 규칙을 발견하면, 규칙의 모든 조건으로 커버되지 않는 어떤 관찰값(예시)든 재정복될 수 있다.

# --------------------------------------------------------------------------------------------------------------

# 규칙 학습 예제: 독버섯 식별

# 규칙 학습자(Rule Learner) 분류기

# 데이터 파일 읽어오기 & 확인
mushroom = read.csv("data/mushrooms.csv", encoding = "UTF-8")
str(mushroom)
head(mushroom)
tail(mushroom)
table(mushroom$type) # edible 4208 / poisonous 3916

# 팩터가 1개뿐인 veil_type 변수는 모든 행이 동일한 값이므로 분류 기준에서 제외.
mushroom$veil_type = NULL
str(mushroom)

# 1) 1R Algorithm(One Rule, OneR) 분류기
install.packages("OneR")
library(OneR)
search()

# 1R 분류기 모델
mushroom_1R = OneR(type ~ ., data = mushroom)
# 'type' => 종속변수 / '.' => type를 제외한 모든 변수가 독립변수. ('.' --- 모든 변수)
# '~'은 기호 (Y ~ x + y +z)
# data는 mushroom
mushroom_1R

mushroom_1R_cap = OneR(type ~ cap_shape + cap_surface + cap_color,
                       data = mushroom)
mushroom_1R_cap

summary(mushroom_1R) 
# Rules ---> 1R 분류기가 분류한 결과
# Contingency table ---> 실제 데이터의 분류 테이블
# Contingency table과 1R 분류기가 분류한 결과를 비교해보면 된다.

# 2) RIPPER Algorithm(Repeated Increment Pruning to Produce Error Reduction) 분류기 
install.packages("RWeka")
library(RWeka)
search()

# RIPPER 분류기 모델
mushroom_ripper = JRip(type ~ ., data = mushroom)
mushroom_ripper
# 각 분류 기준의 rule이 1개 이상으로 구성됨. 괄호 안은 정확도를 의미.
# Number of Rules : 9
# ~> rule은 총 9개
# (odor = foul) => type=poisonous (2160.0/0.0)
# ~> 냄새가 악취가 나면 독버섯이다.
# (gill_size = narrow) and (gill_color = buff) => type=poisonous (1152.0/0.0)
# ~> 아가미가 좁고, 색이 담황색이면 독버섯이다. 
#  => type=edible (4208.0/0.0)
# ~> rule에 하나라도 만족하지 않는 대상이 있으면 식용버섯이다.

summary(mushroom_ripper)
