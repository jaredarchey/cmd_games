require "io/console"

module InputHelper

    def get_string
        string = ''
        begin
            char = read_char
            string += char if char != "\r"
            yield(string)
        end until char == "\r"
        string
    end

	def read_char
        STDIN.echo = false
        STDIN.raw!
        input = STDIN.getc.chr
        if input == "\e" then
            input << STDIN.read_nonblock(3) rescue nil
            input << STDIN.read_nonblock(2) rescue nil
        end
        ensure
        STDIN.echo = true
        STDIN.cooked!
        return input
    end
end