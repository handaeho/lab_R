# 패턴 찾기: 연관 규칙을 이용한 장바구니 분석

# 연관 규칙(Associative Rules)
# ● 자율 학습(비지도 학습, unsupervised learning)의 한가지 방법
# ○ 데이터가 사전에 레이블될 필요가 없다.
# ● 대규모 데이터베이스에서 자율적인 지식의 발견(패턴 감지)를 위해 사용
# ● 장바구니 분석에 가장 많이 사용 (예: 땅콩 버터와 젤리가 함께 구매되면 빵도 구매될 가능성이 있다.)
# ● 응용 분야
# ○ 암 데이터에서 빈번히 발생하는 DNA/단백질 서열 패턴
# ○ 사기성 신용카드 구매 패턴
# ○ 사기성 의료비 청구 패턴

# Apriori 알고리즘 - 연관 규칙 학습
# ● a priori
# ○ (실험/경험이 아닌 가설/이론에 기초해서) 선험적인, 추측인, 비분석적인
# ● Apriori 알고리즘
# ○ “빈번한 아이템 집합의 모든 부분집합 역시 빈번해야 한다.”는 선험적(a priori) 믿음을 이용.
# ○ 어떤 아이템이 빈번하지 않다면, 그 아이템을 포함하는 어떤 집합이든 검색에서 제외할 수 있다

# ● 지지도(Support) : 데이터에서 발생하는 빈도
# support(X) = count(X) / N

# ● 신뢰도(Confidence) : 예측 능력 또는 정확도의 측정치
# X, Y를 모두 포함하는 아이템 세트의 지지도를 X만 포함하는 아이템 세트의 지지도를 나눈 값
# confidence(X -> Y) = support(X, Y) / support(X) ~~~> P(A|B) = P(A ∩ B) / P(B)와 같다.

# Aprioi 원칙(Apriori Principle)을 이용한 규칙 집합 만들기
# ○ {A, B}가 빈번하다면, {A}와 {B} 모두 빈번해야 한다.
# ○ {A} 또는 {B}가 빈번하지 않다면, {A, B}는 빈번하지 않다.
# - {A}가 원하는 지지도 임계치를 만족하지 않는다면 {A}를 포함하는 어떤 아이템 집합도 고려할 이유가 없다.

# ● {A, B, C, D.}
# ○ {A}, {B}, {C}는 빈번하고, {D}는 빈번하지 않음 ⇒ {A, B}, {A, C}, {B,C} 를 고려
# ○ {A, B}, {B,C}는 빈번한데, {A, C}는 빈번하지 않음 ⇒ {A, B, C}를 고려하게 되는데, {A, C}가 빈번하지 않으므로 {A, B, C}는 고려대상이 될 수 없음.
# ○ Apriori 알고리즘은 {A, B}, {B,C} 두개의 규칙을 만들어 내고 종료

#-----------------------------------------------------------------------------------------------------------

# groceries 데이터로 연관 규칙 학습

# 데이터 준비 & 확인
groceries = read.csv("data/groceries.csv", header = F) # groceries 데이터에 헤더 없음.
str(groceries) # 15296개 예시 / 4개 특징
head(groceries) 
# 사람마다 구매 물품과 그 개수가 달라 컬럼의 수가 일정하지 않다.(칸이 밀리거나 지워짐)
# 1행의 아이템이 4개여서 4개에 맞추어 데이터프레임을 생성했지만, 2행부터는 개수가 다 달라 서로 컬럼의 수가 맞지 않음.
# 따라서 이 상태로는 데이터 분석 불가능.

# 해결 방법 => 희소 행렬(Sparse Matrix)

# arules(association rules, 연관 규칙) 패키지 설치 & 로드
install.packages("arules")
library(arules)
search()

# groceries 데이터를 희소 행렬로 읽어오기
groceries = read.transactions("data/groceries.csv", header= F, sep = ",")
# sep = "," ~~~> 입력 파일에서 아이템들을 ','로 구분한다. default는 " " 이므로 반드시 ','로 전달해야 함.
# header = F가 default
summary(groceries) # 9835 rows(elements/itemsets/transactions) and 169 columns(items)
# read.csv와 읽어온 구조의 값이 다르다. 9835 rows / 169 colums가 정확한 것.

# a density of 0.02609146 ---> 행렬에서 0이 아닌 셀의 비율

# most frequent items:
# whole milk    other vegetables  rolls/buns         soda           yogurt          (Other) 
# 2513             1903             1809             1715             1372            34055 

# element (itemset/transaction) length distribution:
# sizes
# 1    2    3    4     5    6    7    8    9    10   11   12   13   14   15   16   17   18   19   20   21  22   23   24   26   27   28   29   32 
# 2159 1643 1299 1005  855  645  545  438  350  246  182  117  78   77   55   46   29   14   14    9   11   4    6    1    1    1    1    3    1
# ---> 1개만 산(아이템 = 1) 영수증은 2159개, 2개 산 영수증은 1643개, 3개 산 영수증은 1299개, ...
#  Min. 1st Qu.  Median  Mean   3rd Qu. Max. 
# 1.000  2.000   3.000   4.409  6.000   32.000 

