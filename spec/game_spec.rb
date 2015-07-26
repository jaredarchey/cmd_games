require_relative "spec_helper"

describe Game do 

	before :each do 
		@g = Game.new(3, 4, "2D")
	end

	describe "#intialize" do 

		it "should initialize with a board" do 
			expect([@g.board.rows, @g.board.columns]).to eq([3,4])
		end

		it "should initialize with 2 players" do 
			expect(@g.player1.class).to eq(Player)
			expect(@g.player2.class).to eq(Player)
		end

		it "should have a main menu" do 
			expect(@g.main_menu.class).to eq(Menu)
		end
	end
end