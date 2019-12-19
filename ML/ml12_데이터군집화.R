# 데이터 그룹 찾기: k-평균 군집화

# Clustering(군집화)의 이해
# ● 데이터를 클러스터(cluster, 유사한 아이템들의 그룹)으로 분리하는 자율(비지도, unsupervised) 머신 러닝 작업

# ● Clustering의 원칙
# ○ 클러스터 안에 있는 아이템들은 서로 아주 비슷해야 한다.
# ○ 클러스터 밖에 있는 아이템들은 아주 달라야 한다.

# ● 분류(classification) vs 군집화(clustering)
# ○ classification: 레이블이 있는 데이터의 패턴을 설명
# ○ clustering: 레이블이 없는 예시(example, observation)들을 분류

# k-means algorithm(k-평균 알고리즘)
# ● n개의 예시를 k개의 클러스터 중 하나에 할당(k는 사전에 결정된 숫자)

# ● 클러스터 냉의 차이를 최소화하고, 클러스터 간의 차이를 최대화

# ● 지역 최적 해(locally optimal solution)을 찾는 휴리스틱(heuristic) 과정을 사용
# ○ k개의 초기 클러스터 집합에 예시들을 할당
# ○ 클러스터 경계를 조정하여 예시들의 할당을 수정하여 동질성을 향상시키는 지 확인
# ○ 경계 수정과 예시 할당의 과정을 더이상 클러스터 적합도를 향상시키지 못할 때까지 반복
# ○ 클러스터 적합도가 더이상 향상되지 않는 시점에 과정이 중단되고 클러스터가 완성

# k-평균은 클러스터 수에 민감하다. k를 아주 크게하면 클러스터의 동질성은 향상되지만, 데이터가 Overfitting 될 수 있다.

# k 설정 방법
# 1) k = sqrt(n/2) ---> n : 데이터 셋의 예시 개수
# 2) 엘보법(Elbow Method) 
# => 다양한 k값에 대해 클러스터 내의 동질성과 이질성의 변화를 측정.
# => 동질성을 최대화, 이질성을 최소화 하는것이 아닌,  특정 포인트를 넘어가면 k가 약화되는 지점(엘보 포인트, Elbow Point)을 찾는 것.

# k가 변할 때 클러스터의 특성이 어떻게 변화하는지를 관찰하면 데이터가 자연스럽게 경계를 정의하는 곳을 추론 가능.
# 보다 군집화 된 그룹 ~> 거의 변하지 않음. / 보다 덜 동질적인 그룹 ~> 시간이 지나며 형성되고 해체됨.

#-----------------------------------------------------------------------------------------------------------

# 10대 snsdata 데이터를 이용한 k-평균 군집화 학습

# 데이터 준비 & 확인
teens = read.csv("data/snsdata.csv")
str(teens) # 30000개 예시 / 40개 특징

# 현재 gender에서 NA 존재.
table(teens$gender) # F 22054 / M 5222
table(teens$gender, useNA = "ifany") # F 22054 / M 5222 / NA 2724

# 또한 age 변수에도 NA 존재
summary(teens$age) 
# Min.   1st Qu.  Median  Mean    3rd Qu. Max.     NA's 
# 3.086  16.312   17.287  17.994  18.259  106.927  5086 

# 10대의 sns data이므로 13세 ~ 19세로 연령을 설정. 이외는 NA.
teens$age = ifelse(teens$age >= 13 & teens$age < 19, teens$age, NA)
summary(teens$age)
# Min.  1st Qu. Median  Mean   3rd Qu. Max.  NA's 
# 13.03 16.24   17.16   17.12  18.05   19.00 7000 

# 더미 코딩을 이용하여, 성별(범주형 변수)에 '알수 없음'을 추가
# 더미코딩은 레퍼런스 그룹으로 제공하기 위해, 빠지는 1개를 제외하고 명목 특징의 모든 레벨에 대해 이진변수(0, 1를 갖는 별도의 더미 변수 생성.
# 번주 하나가 제외 가능한 이유는 다른 범주로 부터 나머지 1개를 추론 가능('여자'도 아니고 '알수 없음'도 아니면 '남자')

