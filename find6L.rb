require_relative "tetromino.rb"

class Array
    # uniq method using == instead of Object#eql? 
    def uniq_ee
        u = []
        each do |e|
            u << e unless u.include?(e) # include? uses ==.
        end
        u
    end
end


def solve(tetrominoes)
    return if tetrominoes.empty?
    n = tetrominoes.size
    (0...n).each do |i|
        tetromino = tetrominoes[i]
        ts = tetrominoes.dup
        ts.delete_at(i)
        tetromino.each do |t|
            if @board.try(t) # success
                if @board.n == 6 #complete
                    @solution << @board.dup
                else
                    solve(ts)
                end
                @board.back
            end
        end
    end
end

@board = Tetromino::Board.new(12, 2)
t = Tetromino::Tetromino.new(Tetromino::T_L)
@solution = []
solve([t, t, t, t, t, t])

@solution = @solution.uniq_ee

@solution.each do |s|
    print s, "\n"
end

print @solution.size

print "\n--------------------\n\n"

@board = Tetromino::Board.new(8, 3)
@solution = []
solve([t, t, t, t, t, t])

@solution = @solution.uniq_ee

@solution.each do |s|
    print s, "\n"
end

print @solution.size

print "\n--------------------\n\n"

@board = Tetromino::Board.new(6, 4)
@solution = []
solve([t, t, t, t, t, t])

@solution = @solution.uniq_ee

@solution.each do |s|
    print s, "\n"
end

print @solution.size
