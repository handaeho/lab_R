# Package
# 여러개의 데어터와 함수가 들어있는것.

# 패키지 설치하기 -> install.package("패키지이름")
install.packages("ggplot2")

# 패키지의 함수 또는 데이터 사용하기 -> 패키지이름::함수 or 데이터
x <- c("a", "b", "c", "d")
x
ggplot2::qplot(x) # 데이터 개수(빈도) 그래프 출력

# 패키지 로드하기 -> library(패키지이름)
# 패키지 로드를 하면 패키지이름을 일일히 붙혀주지 않아도 된다.
library(ggplot2)

qplot(x) # 데이터 개수(빈도) 그래프 출력

search() # 검색 경로(메모리)에 로드된 패키지, 환경 정보등을 확인.

detach("package:ggplot2") # 패키지를 메모리에서 제거.

