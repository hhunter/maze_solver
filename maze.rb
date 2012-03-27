class Maze

  attr_reader :height, :width

  def initialize(maze_2d)
    
    @maze = []  # 2-D maze represented in 1-D array

    maze_2d.each_index { |rownum|
      maze_2d[rownum].each_index { |colnum|
        @maze.push( maze_2d[rownum][colnum] )
      }
    }

    @height = maze_2d.size        # num of rows in 2-D maze is height
    @width  = @maze.size / height # total num cells / height is width

    @start  = coordinates2index(1, height-2) # lower left corner (not outer wall) 
    @finish = coordinates2index(width-2, 1)  # upper right corner (not outer wall)

    # @solution will contain a trail of breadcrumbs so we can later draw
    # the happy path.  We'll initialize it with the starting position
    # since we know that to be on the happy path
    
    @solution = [ @start ]

    # the cursor will hold an index for the @maze array and keeps track of
    # where we are on the maze
    
    @cursor   = @start

  end

  def to_s
    # useful when debugging ... prints the current state of the maze
    copy = @maze.clone
    copy.each_index do |i|
      copy[i] = '.' if @solution.include?(i)
    end
    copy[@cursor] = 'o'
    copy.each_slice(width) do |a|
      puts a.join('')
    end
  end

  def print_solution
    # draw the happy path
    @solution.each do |i|
      @maze[i] = '.'
    end

    # turn cells sealed off by this program back into open cells
    @maze.each_slice(width) do |a|
      puts a.join().gsub(/X/, ' ')
    end
  end

  def is_open?(i)
    (@maze[i] =~ /\s/)  ? true : false
  end

  def is_blocked?(i) ! is_open?(i)  end

  def is_start? (i=@cursor) i == @start  end
  def is_finish?(i=@cursor) i == @finish end

  ## 
  # Returns the index of the cell n/s/e/w of the index passed in.
  # Since there are walls around the whole maze, we don't need to 
  # be too careful about edges.  In other words, moving east from
  # a cell on the eastern edge of the maze will return the index
  # of an outer wall and we will never move the cursor there
  
  def north(i=@cursor) i-width end 
  def south(i=@cursor) i+width end
  def east (i=@cursor) i+1     end
  def west (i=@cursor) i-1     end

  #
  ##

  def num_exits(i=@cursor)
    num_exits = 0
    num_exits += 1 if is_open?(north(i))
    num_exits += 1 if is_open?(south(i))
    num_exits += 1 if is_open?(east(i))
    num_exits += 1 if is_open?(west(i))
    num_exits
  end

  def coordinates2index(x,y)
    (y % height) * width + (x % width)
  end

  def rewind

    # If we ever find we have no choice but to move back the way we came, then 
    # we know that we turned off the happy path at some point and all the cells 
    # visited since the last junction are not on the happy path.  
    #
    # Rewinding moves the cursor back to the last junction and marks cells 
    # visited since that junction with an 'X' so they won't be re-visited

    @rewind = []
    while (num_exits(@solution.last) < 3 && @solution.last != @start) 
      @rewind.push(@solution.pop)
      @cursor = @solution.last
    end
    @rewind.each do |i|
      @maze[i] = 'X'
    end 
  end


  def move_next

    # Used in the human solver, this method tries to move the @cursor to an
    # adjacent cell that has not been previously visited.
    #
    # If no other option exits but to re-tread on a cell, we rewind()
 
    open = [] # directions available for next move

    # in general, we want to move north and east toward the solution, so it's
    # a small optimization to include these directions first
    %w( north east south west ).each do |dir|
      if (is_open?(send(dir))) 
        open.push(dir)
      end
    end
   
    dir_to_move = nil

    # choose a non-visted direction
    open.each do |dir|
      if (! @solution.include?(send(dir)))
        dir_to_move = dir
        break  
      end
    end
  
    # actually move the cursor to the new cell
    if dir_to_move
      @solution.push(send(dir_to_move))
      @cursor = send(dir_to_move)
    else
      # if we didn't find a non-visted direction in which to move, it's time 
      # to rewind()
      rewind()
    end

  end

  def solve(solver)
    solver_method = ['solver', solver].join('_')

    if ! respond_to?(solver_method)
      puts "unknown solver: #{solver}"
      exit
    end
    send(['solver', solver].join('_'))
  end

  ##
  # Solvers 
  ##

  def solver_human 

    while (@cursor != @finish)
      move_next
    end 
 
  end

  def solver_dead_end_fill
  
    while(1)
      dead_ends_filled = 0
      @maze.each_index do |i|
        next if is_blocked?(i)
        next if is_start?(i)
        next if is_finish?(i)
        if i != @start && i != @finish && num_exits(i) == 1
          @maze[i] = 'X'
          dead_ends_filled += 1 
        end
      end
      break if dead_ends_filled == 0
    end
  
    # we find the @solution based on what's left
    @maze.each_index do |i|
      @solution.push(i) if @maze[i] == ' '
    end
  
  end

end

