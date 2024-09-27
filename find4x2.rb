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


@solution = []
def solve(tetrominoes)
    return if tetrominoes.empty?
    n = tetrominoes.size
    (0...n).each do |i|
        tetromino = tetrominoes[i]
        ts = tetrominoes.dup
        ts.delete_at(i)
        tetromino.each do |t|
            if @board.try(t) # success
                if @board.n == 2 #complete
                    @solution << @board.dup
                else
                    solve(ts)
                end
                @board.back
            end
        end
    end
end

@board = Tetromino::Board.new(4, 2)
t0 = Tetromino::Tetromino.new(Tetromino::T_Line)
t1 = Tetromino::Tetromino.new(Tetromino::T_L)
t2 = Tetromino::Tetromino.new(Tetromino::T_T)
t3 = Tetromino::Tetromino.new(Tetromino::T_Square)
t4 = Tetromino::Tetromino.new(Tetromino::T_Z)
solve([t0, t0, t1, t1, t2, t2, t3, t3, t4, t4])

@solution = @solution.uniq_ee

@solution.each do |s|
    print s, "\n"
end

print @solution.size

print "\n\n"
