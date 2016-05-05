def salt_generator(url)
	agent = Mechanize.new

	username=	ARGV[0]
	password=	ARGV[1]

	# SIGN IN
	begin
		main_page = signin(url, agent, username, password).submit
	rescue Exception => e
		errorLogging(e)
		return false
	end


	# GET BET STATUS
	begin
		stateJSON = agent.get(url+'/state.json').body #=> {p1nam:'...', p2name:'...', ... status:'...', ...}
	rescue Exception => e
		errorLogging(e)
		return false
	end # DONE: begin...


	status_hsh = JSON.parse(stateJSON)
	bet_status = status_hsh['status'] # Are bets 'open' or 'locked'?

	if(bet_status == 'open')
		# GET FIGHTER NAMES
		p1 = status_hsh['p1name'] # Name of red team
		p2 = status_hsh['p2name'] # Name of blue team

		statsJSON = agent.get(url+'/ajax_get_stats.php').body # Get winrates for both fighters (or teams if it's an exhibition match)
		stats_hsh = JSON.parse(statsJSON)

		p1_winrate = winrate_getter(stats_hsh['p1winrate'])
		p2_winrate = winrate_getter(stats_hsh['p2winrate'])

		# DECIDING WHO TO BET ON 
		selectedplayer = (p1_winrate < p2_winrate) ? 'player1' : 'player2'
		accounts_hsh = {}


		# CURRENT SALT BALANCE AND HOW MUCH TO BET
		curr_salt = main_page.search('#balance')[0].text.gsub(',','').to_i # How much Salt I currently have
		all_in_threshold = 2500
		# wager = (curr_salt<all_in_threshold) ? curr_salt : 
		# 	(curr_salt<50000) ? 2500  : 
		# 	(curr_salt<100000) ? 3500 : 
		# 	(curr_salt<1000000) ? 5000 :
		# 	(curr_salt<5000000) ? 7500 :
		# 	(curr_salt<10000000) ? 10000 :
		# 	(curr_salt<20000000) ? 15000 :
		# 	20000
		wager = curr_salt*0.01
		wager = wager.round

		# PREAMBLE TO THE BET
		p "Signed in as #{ARGV[0]}",
		"Bets are '#{bet_status}'",
		"Current balance: $#{curr_salt}",
		"Player 1: '#{p1}' with win ratio of #{p1_winrate}",
		"Player 2: '#{p2}' with win ratio of #{p2_winrate}",
		"BOT WILL BET $#{wager} ON #{selectedplayer}...",
		'==='

		# PLACE THE BET AND PRINT CONFIRMATION
		begin
			agent.post(
				url+'/ajax_place_bet.php',
				{
					'radio'=>'on',
					'selectedplayer'=>selectedplayer,
					'wager'=>wager.to_s
				}
			)		
		rescue Exception => e
			errorLogging(e)
			return false
		end # DONE: begin...

		p "BET COMPLETED AT #{Time.now}!"
		sleep 60



		# GET BET STATUS
		begin
			stateJSON = agent.get(url+'/state.json').body #=> {p1nam:'...', p2name:'...', ... status:'...', ...}
		rescue Exception => e
			errorLogging(e)
			return false
		end # DONE: begin...

		
		main_page = agent.get(url)
		p "=================================================="
		salt_generator(url) # Recursive method...the script checks the bets again and again...
	else
		p "BETS ARE LOCKED! THE TIME IS #{Time.now}. RE-CHECKING BET STATUS IN 30 SECONDS..."
		sleep 30


		# GET BET STATUS
		begin
			stateJSON = agent.get(url+'/state.json').body #=> {p1nam:'...', p2name:'...', ... status:'...', ...}
		rescue Exception => e
			errorLogging(e)
			return false
		end # DONE: begin...

		
		main_page = agent.get(url)
		p "=========================="
		begin
			salt_generator(url) # Recursive method...the script checks the bets again and again...
		rescue Exception => e
			errorLogging(e)
			return false
		end
		
	end	# DONE: if(bet_status == 'open')	
end # DONE: def salt_generator(stateJSON)

def signin(main_url, mech_agent, email, pass)
	signin = '/authenticate?signin=1'
	form_url = main_url+signin

	begin
		signin_form = mech_agent.get(form_url).forms[0]
	rescue Exception => e
		errorLogging(e)
		return false
	end

	signin_form['authenticate'] = 'signin'
	signin_form['email'] = email
	signin_form['pword'] = pass
	return signin_form
end

def winrate_getter(winrate_str)
	if(winrate_str.include?('/'))
		winrate_arr = winrate_str.split('/')
		w1 = winrate_arr[0].to_f
		w2 = winrate_arr[1].to_f
		return (w1+w2)/2
	else
		return winrate_str.to_f
	end			
end

def errorLogging(e)
	p "ERROR: #{e}"
	puts e.backtrace

	errorLog = 'ERRORS.txt'

	if(File.exist?(errorLog)===false)
		File.open(errorLog,'w')
	end

	File.open(errorLog,'a'){|f|
		[
			'====================',
			Time.now,
			e,
			e.backtrace
		].each{|err| 
			f.puts(err)
		}
	}
end
