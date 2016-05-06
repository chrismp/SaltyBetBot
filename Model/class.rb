class Bot < Sequel::Model(:Bots)
	# one_to_many :Bot_Bets, :class=>:Bet, :key=>:BotID
end

class Author < Sequel::Model(:Authors)
	# one_to_many :Fighters
end

class Fighter < Sequel::Model(:Fighters)
	# many_to_one :Authors
end

class MatchType < Sequel::Model(:MatchTypes)
	# one_to_many :Matches
end

class Tier < Sequel::Model(:Tiers)
	# one_to_many :Matches
end

class Match < Sequel::Model(:Matches)
	# one_to_many :Bets
	# many_to_one :MatchTypes
	# many_to_one :Fighters
	# many_to_one :Tiers
end

class Bet < Sequel::Model(:Bets)
	# many_to_one :Matches
	# many_to_one :Bot, :class=>:Bot
end