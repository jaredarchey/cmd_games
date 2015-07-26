require_relative "spec_helper"

describe Hangman do 
	before :all do
		@h = Hangman.new
	end
	describe "#initialize" do 

		it "should have a word length range between 2 and 5" do 
			expect(@h.length).to eq([2,5])
		end

		it "should have a word" do 
			expect(@h.word.length.between?(*@h.length)).to be true
		end

		it "should have empty guess history" do 
			expect(@h.guess_history).to eq([])
		end

		it "should have 0 incorrect" do 
			expect(@h.incorrect).to eq(0)
		end

		it "should have a menu title hangman" do 
			expect(@h.main_menu.title).to eq(@h.class.to_s)
		end

		it "should have nil winner" do
			expect(@h.winner).to be nil
		end
	end

	describe "#adjust_min_length" do 

		it "should not be less than 2" do 
			expect(@h.length[0]).to eq(2)
			@h.adjust_min_length(:left)
			expect(@h.length[0]).to eq(2)
		end

		it "should be 1 less than the max length" do 
			6.times { @h.adjust_min_length(:right) }
			expect(@h.length[0]).to eq(4)
		end

		it "should get a new word" do 
			expect(@h.word.length.between?(*@h.length)).to be true
		end
	end

	describe "#adjust_max_length" do 

		it "should be 1 more than min length" do 
			5.times { @h.adjust_max_length(:left) }
			expect(@h.length[1]).to eq(5)
		end

		it "should not exceed 10" do 
			10.times { @h.adjust_max_length(:right) }
			expect(@h.length[1]).to eq(10)
		end

		it "should get a new word" do 
			expect(@h.word.length.between?(*@h.length)).to be true
		end
	end

	describe "#get_str" do 

		it "should increase incorrect if the guess is not in the word" do 
			expect(@h.gallow[1][2][:value]).to eq(" ")
			@h.create_word('hello')
			@h.get_str('i')
			expect(@h.incorrect).to eq(1)
		end

		it "should add a head with 1 incorrect" do 
			expect(@h.gallow[1][2][:value]).to eq("o")
		end

		it "should add a letter to the board if the guess is correct" do 
			expect(@h.gallow[2][2][:value]).to eq(" ")
			@h.get_str('l')
			expect(@h.board.board[0][2].value).to eq('l')
			expect(@h.board.board[0][3].value).to eq('l')
		end

		it "should not add to the hangman if the guess is correct" do 
			expect(@h.gallow[2][2][:value]).to eq(" ")
		end

		it "should not allow repeat guesses" do 
			@h.get_str('l')
			expect(@h.gallow[2][2][:value]).to eq(" ")
		end

		it "should add a torso with 2 incorrect" do 
			@h.get_str('a')
			expect(@h.gallow[2][2][:value]).to eq("|")
		end

		it "should add the left arm with 3 incorrect" do 
			@h.get_str('b')
			expect(@h.gallow[2][1][:value]).to eq("/")
		end

		it "should add the right arm with 4 incorrect" do 
			@h.get_str('c')
			expect(@h.gallow[2][3][:value]).to eq("\\")
		end

		it "should add the pelvis with 5 incorrect" do 
			@h.get_str('d')
			expect(@h.gallow[3][2][:value]).to eq("*")
		end

		it "should add the left leg with 6 incorrect" do 
			@h.get_str('f')
			expect(@h.gallow[3][1][:value]).to eq("/")
			expect(@h.winner).to be nil
		end

		it "should add the right leg with 7 incorrect" do 
			@h.get_str('g')
			expect(@h.gallow[3][3][:value]).to eq("\\")
		end

		it "should set the winner to dead with 7 incorrect" do 
			expect(@h.winner).to eq('dead')
		end
	end
end