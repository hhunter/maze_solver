#!/usr/bin/ruby

require 'maze'
require 'getoptlong'

def print_help
  puts <<-EOF
e_maze.rb [OPTION] ... FILE

--help          : Show this message

--dead-end-fill : Solve maze using the simple dead-end-filler algorithm

--human         : DEFAULT.  Solve maze in a more human way by walking the maze and
                  eliminating twice-visited pathways

FILE            : The file containing ascii mazes to solve

  EOF
  exit
end

opts = GetoptLong.new(
  [ '--help',          '-h', GetoptLong::NO_ARGUMENT ],
  [ '--dead-end-fill',       GetoptLong::NO_ARGUMENT ],
  [ '--human',               GetoptLong::NO_ARGUMENT ]   
)

# there are two solvers, we'll use the human solver by default
solver = 'human'

opts.each do |opt, arg|
  case opt
    when '--help'
      print_help
    when '--dead-end-fill'
      solver = 'dead_end_fill'
    when '--human'
      solver = 'human'
  end
end

# make sure a filename was passed in
if ARGV.length != 1 # no file argument
  print_help
end


filename = ARGV.pop
if ! File.exists?(filename)
  puts "filename #{filename} does not exist"
  exit
end

# TODO test existance of filename

ascii_mazes = []  # an array of ascii mazes
am          = []  # an actual ascii maze

File.open(filename, 'r') do |file|
  while line = file.gets
    # skip line if there's no maze elements present
    next if line !~ /\*/

    # trim any non-wall whitespace at the beginning of the lilne
    line = line.gsub(/^[^*]*/, '')

    # trim any non-wall whitespace at the end of the line
    line = line.gsub(/[^*]*$/, '')
   
    am.push(line.split(''))
  
    if (line !~ / / && am.size > 1)
      ascii_mazes.push(am)
      am = []
    end
 
  end
end

ascii_mazes.each { |am|
  maze = Maze.new(am)
  maze.solve(solver)
  maze.print_solution()
}


