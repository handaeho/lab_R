# Csv 파일에서 데이터 프레임 만들기

# 현재 작업 디렉토리 확인
getwd()

# 현재 작업 디렉토리 변경. setwd("변경할 디렉토리 주소")
setwd("C:/dev/lab-R")

# CSV 파일 형식 불러오기. 
# 데이터프레임이름 <- read.csv("경로/파일이름.csv")
exam_csv <- read.csv("data_excel/csv_exam.csv")
exam_csv

# 합계. sum(데이터프레임이름$컬럼이름)
sum(exam_csv$math)

#평균. mean(데이터프레임이름$컬럼이름)
mean(exam_csv$english)

# 각 학생들의 수학 / 영어 / 과학 점수 총점.
total <- exam_csv$math + exam_csv$english + exam_csv$science
total

# 문자가 들어있는 파일을 읽어올 경우
# 데이터프레임이름 <- read.csv("경로/파일이름.csv", stringAsFactors = F)
exam_csv <- read.csv("data_excel/csv_exam.csv", stringsAsFactors = F)
exam_csv

# 헤더가 없는 csv파일에서 데이터 프레임 생성 
# 데이터프레임이름 <- read.csv("경로/파일이름.csv", header = F)
exam_csv2 <- read.csv("data_excel/csv_exam_nohead.csv", header = F)
exam_csv2

# ','가 아닌 ':'으로 구분된 csv 파일 읽어오기. 
# 데이터프레임이름 <- read.csv("경로/파일이름.csv", sep = ":") [sep = seperater]
exam_csv3 <- read.csv("data_excel/csv_exam2.csv", sep = ":")
exam_csv3

# 데이터 프레임을 CSV 파일로 저장하기. 
# write.csv(데이터프레임이름, file = "파일명.csv")
write.csv(df_midterm, file = "df_midterm.csv")

# RData 파일 활용. R 전용 데이터 파일은 용량이 작고 빠르다. 

# 데이터 프레임을 RData 파일로 저장하기.
# save(데이터프레임이름, file = "파일명.rda")
save(df_midterm, file = "df_midterm.rda")

# RData 불러오기 
# load("파일명.rda")
load("df_midterm.rda")
df_midterm

# 엑셀, CSV 파일은 불러와 새 변수에 할당해서 사용.
# rda 파일은 저장한 파일명과 동일한 데이터 프레임이 자동으로 생성된다.
# 할당없이 바로 사용 가능.

# excel 파일 불러와 df_exam에 할당.
df_exam <- read.excel("excel_exam.xlsx")
# csv 파일 불러와 df_csv_exam에 할당.
df_csv_exam <- read.csv("csv_exam.csv")
# rda파일 불러와 할당 없이 바로 사용. df_midterm이라는 데이터프레임 자동 생성.
load("df_midterm.rda") 
