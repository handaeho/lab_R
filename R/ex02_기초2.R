# 변수 선언 & 사용

# 변수이름 <- 값
# 변수이름 = 값
# 데이터 타입 명시 X
x <- 11
y = 22
name = 'daeho'
name <- 100
num_array = 1:10

# seq(start, end, by 증분값) # 'by'는 생략 가능.
num_array = seq(1, 10, 2) #1부터 10까지 2씩 증가하며 저장
num_array2 = seq(10, 1, -1)
num_array3 = seq(1, 10, pi)

# Combine -> C(...)
num_array <- c(1, 10, 100, 1234)
names <- c('강', '김', '박')

# 배열의 인덱스 -> 배열이름[인덱스]
# r에서 배열의 인덱스는 1부터 시작. 연속적으로 증가하는 양의 정수.
num_array <- c(1:10)
num_array[3]
names[2] # 배열 names의 2번지 값을 출력.
num_array[1:5] # 1번지부터 5번지까지의 값 출력.
num_array[5:7] # 5번지부터 7번지까지의 값 출력.
num_array[c(1, 5, 10)] # c() 함수를 사용해 1, 5, 10번지 값 출력.
num_array[seq(1, 10, 2)] # seq() 함수 역시 인덱스에 사용 가능.

# 숫자 연산
x <- 1
y <- 1.5
x + y 
x - y
x * y
x / y
num_array <- c(10, 20, 30, 40, 50)
num_array + 1 # num_array의 모든 값에 +1 # 벡터 + 스칼라
num_array - 1 # num_array의 모든 값에 -1 #벡터 - 스칼라
num_array * 2 # num_array의 모든 값에 *2 # 벡터 * 스칼라
num_array / 2 # num_array의 모든 값에 /2 # 벡터 / 스칼라

# 스칼라(Scalar) : 1개의 값을 저장하는 변수
# 벡터 (Vector) : 2개 이상의 값을 저장하는 변수
# x, y는 스칼라가, num_array는 벡터가 됨.
# 스칼라와 벡터를 사칙 연산하면, 벡터의 모든 원소에 스칼라 값을 연산함.

# 벡터간의 연산시, 같은 인덱스의 원소들끼리 연산.
number1 <- c(11, 22, 33)
number2 <- c(10, 20, 30)
number1 + number2 
number3 <- c(10, 20)
number4 <- c(10, 20, 30)
number3 + number4 # 실행은 완료 되었으나, 인덱스의 수가 달라 경고메시지 출력.

# 문자열을 1개만 저장하는 변수
name <- '홍길동'
name 
#문자열 여러개를 저장하는 변수
names <- c('aaa', 'bbb', 'ccc')
names
names[1:2]
# 문자열은 사칙연산을 할 수 없다.

# 함수 -> 값을 파라미터에 전달하면, 연산 또는 기능을 수행 후, 결과를 반환.
scores <- c(100, 99, 88, 77, 66)
mean(scores)# mean() : 여러 값들의 평균값 계산
average <- mean(scores) 
max(scores) # 최대값 출력
min(scores) # 최소값 출력

# R 함수의 필수 / 옵션 파라미터
# 필수 파라미터 -> 파리미터의 기본값이 지정 되었지 않아,
# 함수 호츨시, 반드시 값을 전달해야하는 파라미터.
# 옵션 파라미터 -> 파라미터의 기본값이 있어. 함수 호출시, 값을 전달해도 되고,
# 생략해도 되는 ㅠㅏ라미터.

# seq(from : 1, to : 1, by :1) #seq()의 기본값
#seq1() <- seq()
seq1 <- seq() # seq1에는 초기 기본값 1 저장
# seq()함수는 모든 파라미터가 기본값을 가짐. 