# 여자면 'F', NA가 아니면 '1', NA이면 '0'
teens$female = ifelse(teens$gender == "F" & !is.na(teens$gender), 1, 0)
teens$no_gender = ifelse(is.na(teens$gender), 1, 0)

table(teens$gender, useNA = "ifany") # F 22054 / M 5222 / NA 2724
table(teens$female, useNA = "ifany") # 0 7946 / 1 22054
table(teens$no_gender, useNA = "ifany") # 0 27276 / 1 2724

# age 변수의 NA 대체
# 대체 ~> 누락된 데이터를 실제 값에 대한 추정 값으로 채움.

# 졸업 년도가 같으면 나이가 같을 것으로 추정하고, NA를 대체하자.
# 대표 값을 찾기 위해 평균을 계산.
# aggregate() 함수 ~> 데이터의 하위 그룹에 대한 통계 계산. 출력은 데이터 프레임.
mean(teens$age) # NA
mean(teens$age, na.rm = TRUE) # 17.12484
aggregate(data = teens, age ~ gradyear, mean, na.rm = TRUE)
#   gradyear      age
# 1     2006 18.48625
# 2     2007 17.69346
# 3     2008 16.76123
# 4     2009 15.81270

# aggregate()의 결과는 데이터 프레임이므로, 원 데이터와의 합병을 위해서는 추가 작업 요구됨. 따라서 적합하지 않음.
# 대안 : ave() 함수 ~> 결과가 원 벡터의 길이와 같아지게 그룹의 평균이 반복되는 벡터를 반환.
# 즉, 그룹별 평균(또는 임의의 함수)을 적용해서, 벡터를 반환하는 것.
my_mean = function(x){
  mean(x, na.rm = TRUE)
}
ave_age = ave(teens$age, teens$gradyear, FUN = my_mean)
# ave(평균을 계산할 벡터, 그룹핑 변수, FUN = 함수) ---> FUN의 default는 mean
head(ave_age) # 18.48625 18.48625 18.48625 18.48625 18.48625 
tail(ave_age) # 15.8127 15.8127 15.8127 15.8127 15.8127 15.8127

# 평균으로 NA를 대체하기 위해 원래 NA였다면 ave_age값을 사용하게 하자
teens$age = ifelse(is.na(teens$age), ave_age, teens$age)
summary(teens$age)
# Min.   1st Qu.  Median  Mean   3rd Qu.  Max. 
# 13.03  16.28    17.23   17.19  18.20    19.00 

# 또 다른 방법 : dplyer 패키지 이용
library(dplyr)

teens %>% 
  group_by(gradyear) %>% 
  filter(!is.na(age)) %>% 
  summarise(mean(age))

teens$age = ifelse(teens$gradyear == 2006 & is.na(teens$age), 18.5, teens$age)
teens$age = ifelse(teens$gradyear == 2007 & is.na(teens$age), 17.7, teens$age)
teens$age = ifelse(teens$gradyear == 2008 & is.na(teens$age), 16.7, teens$age)
teens$age = ifelse(teens$gradyear == 2009 & is.na(teens$age), 15.8, teens$age)

# 데이터에 대한 k-평균 군집화 모델 훈련 ---> stats::kmeans()
library(stats)

# 개인 식별 정보(gradyear, gender, age, friends 등)를 제외하고 오로지 '관심사'로만 클러스터링을 해보자.
interests = teens[5:40]
str(interests)
set.seed(2345)

# 클러스터 찾기 ---> my_clusters = kmeans(data, k) 
teen_clusters = kmeans(interests, 5)
str(teen_clusters)

# k-평균 군집화 모델 성능 평가

# kmeans() 클러스터의 크기를 알기 위해서는 $size를 이용.
teen_clusters$size #  2128 1200 731 638 25303 ---> 가장 작은 클러스터의 10대는 638명, 가장 큰 클러스터는 25303명

