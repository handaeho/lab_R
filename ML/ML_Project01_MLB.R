# Lahman 데이터를 이용한 야구 데이터 분석

# 야구는 '기록의 스포츠'. 어떠한 스포츠 종목보다 많은 데이터와 경우의 수, 전략적 분석이 필요한 종목.
# 특정 선수가 특별히 강한 구장, 상황, 특정 구단 상대시 강했던 선수, 약했던 선수, 타선 구성과 타격 능력 또는 구종과 구속 등에 따른 작전 등 수 많은 분석이 필요하다.
# 특히 현대 야구에서는 과거처럼 감독과 코치진의 경험과 직감에 의존 하는것이 아닌, 구단 차원에서 구축된 데이터를 기반으로 수비 위치 시프트, 타자 및 투수 교체등 더욱 그 중요도가 높아지고 있다.

# Lahman(Sean Lahman). 
# = 현재 USA Today Network와 Rochester Democrat 및 Chronicle의 기자이며 데이터베이스 저널리즘, 데이터 마이닝 및 오픈 소스 데이터베이스 연구원.

# Lahman은 'R documentation'에서 1871년 ~ 2016년까지 MLB의 각종 데이터를 csv 파일로 구축, 제공함.

# https://www.rdocumentation.org/packages/Lahman에서 다운로드 가능.

# ===========================================================================================================

# 데이터 준비 & 확인
teams = read.csv("data/baseballdatabank-2017.1/baseballdatabank-2017.1/core/Teams.csv")
str(teams)
names(teams)
# [1] "yearID"         "lgID"           "teamID"         "franchID"       "divID"          "Rank"          
# [7] "G"              "Ghome"          "W"              "L"              "DivWin"         "WCWin"         
# [13] "LgWin"          "WSWin"          "R"              "AB"             "H"              "X2B"           
# [19] "X3B"            "HR"             "BB"             "SO"             "SB"             "CS"            
# [25] "HBP"            "SF"             "RA"             "ER"             "ERA"            "CG"            
# [31] "SHO"            "SV"             "IPouts"         "HA"             "HRA"            "BBA"           
# [37] "SOA"            "E"              "DP"             "FP"             "name"           "park"          
# [43] "attendance"     "BPF"            "PPF"            "teamIDBR"       "teamIDlahman45" "teamIDretro"   

# -----------------------------------------------------------------------------------------------------------

# Q1. 각 10년 단위로 경기 당 평균 홈런 수

# 10년 단위로 데이터 분리(yearID --- 경기 년도)
min(teams$yearID) # 1871
max(teams$yearID) # 2016

# 해당 년도 mod 연대(1870년대, 1880년대, ..., 2000년대, 2010년대) = 0~9에 속하면 그 연대인것.
seq_range = seq(from = 1870, to = 2010, by = 10)
seq_range # 1870 1880 1890 1900 1910 1920 1930 1940 1950 1960 1970 1980 1990 2000 2010
for(i in seq_range){
  decade = teams$yearID %% i
  sub_teams = subset(teams,(0 <= decade) & (decade <= 9))
}
sub_teams # 연대 별로 분리된 데이터 집합

# decade당 열린 경기 수
# teams$G : 해당 팀이 치른 총 경기 수 / teams$Ghome : 해당팀이 치른 홈 경기수 / teams$hr : 홈런 수
# 연대 별 홈런 수 데이터 프레임
avg_hr_decade = data.frame(matrix(ncol = 2, nrow = 1))
names(avg_hr_decade) = c("decade", "hr")
avg_hr_decade 
#   decade hr
# 1     NA NA

# avg_hr_decade에 각 연도별 홈런수 저장
rowIndex = 0 # avg_hr_decade 데이터 프레임에 1번부터 저장하기 위한 변수

for(i in seq_range){
  decade = teams$yearID %% i
  sub_teams = subset(teams, (0 <= decade) & (decade <= 9))
  num_games = sum(sub_teams$G) / 2 # 이때 경기수를 2로 나누는 이유는 A팀과 B팀의 대결시, 기록지에는 같은 경기가 각각 A vs B / B vs A로 들어간다. 따라서 2로 나눔.
  num_hr = sum(sub_teams$HR)
  avg_hr = num_hr / num_games
  
  rowIndex = rowIndex + 1 # row가 1씩 증가
  avg_hr_decade[rowIndex, ] = c(i, avg_hr) # avg_hr_decade 데이터 프레임에 1번부터 평균 홈런 수 저장
}

