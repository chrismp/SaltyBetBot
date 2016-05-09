[
	"rubygems",
	"open-uri",
	"mechanize",
	"json"
].each{|g| 
	require g
}

# require_relative "Model/db.rb"

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

p "Signed in as #{email}"

while true
	# GET BET STATUS
	MatchStateURL||=baseURL+"/state.json"
	stateJSON=		agent.get(MatchStateURL).body	# JSON containing some info about current match: fighter names, matches remaining in game mode, etc.
	stateHash=		JSON.parse(stateJSON)
	betStatus=		stateHash["status"]			# Are bets "open" or "locked"?
	if betStatus==="open"
		# GET FIGHTER NAMES, also for Fighter class
		p1name=	stateHash["p1name"]	# Name of red player/team
		p2name=	stateHash["p2name"]	# Name of blue player/team
		if p1name.include?('/')===false && p2name.include?('/')===false	# If either plauyer name has a forward-slash, that means it's a two-fighter team. Don't bet.
			playerStatsURL=	baseURL+"/ajax_get_stats.php"
			statsJSON=		agent.get(playerStatsURL).body
			if statsJSON!=''
				statsHash=		JSON.parse(statsJSON)
				
				# For MatchType class
				remaining=	stateHash["remaining"]
				if remaining.include?"until the next tournament!"
					matchTypeID=	1
				end

				# For Author class
				p1author=	statsHash["p1author"]
				p2author=	statsHash["p2author"]

				# For Matches class
				p1totalmatches=	statsHash["p1totalmatches"]
				p2totalmatches=	statsHash["p2totalmatches"]
				p1winrate=		statsHash["p1winrate"]
				p2winrate=		statsHash["p2winrate"]
				p1life=			statsHash["p1life"]
				p2life=			statsHash["p2life"]
				p1meter=		statsHash["p1meter"]
				p2meter=		statsHash["p2meter"]
				p1palette=		statsHash["p1palette"]

				p "#{p1name} win rate: #{p1winrate}%. #{p2name} win rate: #{p2winrate}%."
			end

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
			balanceString=	mainPage.search("#balance")[0].text.gsub(",","")
			balance=		balanceString.to_i # How much Salt I currently have
			allInThreshold=	ARGV[3].to_i
			wagerString=	''
			(balanceString.length-1).times do |x|
				digit=	x===0 ? '1' : '0'
				wagerString << digit
			end
			wager=			balance<allInThreshold ? balance : wagerString.to_i

			# For Bet class
			betChoice=	selectedplayer===p1Pick ? 1 : 2

			# PLACE BET
			agent.post(
				baseURL+"/ajax_place_bet.php",
				{
					"radio"=>			"on",
					"selectedplayer"=>	selectedplayer,
					"wager"=>			wager
				}
			)

			p "#{p1name} vs. #{p2name}.",
			"Balance: $#{balance}.",
			"Bet $#{wager} on #{selectedplayer} at #{Time.now}.",
			"==="
			sleep 60
		end
	end	# DONE: if betStatus == "open"
	p "Bets closed at #{Time.now}"
	sleep 30
end
