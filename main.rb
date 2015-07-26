require_relative "src/tic-tac-toe"
require_relative "src/connect4"
require_relative "src/hangman"
require_relative "src/mastermind"
require_relative "src/chess"
require_relative "src/menu"

tic_tac_toe = TicTacToe.new
connect4 =    Connect4.new
mastermind =  MasterMind.new
hangman =     Hangman.new
chess =       Chess.new
menu = Menu.new("Play Games")
menu << ["TicTacToe", \
		 "Connect2", \
		 "Mastermind", \
		 "Hangman", \
		 "Chess"]
