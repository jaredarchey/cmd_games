require_relative "../lib/input_helper"
require_relative "../lib/formatter"
require "yaml"

# Need to test with rspec

class Menu
	include FormatHelper
	include InputHelper
	attr_reader :title, :options, :format, :current_option

	def initialize(title)
		@title = title
		@options = []
		@current_option = 0
		create_format
	end

	def <<(options)
		options.class == Array ? options.each {|option| @options << option} : @options << option
		create_format
	end

	def change_option_label(option, label)
		return nil if option > @options.length || option < 0
		@options[option] = label
		create_format
	end

	def use
		input = read_char
		case input
		when "\e[A" then move_selection(:up)
		when "\e[B" then move_selection(:down)
		when "\u0003" then exit
		else return input
		end
	end

	def create_format
		format_width = longest_string
		format_height = @options.length + 3
		@format = Formatter.new(format_height, format_width, :black)
		@format.insert_string([0,0], value: @title, color: :green)
		@format.insert_string([1,0], value: "#{'-'*format_width}", color: :red)
		@options.length.times do |i| 
			background = i == @current_option ? :red : nil
			@format.insert_string([i+2,0], value: @options[i], background: background)
		end
		@format.insert_string([-1,0], value: "#{'-'*format_width}", color: :red)
		@format = full_screen(@format, :white)
	end

	def move_selection(direction)
		case direction
		when :up   then @current_option -= 1
		when :down then @current_option += 1
		end
		@current_option = 0 if @current_option > @options.length-1
		@current_option = @options.length-1 if @current_option < 0
		create_format
	end

	def show
		puts @format.to_s
	end

	def load(game)
		base_path = "#{File.expand_path File.dirname(__FILE__)}/../data/"
		if Dir.new(base_path).include?("#{game}.yml")
			game = YAML::load_file("#{base_path}/#{game}.yml")
			game[0].play(true)
		end
	end

	private

	def longest_string
		longest = @title.length < 40 ? 40 : @title.length
		@options.each { |option| longest = option.length if option.length > longest }
		longest
	end
end

#m = Menu.new("Jared")