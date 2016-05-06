[
	"rubygems",
	"open-uri",
	"mechanize",
	"json"
].each{|g| 
	require g
}

require_relative "Models/db.rb"

email=						ARGV[0]
password=					ARGV[1]
agent=						Mechanize.new

baseURL=					"http://www.saltybet.com"

signin=						"/authenticate?signin=1"
formURL=					baseURL+signin
signInForm=					agent.get(formURL).forms[0]
signInForm["authenticate"]=	"signin"
signInForm["email"]=		email
signInForm["pword"]=		password
signInForm.submit

while true
	# GET BET STATUS
	MatchStateURL ||=	baseURL+"/state.json"
	stateJSON=		agent.get(MatchStateURL).body # JSON containing some info about current match: fighter names, matches remaining in game mode, etc.
	statusHash=		JSON.parse(stateJSON)
	betStatus=		statusHash["status"] # Are bets "open" or "locked"?

	if betStatus==="open"
		# GET FIGHTER NAMES
		p1name=	statusHash["p1name"] # Name of red player/team
		p2name=	statusHash["p2name"] # Name of blue player/team

		playerStatsURL=	baseURL+"/ajax_get_stats.php"
		statsJSON=		agent.get(playerStatsURL).body
		statsHash=		JSON.parse(statsJSON)


		# DECIDING WHO TO BET ON 
		botStrategy=ARGV[2].to_i
		p1Pick=		"player1"
		p2Pick=		"player2"
		if botStrategy===0		# Coin flip
			selectedplayer=	rand(1..2)===1 ? p1Pick : p2Pick
		elsif botStrategy===1	# Always bet higher winrate
			selectedplayer=	(p1winrate > p2winrate) ? p1Pick : p2Pick
		elsif botStrategy===2	# Always bet lower winrate
			selectedplayer=	(p1winrate < p2winrate) ? p1Pick : p2Pick
		end

		# CURRENT SALT BALANCE AND HOW MUCH TO BET
		mainPage=		agent.get(baseURL)
		balance=		mainPage.search("#balance")[0].text.gsub(",","").to_i # How much Salt I currently have
		allInThreshold=	ARGV[3].to_i
		wager=			balance<allInThreshold ? balance : (balance*0.01).round

		# PLACE BET
		agent.post(
			baseURL+"/ajax_place_bet.php",
			{
				"radio"=>			"on",
				"selectedplayer"=>	selectedplayer,
				"wager"=>			wager
			}
		)
	end	# DONE: if betStatus == "open"

	sleep 30
end