#  KBO 타자 OPS 모델링/시각화 

# 2019 KBO타자 성적 예측 대회(상반기)

# Competition URL https://dacon.io/cpt6/

# Host ①데이콘 ②서울대학교 통계연구소 ③수원대 DS&ML 센터 ④한국야구학회 ⑤기타

# Background
# = 2016년 관중수가 800만명을 돌파한 프로야구는, 명실공히 한국 프로스포츠 최고의 인기 종목입니다.
# 프로야구의 인기와 더불어 데이터 분석에 대한 인식이 높아짐에 따라 국내 여러 구단에서 데이터 사이언스 역할의 수요가 늘고 있습니다.
# 특히 야구에서는 특정 선수의 성적 변동성이 해마다 매우 크기 때문에 내년 성적을 예측하기 까다로운 부분이 많습니다.
# 정말 못할 것이라고 생각했던 선수도 막상 내년에는 잘하고, 많은 지표가 리그 상위권이었던 선수가 내년에는 그렇지 않은 경우가 많습니다.
# 본 대회는 야구 데이터로 불확실성 문제를 해결하기 위해 2019년 타자들의 상반기 성적 예측을 목표로 합니다.

# Description
# = 2019년 타자들의 상반기 OPS를 예측하는 모델을 만들어 주세요. 2010년부터 1군 엔트리에 1번 이상 포함 되었던 타자들의 역대 정규시즌,
# 시범경기 성적 정보를 제공합니다(후반기 OPS 예측 대회는 전반기 종료 한 달 전 따로 오픈할 예정입니다)

# 약 350명의 타자들의 시즌별 성적, 생년월일, 몸무게, 키 등의 정보가 제공됩니다.
# * KBO기록실( https://www.koreabaseball.com/Record/Player/HitterBasic/Basic1.aspx )과 같은 법적인 제약이 없는 외부 데이터 사용이 가능합니다.

# 데이터 설명
# [Files]
# ① Regular_Season_Batter.csv : KBO에서 활약한 타자들의 역대 정규시즌 성적을 포함하여 몸무게, 키 ,생년월일 등의 기본정보
# ② Regular_Season_Batter_Day_by_Day.csv: KBO에서 활약한 타자들의 일자 별 정규시즌 성적
# ③ Pre_Season_Batter.csv : KBO에서 활약한 타자들의 역대 시범경기(정규시즌 직전에 여는 연습경기) 성적
# ④ submission.csv : 참가자들이 예측해야 할 타자의 이름과 아이디 목록

# Weighted Root Mean Squared Error(WRSME)
# 선수들의 타수를 가중치로 둔 RMSE입니다.
# 예를 들어 a와 b라는 선수가 각각 62타수, 10타수을 소화하고 ops는 0.809, 0.721을 기록하였다고 가정합시다.
# 근데 만약 어떤 사람이 a는 0.918, b는 0.640의 OPS를 기록할 것이라고 예측했다면 이 예측 공식은 아래와 같습니다.
# WRSME = sqrt(∑((실제값-예측치)^2 * 타수) / ∑타수)