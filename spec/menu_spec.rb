require "spec_helper"

describe Menu do 

	before :all do 
		@menu = Menu.new("Title")
		@menu_format = @menu.format.children[0][0]
		@format = @menu.format
	end

	describe "#initialize" do 

		it "should have a title" do
			expect(@menu.title).to eq("Title")
		end

		it "should have no options" do 
			expect(@menu.options.length).to eq(0)
		end

		it "should have current option as 0" do 
			expect(@menu.current_option).to eq(0)
		end

	end

	describe "#create_format" do

		it "should be 3 rows without options" do 
			expect(@menu_format.rows).to eq(3)
		end

		it "should fill the size of the console" do
			expect(@format.rows).to eq(IO.console.winsize[0])
			expect(@format.columns).to eq(IO.console.winsize[1])
		end

		it "should have the menu_format as a child" do 
			expect(@format.children[0][0]).to eq(@menu_format)
		end

		it "should be 40 columns if the longest string is less than 40" do
			expect(@menu_format.columns).to eq(40)
		end

		it "should be 3 + number options rows" do 
			@menu.options = ["One", "Two", "Three"]
			@menu.create_format
			expect(@menu.format.children[0][0].rows).to eq(3 + @menu.options.length)
		end

		it "should be longest string columns if longest string > 40" do
			@menu.options = ["#{'p'*80}", "Hello", "#{'p'*70}", "#{'a'*100}"]
			@menu.create_format
			expect(@menu.format.children[0][0].columns).to eq(100)
		end

		it "should begin with highlighting option 0" do 
			@menu.options = ["One", "Two", "Three"]
			@menu.create_format
			@menu.format.children[0][0][2].each do |map| 
				expect(map[:background]).to eq(@menu.option_highlight) if map[:value] != " "
				expect(map[:background]).to eq(@menu.menu_background) if map[:value] == " "
			end
			@menu.options = []
		end

	end

	describe "#<<" do 

		it "should add an array of options" do 
			@menu << ["One", "Two", "Three"]
			expect(@menu.options.length).to eq(3)
		end

		it "should update the format" do 
			expect(@menu.format.children[0][0].rows).to eq(6)
		end

	end

	describe "#change_option_label" do 

		it "should change an options label" do 
			expect(@menu.options[0]).to eq("One")
			@menu.change_option_label(0, "Zero")
			expect(@menu.options[0]).to eq("Zero")
		end

		it "should update the format" do 
			expect(@menu.format.children[0][0].columns).to eq(40)
			@menu.change_option_label(0, "#{'0'*80}")
			expect(@menu.format.children[0][0].columns).to eq(80)
			@menu.change_option_label(0, "One")
		end

		it "should return nil if there is not the specified option" do 
			expect(@menu.change_option_label(4, "k")).to eq(nil)
		end
	end

	describe "#move_selection" do 

		it "should move highlight down" do 
			@menu.move_selection(:down)
			menu_highlight_helper(1)
		end

		it "should move highlight up" do 
			@menu.move_selection(:up)
			menu_highlight_helper(0)
		end

		it "should remap current_option to be in range" do 
			@menu.move_selection(:up)
			menu_highlight_helper(2)
			@menu.move_selection(:down)
		end
	end

	describe "#use" do 

		it "should move highlight down with down arrow key" do
			@menu.use("\e[B")
			menu_highlight_helper(1)
		end

		it "should move highlight up with up arrow key" do
			@menu.use("\e[A")
			menu_highlight_helper(0)
		end

		it "should return all input except up and down" do
			expect(@menu.use("\e[A") == "\e[A").to be false
			expect(@menu.use("\e[B") == "\e[B").to be false
			expect(@menu.use("c") == "c").to be true
		end
	end
end