class TicTacToe

  def initialize
    @positions = {
      :a1 => 2, :a2 => 7, :a3 => 6,
      :b1 => 9, :b2 => 5, :b3 => 1,
      :c1 => 4, :c2 => 3, :c3 => 8
    }

    @victories =
      [:a1,:a2,:a3],
      [:b1,:b2,:b3],
      [:c1,:c2,:c3],
      
      [:a1,:b1,:c1],
      [:a2,:b2,:c2],
      [:a3,:b3,:c3],
      
      [:a1,:b2,:c3],
      [:c1,:b2,:a3]

    @board = {
      :a1 => " ", :a2 => " ", :a3 => " ",
      :b1 => " ", :b2 => " ", :b3 => " ",
      :c1 => " ", :c2 => " ", :c3 => " "
    }

    @corners = @positions.select {|k,v| v % 2 == 0}

    @turns = possible_moves.keys.count

    @cpu = rand() > 0.5 ? 'X' : 'O'
    @user = @cpu == 'X' ? 'O' : 'X'

    @last_move = nil

    put_line
    puts("Welcome to The Unbeatable TicTacToe master")
    put_line

    draw_start_grid

    start_game(@user == 'X')
  end

  def start_game(user_starts_first)
    if (user_starts_first)
      user_move
    else
      cpu_move
    end
  end

  def get_input
    moves = possible_moves
    print "\nYour available moves are "
    moves.each {|k,v| print "#{k} "}
    print "\n\nPlease make a move or type 'exit' to quit: "
    STDOUT.flush
    input = gets.chomp.downcase.to_sym
    if input.length == 2
      a = input.to_s.split('')
      if(['a','b','c'].include? a[0])
        if(['1','2','3'].include? a[1])
          if @board[input] == " "
            return input
          else
            wrong_move
          end
        else
          wrong_input
        end
      else
        wrong_input
      end
    else
      wrong_input unless input == :exit
      if input == :exit
        exit 0
      end
    end
  end

  def user_move
    input = get_input
    @board[input] = @user
    @last_move = "user"
    check_status
  end

  def cpu_move
    flag = possible_victory
    if flag != 0
      @board[flag] = @cpu
    else
      if @board[:b2] == " " # if center is empty cpu moves to center
        @board[:b2] = @cpu
      elsif @corners.count == 3 # if only three corners are empty
        first_corner = @corners.keys.first
        first_corner_value = @corners[first_corner]
        possible_corners = @corners.select {|k,v| v + first_corner_value == 10}
        random_corner = possible_corners.keys.sample
        @board[random_corner] = @cpu
      elsif (@corners.count <= 2 || @corners.count == 4) && @corners.count != 0 # choose random corner
        random_corner= @corners.keys.sample
        @board[random_corner] = @cpu
      else #make random move
        @board[possible_moves.keys.sample] = @cpu
      end
    end
    @last_move = "cpu"
    check_status
  end

  def possible_victory
    @victories.each do |victory|
      sum = 0
      count = 0

      if !(victory.detect {|key| @board[key] == @cpu})
        victory.each do |key|
          if @board[key] == @user
            sum += @positions[key]
            count += 1
          end
        end
      end
      
      if sum < 15 && count == 2
        pos = 15 - sum
        return @positions.key(pos)
      end
    end
    return 0
  end

  def check_victory
    winner = ""
    @victories.each do |victory|
      sum = 0
      count =
      {
        :user => 0,
        :cpu => 0
      }
      victory.each do |key|
        if sum <= 15 && @board[key] != " "
          sum += @positions[key]
          if @board[key] == @user
            count[:user] += 1
          elsif @board[key] == @cpu
            count[:cpu] += 1
          end
        else
          break
        end
      end
      if sum == 15
        if count[:user] == 3
          winner = "user"
        elsif count[:cpu] == 3
          winner = "cpu"
        end
      end
    end
    if winner != ""
      return winner
    else
      return 0
    end
  end

  def check_draw
    @victories.each do |victory|
      count =
      {
        :user => 0,
        :cpu => 0
      }
      victory.each do |key|
        if @board[key] != " "
          if @board[key] == @user
            count[:user] += 1
          elsif @board[key] == @cpu
            count[:cpu] += 1
          end
        else
          break
        end
        if count[:user] == 1 && count[:cpu] == 1
          return true
        end
      end
    end
  end

  def possible_moves
    return @board.select {|k,v| v == " "}
  end

  def update_corners
    @corners.delete_if {|k,v| @board[k] != " "}
  end

  def update_turns
    @turns = possible_moves.keys.count
  end

  def wrong_input
    puts("The input should be of the form A1, B2, C3 or similar.")
    get_input
  end

  def wrong_move
    puts("The tile you wish to move to is not empty.")
    get_input
  end

  def check_status
    put_line('-')
    @last_move == "user" ? puts("Your move"): puts("CPU's move")
    put_line('-')

    update_corners
    update_turns

    draw_board
    victory_flag = check_victory
    if victory_flag == "user"
      puts "USER WINS!"
    elsif victory_flag == "cpu"
      puts "CPU WINS!"
    else
      if @turns == 0 && check_draw
        puts "Game was a draw"
      else
        @last_move == "user" ? cpu_move : user_move
      end
    end
    exit 0
  end

  # Draws a line with the provided character
  def put_line(char = '*')
    puts("#{char}" * 42)
  end

  # Draws the starting grid with the possible inputs
  def draw_start_grid
    puts("a1 | a2 | a3")
    puts("-- | -- | --")
    puts("b1 | b2 | b3")
    puts("-- | -- | --")
    puts("c1 | c2 | c3")
  end

  def draw_board
    puts(" #{@board[:a1]} | #{@board[:a2]} | #{@board[:a3]}")
    puts(" - | - | -")
    puts(" #{@board[:b1]} | #{@board[:b2]} | #{@board[:b3]}")
    puts(" - | - | -")
    puts(" #{@board[:c1]} | #{@board[:c2]} | #{@board[:c3]}")
  end

end