avg_hr_decade
#    decade        hr
# 1    1870 0.1782373
# 2    1880 0.4308711
# 3    1890 0.5028022
# 4    1900 0.2737213
# 5    1910 0.3402131
# 6    1920 0.8028889
# 7    1930 1.0918691
# 8    1940 1.0470265
# 9    1950 1.6857928
# 10   1960 1.6395589
# 11   1970 1.4916187
# 12   1980 1.6198063
# 13   1990 1.9148375
# 14   2000 2.1468033
# 15   2010 1.9677192

# 경기당 평균 홈런 수 시각화
install.packages("plotly")
library(plotly)

plotly_avg_hr_decade = plot_ly(data = avg_hr_decade,
                               x = ~decade,
                               y = ~hr,
                               type = 'scatter',
                               mode = 'lines+markers',
                               line = list(color = "blue", width = 3)) %>% 
  layout(title = "Average Home Runs Per each Decade Game",
         xaxis = list(title = "Decade"),
         yaxis = list(title = "Average Home Runs"))

print(plotly_avg_hr_decade)

# -----------------------------------------------------------------------------------------------------------

# Q2. 각 10년 단위로 보았을 때 삼진 수와 홈런 수 상관관계

# 홈런 타자일수록 삼진 개수가 많다는 것은 야구계의 상식. 과연 이 상식은 정말일까?

# 홈런과 삼진 데이터 프레임 생성
strike_hr_decade = data.frame(matrix(ncol = 3, nrow = 1))
names(strike_hr_decade) = c("decade", "hr", "StrikeOut")
strike_hr_decade
#   decade hr StrikeOut
# 1     NA NA        NA

# 삼진 수(teams$so) 확인
teams$SO # 현재 NA값 존재.

# 연대 별 삼진 개수 중, NA가 아닌 것들만 저장 하기 위해 complete.cases() 이용
# complete cases() 
# = 행에 누락된 데이터가 없는(NA가 존재하지 않는)지를 확인해주는 함수 .
# 해당 행 전체에 누락된 데이터가 없다면 TRUE값을 반환하고 누락된 데이터가 존재한다면 FALSE를 반환.
real = stats::complete.cases(sub_teams$SO)
head(real) # TRUE TRUE TRUE TRUE TRUE TRUE

real_set = sub_teams[real, ]
head(real_set$SO) # 1529 1140 1056 1140 922 1236 (연대 별 총 삼진 수)

# 연대 별 경기당 삼진 수 & 경기당 홈런 수 계산 후, 저장. 방법은 Q1과 같음. 
rowIndex = 0

for(i in seq_range) {
  decade = teams$yearID %% i
  sub_teams = base:: subset(teams, (0 <= decade) & (decade <= 9))
  
  complete_set = sub_teams[stats::complete.cases(sub_teams$HR),]
  num_games = base::sum(complete_set$G) / 2
  num_hrs = base::sum(complete_set$HR)
  avg_hrs = num_hrs / num_games
  
  complete_set = sub_teams[stats::complete.cases(sub_teams$SO),]
  num_games = base::sum(complete_set$G) / 2
  num_sos = base::sum(complete_set$SO)
  avg_sos = num_sos / num_games
  
  rowIndex = rowIndex + 1
  strike_hr_decade[rowIndex,] = base::c(i, avg_hrs, avg_sos)
}

print(strike_hr_decade)
#    decade        hr StrikeOut
# 1    1870 0.1782373  2.415559
# 2    1880 0.4308711  7.364083
# 3    1890 0.5028022  5.289310
# 4    1900 0.2737213  6.426271
# 5    1910 0.3402131  7.259356
# 6    1920 0.8028889  5.629554
# 7    1930 1.0918691  6.634311
# 8    1940 1.0470265  7.100275
# 9    1950 1.6857928  8.797721
# 10   1960 1.6395589 11.430236
# 11   1970 1.4916187 10.286832
# 12   1980 1.6198063 10.726607
# 13   1990 1.9148375 12.296888
# 14   2000 2.1468033 13.121979
# 15   2010 1.9677192 15.040807

