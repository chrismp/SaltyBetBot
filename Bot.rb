[
	"rubygems",
	"open-uri",
	"mechanize",
	"json"
].each{|g| 
	require g
}

email=						ARGV[0]
password=					ARGV[1]
agent=						Mechanize.new

baseURL=					"http://www.saltybet.com"

signin=						"/authenticate?signin=1"
formURL=					baseURL+signin
signInForm=					agent.get(formURL).forms[0]
signInForm["authenticate"]=	"signin"
signInForm["email"]=		email
signInForm["pword"]=		pass
signInForm.submit

while true
	# GET BET STATUS
	MatchStateURL=	baseURL+"/state.json"
	stateJSON=		agent.get(MatchStateURL).body # JSON containing some info about current match: fighter names, matches remaining in game mode, etc.
	statusHash=		JSON.parse(stateJSON)
	betStatus=		statusHash["status"] # Are bets "open" or "locked"?

	if(betStatus==="open")
		# GET FIGHTER NAMES
		p1name=	statusHash["p1name"] # Name of red player/team
		p2name=	statusHash["p2name"] # Name of blue player/team

		playerStatusURL=	baseURL+"/ajax_get_stats.php"
		statsJSON=			agent.get().body
		statsHash=			JSON.parse(statsJSON)

		p1winrate=	winrate_getter(statsHash["p1winrate"])
		p2winrate=	winrate_getter(statsHash["p2winrate"])

		# DECIDING WHO TO BET ON 
		selectedplayer=	(p1winrate < p2winrate) ? "player1" : "player2"

		# CURRENT SALT BALANCE AND HOW MUCH TO BET
		mainPage=		agent.get(baseURL)
		balance=		mainPage.search("#balance")[0].text.gsub(",","").to_i # How much Salt I currently have
		allInThreshold=	ARGV[2].to_i
		wager=			balance<allInThreshold ? balance : (balance*0.01).round

		# PLACE BET
		agent.post(
			baseURL+"/ajax_place_bet.php",
			{
				"radio"=>"on",
				"selectedplayer"=>selectedplayer,
				"wager"=>wager.to_s
			}
		)
	end	# DONE: if(betStatus == "open")	

	sleep 30
end