# SaltyBetUpset
SaltyBetUpset is a Ruby-powered bot that places bets on [SaltyBet](http://saltybet.com), where players bet fake money on fights between video game characters. This bot checks the win-rates for both fighters and bets on the fighter with the lower winrate -- betting upset.

## How to use
SaltyBetUpset takes two parameters: email and password. Open `launcher.cmd` in a text editor and replace "EMAIL" and "PASSWORD" with your SaltyBet login email and password. Or open the command prompt and run `ruby AlwaysBetUpset.rb EMAIL PASSWORD`.

## Forking guidelines
Just do it. 

## Dependencies
- [Mechanize](https://github.com/sparklemotion/mechanize)
- JSON
-- Ruby Devkit, since this bot uses the `JSON` gem. Get the devkit from [RubyInstaller.org](http://rubyinstaller.org/downloads/).

## Compatibility
SaltyBetUpset was made in Ruby v1.9.3 and hasn't been tested in other versions of Ruby.

## Contact
- Twitter: [@ChrisMPersaud](http://twitter.com/ChrisMPersaud)