# 연대 별 경기당 홈런데 대한 삼진 수 시각화
plotly_strike_hr_decade = plot_ly(data = strike_hr_decade,
                               x = ~decade,
                               y = ~hr,
                               name = "Average Home Runs per Games",
                               type = "scatter",
                               mode = "lines+markers",
                               line = list(color = "red", width = 3)) %>% 
  add_trace(y = ~StrikeOut,
            name = "Average Strike Out per Games",
            line = list(color = "yellow", width = 5)) %>% 
  layout(title = "Average Home Runs & Strike Out Per each Decade Game",
         xaxis = list(title = "Decade"),
         yaxis = list(title = "Average Home Runs & Strike Out"))

print(plotly_strike_hr_decade)

# 그럼 홈런과 삼진의 상관 관계는?
stats::cor(x = strike_hr_decade[ ,2:3])
#                  hr StrikeOut
# hr        1.0000000 0.8873489
# StrikeOut 0.8873489 1.0000000 ~~~~~> 꽤 높다!

# -----------------------------------------------------------------------------------------------------------

# Q3. American League의 지명타자 제도 도입으로 양 리그(National League와 American League) 간 득점의 차이가 생겼을까?
# 현재 American League(AL)은 투수 대신 타격만 하는 '지명타자'제도를 시행 중(1901년 도입). National League(NL)은 지명타자 없이 투수가 타격도 수행.

# 1901년 이후 AL / NL 경기수 및 득점 데이터 프레임(lgID = 리그 이름)
df_league = data.frame(matrix(ncol = 8, nrow = 1)) 
names(df_league) = c("year", "NL_GAMES", "NL_SCORES", "NL_AVG_SCORES", "AL_GAMES", "AL_SCORES", "AL_AVG_SCORES", "DIFF")
df_league
#   year NL_GAMES NL_SCORES NL_AVG_SCORES AL_GAMES AL_SCORES AL_AVG_SCORES DIFF
# 1   NA       NA        NA            NA       NA        NA            NA   NA

# 각 해마다 NL & AL 리그별 총 경기수, 총 득점, 경기당 평균 득점, 평균 득점 차를 구하고 저장
rowIndex = 0

for(year in min(teams$yearID) : max(teams$yearID)){
  nl = subset(teams, subset = ((yearID == year) & (lgID == "NL")));
  al = subset(teams, subset = ((yearID == year) & (lgID == "AL")));
  
  if((nrow(nl) > 0) & (nrow(al) > 0)){
    nl_games = sum(nl$G) / 2;
    al_games = sum(al$G) / 2;
    
    nl_scores = sum(nl$R);
    al_scores = sum(al$R);
    
    nl_avg_scores = nl_scores / nl_games;
    al_avg_scores = al_scores / al_games;
    
    diff = al_avg_scores - nl_avg_scores;
    
    rowIndex = rowIndex + 1;
    df_league[rowIndex, ] = c(year, nl_games, nl_scores, nl_avg_scores, al_games, al_scores, al_avg_scores, diff);
  }
}
head(df_league)
#   year NL_GAMES NL_SCORES NL_AVG_SCORES AL_GAMES AL_SCORES AL_AVG_SCORES       DIFF
# 1   NA       NA        NA            NA       NA        NA            NA         NA
# 2   NA       NA        NA            NA       NA        NA            NA         NA ~~~> 지명타자는 1901년부터 실시.
# 3 1901      561      5194      9.258467      549      5874     10.699454  1.4409865
# 4 1902      562      4476      7.964413      553      5407      9.777577  1.8131640
# 5 1903      560      5349      9.551786      554      4543      8.200361 -1.3514247
# 6 1904      623      4874      7.823435      626      4433      7.081470 -0.7419653

