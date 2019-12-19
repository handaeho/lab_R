# 외부 데이터를 이용해보자.
# CSV -> 데이터들을 ','로 구분해 저장한 파일 형식.
# ','로 구분 할 수 있지만 ':' 또는 '공백(tab)'으로 구분하는 경우도 있다.

# MS Excel 파일 (xls, xlsx)을 읽어 데이터프레임 생성 시, 라이브러리 설치 필요.
# 엑셀 파일을 읽어오기 위한 패키지 설치
install.packages("readxl") 
# readxl 패키지를 메모리에 로드
library(readxl) 

# 메모리에 로드된 패키지 확인
search()

# 현재 작업 디렉토리명을 반환. 현재 'C:/dev/lab-R'
getwd() 
# setwd("변경 할 디렉토리 경로") -> 현재 작업 디렉토리 변경
setwd("C:/dev/lab-R")

################################################################################
# 1) 상대 경로(Relative path) = 파일의 위치를 현재 작업 디렉토리부터 시작하는 경로.  
# -> data/csv_exam.csv
# '.'은 현재 디렉토리를, '..'은 상위 디렉토리를 의미함.
# ./data_excel/csv_exam.csv == ../csv_exam.csv

# 2) 절대 경로(Absolute path) = 파일의 위치를 Root 디렉토리부터 시작하는 경로.
# -> C:/dev/lab-R/data_excel/csv_exam.csv
################################################################################

# 엑셀 파일의 경로를 직접 지정해주어 데이터 프레임에 저장.
# 데이터프레임이름 <- read_excel("엑셀파일경로/엑셀파일명.xlsx")
exam_xlsx <- read_excel("data_excel/excel_exam.xlsx") 
exam_xlsx

# 특정 컬럼 정보 출력 
# 데이터프레임이름$컬럼이름
exam_xlsx$math

# 엑셀파일 첫 번째 행이 컬럼(변수)명이 아니라면?
# 데이터프레임이름 <- read_excel("엑셀파일경로/엑셀파일명.xlsx", col_name = F)
exam_novar <- read_excel("data_excel/excel_exam_novar.xlsx", col_names = F) 
exam_novar
# 컬럼이름을 설정하고 싶다면?
# 데이터프레임이름 <- read_excel("엑셀파일경로/엑셀파일명.xlsx", col_name = c("컬럼이름1", "컬럼이름2",...))
exam_novar2 <- read_excel("data_excel/excel_exam_novar.xlsx", col_names = c("id", "cl", "m", "e", "s")) 
exam_novar2

# 엑셀파일에 시트가 여러개일때, 특정 시트에만 원하는 데이터가 있다면?
# 데이터프레임이름 <- read_excel("엑셀파일경로/엑셀파일명.xlsx", sheet = 원하는데이터가있는시트번호)
exam_sheet <- read_excel("data_excel/excel_exam_sheet.xlsx", sheet = 3) 
exam_sheet