# kmeans() 클러스터의 중심점을 알기 위해서는 $centers를 이용.
teen_clusters$centers
#   basketball  football     soccer  softball volleyball  swimming cheerleading   baseball     tennis    sports
# 1  0.5808271 0.5305451 0.23637218 0.2946429  0.2617481 0.2659774   0.21005639 0.25845865 0.16682331 0.3825188
# 2  0.3591667 0.3725000 0.14000000 0.1875000  0.1716667 0.1625000   0.18750000 0.08416667 0.09916667 0.1208333
# 3  0.4705882 0.4295486 4.86730506 0.1915185  0.2079343 0.2106703   0.09439124 0.12859097 0.15321477 0.3160055
# 4  0.2993730 0.2680251 0.14733542 0.1865204  0.1410658 0.1489028   0.12695925 0.10501567 0.08934169 0.1802508
# 5  0.2299332 0.2176817 0.09326957 0.1472157  0.1299846 0.1194325   0.09394143 0.09232107 0.07813303 0.1143738

# ~~~> 1번째 행(4번 클러스터)이 농구에 대한 관심이 가장 높고, 5번째 행(5번 클러스터)이 농구에 대한 관심이 가장 낮다.

# k-평균 군집화 모델 성능 개선

# 생성된 클러스터를 다시 teens 데이터 프레임에 넣어 비교
teens$cluster = teen_clusters$cluster
teens[1:5, c("cluster", "gender", "age", "friends")]
#   cluster gender    age friends
# 1       5      M 18.982       7
# 2       1      F 18.801       0
# 3       5      M 18.335      69
# 4       5      F 18.875       0
# 5       1   <NA> 18.995      10

# aggregate() 함수를 이용해, 클러스터의 인구통계학적 특징 파악
aggregate(data = teens, age ~ cluster, mean)
#   cluster      age
# 1       1 17.03258
# 2       2 16.99904
# 3       3 16.95571
# 4       4 17.30619
# 5       5 17.21425

aggregate(data = teens, female ~ cluster, mean)
#   cluster    female
# 1       1 0.8341165
# 2       2 0.8591667
# 3       3 0.7674419
# 4       4 0.7382445
# 5       5 0.7199146

aggregate(data = teens, friends ~ cluster, mean)
#   cluster  friends
# 1       1 32.64192
# 2       2 36.74417
# 3       3 36.51984
# 4       4 34.72884
# 5       5 29.36316
 

# 이번에는 먼저 데이터에 대해 '표준화'를 하고, 클러스터링을 해보자.

# interests 데이터 프레임의 표준화를 위해 z-score 표준화 실행. ---> lapply()함수와 scale()함수
interests_z = as.data.frame(lapply(interests, scale))

teen_clusters_z = kmeans(interests_z, 5)
teen_clusters_z$size # 4790 21808 449 1983 970
teen_clusters_z$centers
#     basketball    football      soccer    softball  volleyball    swimming  cheerleading      baseball       tennis
# 1  0.478518478  0.47666349 -0.01503406  0.42386936  0.46239513  0.32314224  0.5013798454  0.2478401511  0.128288474
# 2 -0.126844666 -0.12710346 -0.15438271 -0.09791074 -0.10292816 -0.08834034 -0.1136229665 -0.0660396583 -0.034022475
# 3  0.110616695  0.06225760 -0.02919191  0.00789213 -0.01136957  0.08036235  0.0005266985 -0.0004912026  0.033549404
# 4  0.003683568  0.03266489  1.67646547 -0.03999049 -0.04636179  0.03266199 -0.0700582149 -0.0377763885 -0.006030436
# 5  0.430055200  0.40817110  0.13140964  0.18624822  0.13074734  0.28641592  0.2216176771  0.3383192509  0.128201045
teens$cluster_z = teen_clusters_z$cluster
teens[1:5, c("cluster", "gender", "age", "friends")]
#   cluster gender    age friends
# 1       5      M 18.982       7
# 2       1      F 18.801       0
# 3       5      M 18.335      69
# 4       5      F 18.875       0
# 5       1   <NA> 18.995      1