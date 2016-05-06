require "sequel"

DB=	Sequel.sqlite("SaltyBetBotData.db")

DB.create_table? :Bots do 
	Integer	:ID,		:unique => true
	varchar	:Username
	varchar	:Email,		:unique => true
	varchar	:Password
	varchar	:StrategyName
	varchar	:Description
end

DB.create_table? :Authors do 
	Integer	:ID, :unique => true
	varchar	:Name
end

DB.create_table? :Fighters do 
	Integer		:ID,		:unique => true
	foreign_key	:AuthorID,	:Authors
	varchar		:Name
end

DB.create_table? :MatchTypes do 
	primary_key	:ID
	varchar		:Type
end

DB.create_table? :Tiers do 
	primary_key	:ID
	varchar		:Tier
end

DB.create_table? :Matches do 
	Integer		:ID,			:unique => true
	foreign_key	:TypeID,		:MatchTypes
	foreign_key	:Player1ID,		:Fighters
	foreign_key	:Player2ID,		:Fighters
	foreign_key	:Player1TierID,	:Tiers
	foreign_key	:Player2TierID,	:Tiers
	Integer		:Player1Matches
	Integer		:Player2Matches
	Integer		:Player1WinRate
	Integer		:Player2WinRate
	Integer		:Player1Life
	Integer		:Player2Life
	Integer		:Player1Meter
	Integer		:Player2Meter
	Integer		:Player1Palette
	Integer		:Player2Palette
end

DB.create_table? :Bets do
	primary_key	:ID
	foreign_key	:MatchID,	:Matches
	foreign_key	:BotID,		:Bots
	Integer		:Balance
	Integer		:Wager
	Integer		:BetChoice
	Integer		:Winner
	Boolean		:BetWon
end


# require_relative "class.rb"

class Bot < Sequel::Model(:Bots)
end

class Author < Sequel::Model(:Authors)
end

class Fighter < Sequel::Model(:Fighters)
end

class MatchType < Sequel::Model(:MatchTypes)
end

class Tier < Sequel::Model(:Tiers)
end

class Match < Sequel::Model(:Matches)
end

class Bet < Sequel::Model(:Bets)
end