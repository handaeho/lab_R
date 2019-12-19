# 필요 패키지 리스트 구성
list_of_packages = c("Lahman", "ggplot2", "tidyverse", "ggthemes", "extrafont",
                         "tibble", "rvest", "stringr", "extrafont")

# 해당 라이브러리 및 종속 패키지 모두 설치
new_packages = list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]

if(length(new_packages)) install.packages(new_packages)

# library vs. require
# library() 명령어로 패키지를 불러올 때 패키지가 없으면 오류가 나지만, require는 패키지가 없어도 그냥 무시한다는 차이가 있다.

# sapply() : lapply()는 리스트를 반환. but, sapply()는 벡터를 반환. 

# 여러 패키지 한번에 불러오기
sapply(list_of_packages, require, character.only = TRUE)

# 1. MLB 베타분포 ------------------------------------

# 투수 제외하고 타율 계산  
# H : 안타 / AB : 타석
career = Batting %>%
  dplyr::filter(AB > 0) %>%
  anti_join(Pitching, by = "playerID") %>%
  group_by(playerID) %>%
  dplyr::summarize(H = sum(H), AB = sum(AB)) %>% 
  mutate(average = H / AB)

# 성과 이름을 붙여 가독성 높임.
career = Master %>%
  tbl_df() %>%
  dplyr::select(playerID, nameFirst, nameLast) %>%
  unite(name, nameFirst, nameLast, sep = " ") %>%
  inner_join(career, by = "playerID") %>%
  dplyr::select(-playerID)

# 타석이 500석 이상 선수만 추려냄. 
career_filtered = career %>%
  filter(AB >= 500)

m <- MASS::fitdistr(career_filtered$average, dbeta,
                    start = list(shape1 = 1, shape2 = 10))

alpha0 <- m$estimate[1]
beta0 <- m$estimate[2]

career_filtered %>%
  dplyr::filter(AB > 500) %>%
  ggplot() +
  geom_histogram(aes(average, y = ..density..), binwidth = .005, color="darkgray", fill="gray") +
  stat_function(fun = function(x) dbeta(x, alpha0, beta0), color = "red",
                size = 1) +
  theme_bw(base_family="NanumGothic") +
  labs(x="타율", y="밀도(Density")

# 2. 2017년 KBO리그 ------------------------------------

## 2.1. KBO 통계(6/28일) -------------------------------
kbo_career = "data/kbo.csv"
kbo_html <- xml2::read_html(kbo_url)

Sys.setlocale("LC_ALL", "English")

kbo_hitter_tbl <- rvest::html_nodes(x=kbo_html, xpath='//*[@id="table1"]')
kbo_hitter <- rvest::html_table(kbo_hitter_tbl)[[1]]
Sys.setlocale("LC_ALL", "Korean")

# 3. KBO 경험적 베이즈(Empirical Bayes) (6/28일) -------------------------------
kbo_hitter_eb <- kbo_hitter %>% 
  dplyr::select(`선수 (팀)`, 타수, 안타, 타율) %>% 
  add_row(`선수 (팀)` = "강지광 (넥센)", 타수 = 2, 안타 = 0, 타율 =0) %>% 
  add_row(`선수 (팀)` = "노경은 (롯데)", 타수 = 2, 안타 = 0, 타율 =0) %>% 
  add_row(`선수 (팀)` = "최경철 (삼성)", 타수 = 1, 안타 = 1, 타율 =1) %>%
  add_row(`선수 (팀)` = "이성곤 (두산)", 타수 = 3, 안타 = 1, 타율 =0.333) %>% 
  mutate(베이즈_타율 = round((안타 + alpha0) / (타수 + alpha0 + beta0), 3))

kbo_hitter_eb  %>% 
  dplyr::arrange(타수) %>% DT::datatable()

prior_g <- kbo_hitter_eb %>% 
  dplyr::select(`선수 (팀)`, 타율) %>% 
  ggplot() +
  geom_histogram(aes(타율, y = ..density..), binwidth = .01, color="darkgray", fill="gray", alpha=0.3) +
  theme_bw(base_family="NanumGothic") +
  labs(x="타율", y="밀도(Density")

## 3.2. KBO 베이즈 타율 시각화 (6/28일) -------------------------------

posterior_g <- kbo_hitter_eb %>% 
  dplyr::select(`선수 (팀)`, 타율, 베이즈_타율) %>% 
  gather(구분, 타율,  -`선수 (팀)`) %>% 
  ggplot() +
  geom_histogram(aes(타율, y = ..density.., fill=구분), binwidth = .005, alpha=0.3) +
  theme_bw(base_family="NanumGothic") +
  stat_function(fun = function(x) dbeta(x, alpha0, beta0), color = "red", size = 1) +
  scale_x_continuous(limits=c(0.2, 0.40)) +
  labs(x="타율", y="밀도(Density") +
  theme(legend.position = "top")

gridExtra::grid.arrange(prior_g, posterior_g,  nrow=1)