# 희소 행렬의 각 행들의 내용 보기
inspect(groceries)

# 아이템 빈도 그래프 그리기 ---> itemFrequencyPlot()
itemFrequencyPlot(groceries, support = 0.1, topN = 20)
# support 파라미터 ---> 아이템을 최소 거래 비율로 나타냄.
# topN 파라미터 ---> 지정개수만큼 도표에 나타냄.

# 전체 희소행렬 시각화 ---> image()
image(groceries)
# 데이터의 이상치나, 경향 등을 파악할 수 잇다.
# 그러나 큰 데이터베이스의 경우 식별이 힘들다. 따라서 sample() 함수로 랜덤한 대상에 대한 희소 행렬을 보려면
image(sample(groceries, 100))

# 데이터에 대한 arules::apriori 모델링 & 자율 학습
groceriesrules = apriori(data = groceries, parameter = list(support = 0.006, confidence = 0.25, minlen = 2))
# data : 거래 데이터를 갖는 희소 아이템 행렬
# parameter는 list() 형태로 주어야 한다.
# support : 요구되는 최소 규칙 지지도(default = 0.1) / confidence : 요구되는 최소 규칙 신뢰도(default = 0.8)
# minlen : 요구되는 최소 규칙 아이템
# support와 confidence는 서로 균형있게 설정되어야만 한다. 너무 작은 값이면 신뢰 대상이 너무 많아지고, 너무 큰 값이면 신뢰 대상이 너무 없어진다.
groceriesrules # set of 463 rules 

# 모델 성능 평가
summary(groceriesrules)

# 연관 규칙 검토
inspect(groceriesrules)
#       lhs                           rhs                  support     confidence lift      count
# [1]   {potted plants}            => {whole milk}         0.006914082 0.4000000  1.5654596  68  
# [2]   {pasta}                    => {whole milk}         0.006100661 0.4054054  1.5866145  60  
# [3]   {herbs}                    => {root vegetables}    0.007015760 0.4312500  3.9564774  69  
# [4]   {herbs}                    => {other vegetables}   0.007727504 0.4750000  2.4548739  76  
# [5]   {herbs}                    => {whole milk}         0.007727504 0.4750000  1.8589833  76  
# lhs(좌변) ---> 규칙을 실행하기 위해, 만족되어야 하는 조건.
# rhs(우변) ---> 그 조건(lhs)을 만족했을 때, 기대하는 결과.
# lift(향상도) ---> 'X가 구매되면, Y가 어떤 확률로 구매될 것인가'를 Y의 일반적인 구매 확률과 비교해 측정.
# lift(X -> Y) = confidence(X -> Y) / support(Y)
# lift가 클 수록 예상보다 더 자주 두 아이템이 함께 구입되었다는것.

# 하루에 10번 판매되는 아이템 * 30개 => 영수증 300개
300 / 9835 # 300개 / 전체 개수 = 약 0.03
groceriesrules_300 = apriori(data = groceries, parameter = list(support = 0.03, confidence = 0.25, minlen = 2))
groceriesrules_300 # set of 15 rules 
summary(groceriesrules_300)
inspect(groceriesrules_300)
#      lhs                     rhs                support    confidence lift     count
# [1]  {whipped/sour cream} => {whole milk}       0.03223183 0.4496454  1.759754 317  
# [2]  {pip fruit}          => {whole milk}       0.03009659 0.3978495  1.557043 296  
# [3]  {pastry}             => {whole milk}       0.03324860 0.3737143  1.462587 327  
# [4]  {citrus fruit}       => {whole milk}       0.03050330 0.3685504  1.442377 300  
# [5]  {sausage}            => {rolls/buns}       0.03060498 0.3257576  1.771048 301 

# 정렬 sort()
inspect(sort(groceriesrules_300, by ="lift")[1:10]) # ---> lift 기준 내림차순 출력

# 연관 집합의 부분 집합 구하기 ---> subset()
berryrules = subset(groceriesrules, items %in% "berries")
# 키워드 item은 규칙의 어디서나 나타나는 아이템과 매칭. 좌측, 우측에만 매칭되는 부분 집합으로 제약하려면 'lhs'나 'rhs'를 사용.
# 연산자 %in%는 아이템 중, 최소 하나가 정의한 목록에서 발견되어야 한다.
# 부분 매칭(%pin%) : items %pin% "fruit" ---> 과일과 열대 과일 모두 찾을수 있음.
# 완전 매칭(%ain%) : items %ain% c("berries", "yogurt") ---> 'berries'와 'yogurt'를 모두 갖는 규칙만 찾는다.
# 부분 집합은 support, confidence, lift로 제약 가능하다.
# 매칭 조건은 '&', '|', '!'등 논리연산자 결합 가능.

inspect(berryrules)
#     lhs          rhs                  support     confidence lift     count
# [1] {berries} => {whipped/sour cream} 0.009049314 0.2721713  3.796886  89  
# [2] {berries} => {yogurt}             0.010574479 0.3180428  2.279848 104  
# [3] {berries} => {other vegetables}   0.010269446 0.3088685  1.596280 101  
# [4] {berries} => {whole milk}         0.011794611 0.3547401  1.388328 116  


