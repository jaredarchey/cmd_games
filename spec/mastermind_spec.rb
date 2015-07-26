require_relative "spec_helper"

describe MasterMind do 
	before :all do 
		@mm = MasterMind.new
	end

	describe "#initialize" do 

		it "should have 12 attempts" do 
			expect(@mm.attempts).to eq(12)
		end

		it "should have a code_length 4" do 
			expect(@mm.length).to eq(4)
		end

		it "should have a board" do 
			expect([@mm.board.rows, @mm.board.columns]).to eq([12,4])
		end

		it "should have a code" do 
			expect(@mm.code.length).to eq(4)
		end

		it "should have an empty guess" do 
			expect(@mm.guess).to eq('')
		end

		it "should have 0 correct" do 
			expect(@mm.correct).to eq(0)
		end

		it "should have an empty history" do 
			expect(@mm.history).to eq([])
		end

		it "should title the menu MasterMind" do 
			expect(@mm.main_menu.title).to eq(@mm.class.to_s)
		end
	end

	describe "#adjust_length" do 

		it "should change the code length" do 
			@mm.adjust_length(:right)
			expect(@mm.length).to eq(5)
			@mm.adjust_length(:left)
			expect(@mm.length).to eq(4)
		end

		it "should get a new code" do 
			expect(@mm.code.length).to eq(@mm.length)
			@mm.adjust_length(:right)
			expect(@mm.code.length).to eq(@mm.length)
		end

		it "should resize the board" do 
			expect(@mm.board.columns).to eq(@mm.length)
		end

		it "should not be greater than 6" do
			3.times { @mm.adjust_length(:right) }
			expect(@mm.length).to eq(6)
			expect(@mm.length).to eq(@mm.board.columns)
		end

		it "should not be less than 2" do 
			5.times { @mm.adjust_length(:left) }
			expect(@mm.length).to eq(2)
			expect(@mm.length).to eq(@mm.board.columns)
		end
	end

	describe "#adjust_attempts" do 

		it "should not be less than 4" do 
			15.times { @mm.adjust_attempts(:left) }
			expect(@mm.attempts).to eq(4)
		end

		it "should resize the board" do 
			expect(@mm.board.rows).to eq(4)
		end

		it "should not be greater than 15" do 
			15.times { @mm.adjust_attempts(:right) }
			expect(@mm.attempts).to eq(15)
			10.times { @mm.adjust_attempts(:left) }
		end
	end

	describe "#adjust_repeats" do 

		it "should toggle the repeats variable" do 
			expect(@mm.repeats).to be true
			@mm.adjust_repeats
			expect(@mm.repeats).to be false
			@mm.adjust_repeats
			expect(@mm.repeats).to be true
		end
	end 

	describe "#random_code" do 

		it "should create a code of length @length" do 
			c = @mm.random_code
			expect(c.length).to eq(@mm.length)
		end
	end

	describe "#get_str" do

		it "should add to guess only if its 'roygbiv'" do 
			expect(@mm.guess).to eq('')
			@mm.get_str('h')
			expect(@mm.guess).to eq('')
			@mm.get_str('b')
			expect(@mm.guess).to eq('b')
		end

		it "should find the number of correct characters" do 
			@mm.update_display
			@mm.create_code('rg')
			expect(@mm.code).to eq('rg')
			@mm.get_str('g')
			expect(@mm.correct).to eq(1)
		end

		it "should reset the guess after finding correct spaces" do 
			expect(@mm.guess).to eq('')
		end

		it "should add the guess to guess history" do 
			expect(@mm.history).to eq(['bg'])
		end

		it "should fill the first empty row of the board" do 
			fill_row = @mm.board.get_by_pattern([4,0],[0,1])
			expect([fill_row[0].value, fill_row[1].value]).to eq(['b','g'])
			fill_row[0].format.each {|f| expect(f[:background]).to eq(:cyan)}
			fill_row[1].format.each {|f| expect(f[:background]).to eq(:green)}
			@mm.get_str('r')
			@mm.get_str('y')
			fill_row = @mm.board.get_by_pattern([3,0],[0,1])
			fill_row[0].format.each {|f| expect(f[:background]).to eq(:red)}
			fill_row[1].format.each {|f| expect(f[:background]).to eq(:yellow)}
		end

		it "should declare a winner if the code is guessed" do 
			expect(@mm.winner).to eq(nil)
			@mm.get_str('r')
			@mm.get_str('g')
			expect(@mm.correct).to eq(2)
			expect(@mm.winner).to be true
		end
	end
end