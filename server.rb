require 'sinatra'
require 'csv'


def import_csv(filename)
  data = []
  CSV.foreach(filename, headers:true) do |row|
    data << row.to_hash
  end
  data
end

def count_results(league)
  wins = {}
  losses = {}
  #set all losses and wins to 0, initialize values
  league.each do |game|
    wins[game["home_team"]]=0
    wins[game["away_team"]]=0
    losses[game["home_team"]]=0
    losses[game["away_team"]]=0
  end
  #count losses and wins
  league.each do |game|
    if game["home_score"].to_i > game["away_score"].to_i
      wins[game["home_team"]] += 1
      losses[game["away_team"]] += 1
      else
      wins[game["away_team"]] += 1
      losses[game["home_team"]] += 1
      end
    end

  # wins = {"Patriots"=>3, "Broncos"=>1, "Colts"=>0, "Steelers"=>0}
  # losses = {"Patriots"=>0, "Broncos"=>1, "Colts"=>2, "Steelers"=>1}
  results=[]

  results << wins
  results << losses
  results
end

def sort(results)

  team = []
  sort = []

  wins = results[0]
  losses = results[1]

  wins.keys.each do |key|
    team = [key]
    sort << team
  #sort = [[Patriots],[Broncos],[Colts],[Steelers]]
  end

  #sort = [[Patriots, 3], [Bronocs, 1]..]
  sort.each do |array|
    array << wins[array[0]]
  end

  sort.each do |array|
    array << losses[array[0]]
  end

  #sort the result by wins, losses, the team names(if they have same w/l)
  result = sort.sort_by{|v1, v2, v3| [-v2, v3, v1]}
end

get '/leaderboard' do
  @all_games = import_csv('NFL.csv')
  @win_loss = count_results(@all_games)
  @results = sort(@win_loss)
  erb :index
end


get '/leaderboard/:team' do
  @team = params[:team]

  @all_games = import_csv('NFL.csv')

  #game info
  # win_loss=[{"Patriots"=>3, "Broncos"=>1, "Colts"=>0, "Steelers"=>0},
  # {"Patriots"=>0, "Broncos"=>1, "Colts"=>2, "Steelers"=>1}]
  win_loss = count_results(@all_games)
  win = win_loss[0]
  @team_win = win[@team]

  loss = win_loss[1]
  @team_loss = loss[@team]

  erb :team
end









