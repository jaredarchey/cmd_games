require_relative "spec_helper"

describe Space do

	it "should optionally initialize with a value" do 
	 	space = Space.new("X")
	 	expect(space.value).to eq("X")
	 	expect { Space.new("XY") }.to raise_error(ArgumentError)
	end

	it "should optionally initialize with formatting" do 
	 	space = Space.new(" ", color: :blue, background: :red)
	 	expect(space.format[0][1]).to eq({value: " ", color: :blue, background: :red})
	end

	describe "#value" do
	 	it "should return its value" do
	 		space = Space.new("X")
	 		expect(space.value).to eq("X")
	 	end
	end

	describe "#set" do
		before :each do
			@space = Space.new(" ")
		end

		it "should set its value" do 
			@space.set(value: "X")
			expect(@space.value).to eq("X")
		end

		it "should set all characters backgrounds" do
			@space.set(background: :black)
			@space.format.each {|char| expect(char).to eq({value: " ", color: nil, background: :black})}
		end

		it "should only set the values foreground" do 
			@space.set(value: "X", color: :red)
			expect(@space.format[0][0]).to eq({value: " ", color: nil, background: nil})
			expect(@space.format[0][1]).to eq({value: "X", color: :red, background: nil})
			expect(@space.format[0][2]).to eq({value: " ", color: nil, background: nil})
		end
	end

	describe "#to_s" do
		it "should be returned as a string" do
			space = Space.new(" ") 
		 	expect(space.to_s.class).to eq(String)
		end
	end
end