# 각 해마다 리그 별 평균 득점 시각화
plotly_lg_avg_scores = plot_ly(data = df_league,
                                  x = ~year,
                                  y = ~NL_AVG_SCORES,
                                  name = "NL_AVG_SCORES",
                                  type = "scatter",
                                  mode = "lines+markers",
                                  line = list(color = "red", width = 3)) %>% 
  add_trace(y = ~AL_AVG_SCORES,
            name = "AL_AVG_SCORES",
            line = list(color = "blue", width = 5)) %>% 
  layout(title = "Average Scores for Year",
         xaxis = list(title = "Year"),
         yaxis = list(title = "Average Scores for Each League"))

print(plotly_lg_avg_scores)

# 각 해마다 리그 간 득점 차이 시각화
plotly_lg_scores_diff = plot_ly(data = df_league,
                                x = ~year,
                                y = ~DIFF,
                                name = "DIFF",
                                type = "scatter",
                                mode = "lines+makers",
                                line = list(color = "green", width = 3)) %>% 
  layout(title = "Difference of Average Scores Between AL and NL",
         xaxis = list("Year"),
         yaxis = list("Difference of Average Scores"))
print(plotly_lg_scores_diff)

# -----------------------------------------------------------------------------------------------------------

# Q4. MLB 전체에서 투수의 완투비율은 어떻게 변화되어 왔는가?
# 완투 : 선발투수가 9이닝까지 교체없이 경기를 끝내는 것.(teams$cg ---> complete games)

# 각 해마다 경기 수, 완투 횟수, 완투 비율 데이터 프레임 
df_cg = data.frame(matrix(ncol = 4, nrow = 1))
names(df_cg) = c("year", "GAMES", "CG", "CG_RATE")
df_cg
#   year GAMES CG CG_RATE
# 1   NA    NA NA      NA

# 각 해마다 경기수, 완투 횟수, 완투 비율을 구하고 데이터 프레임에 저장
seq_years = seq(from = min(teams$yearID), to = max(teams$yearID))

rowIndex = 0

for(i in seq_years){
  sub_teams = subset(teams, yearID == i)
  num_games = sum(sub_teams$G) / 2
  num_cg = sum(sub_teams$CG) / 2
  rate_cg = (num_cg / num_games) *100
  
  rowIndex = rowIndex + 1
  df_cg[rowIndex, ] = c(i, num_games, num_cg, rate_cg)
}
head(df_cg)
#   year GAMES    CG   CG_RATE
# 1 2010  2430  82.5  3.395062
# 2 1871   127 115.5 90.944882
# 3 1872   183 164.5 89.890710
# 4 1873   199 182.0 91.457286
# 5 1874   232 220.0 94.827586
# 6 1875   345 310.5 90.000000

# 각 해마다 완투 비율 시각화
plotly_rate_cg = plot_ly(data = df_cg,
                                x = ~year,
                                y = ~CG_RATE,
                                type = "scatter",
                                mode = "lines+makers",
                                line = list(color = "black", width = 3)) %>% 
  layout(title = "Rate of Complete Games of Each Year",
         xaxis = list("Year"),
         yaxis = list("Rate of Complete Games"))
print(plotly_rate_cg)

# -----------------------------------------------------------------------------------------------------------

# Q5. 선수들의 연봉이 높은 구단일수록 더 잘할까? 우승 횟수에 따른 선수단 총 연봉 차이
# 현대 메이져리그는 '사치세' 제도를 도입하여, 총 연봉이 일정 수준 이상을 넘으면 벌금을 부과해, 자본금에 따른 구단 사이의 차이를 메꾼다.
# 그렇다면 정말 돈을 많이 주면 더 잘할까?

# 팀별 승리 횟수가 들어있는 teams.csv와 연봉이 들어있는 Salaries.csv를 합치기


# 팀별 연봉과 승리 횟수 데이터 프레임(승리 = teams$W, 연봉 = salaries$salary)
df_money_win = data.frame(matrix(ncol = 3, nrow = 1))
names(df_money_win) = c("team_name", "SALARY", "WIN")
df_money_win
#   team_name SALARY WIN
# 1        NA     NA  NA

# 팀별 연봉과 승리횟수를 구해 데이터 프레임에 저장
