class TicTacToe

  def initialize

    # Use 3x3 Magic Square to find the position to win/block
    
    @positions = {
      :a1 => 2, :a2 => 7, :a3 => 6,
      :b1 => 9, :b2 => 5, :b3 => 1,
      :c1 => 4, :c2 => 3, :c3 => 8
    }

    # List of possible victory combinations
    
    @victories =
      [:a1,:a2,:a3],
      [:b1,:b2,:b3],
      [:c1,:c2,:c3],
      
      [:a1,:b1,:c1],
      [:a2,:b2,:c2],
      [:a3,:b3,:c3],
      
      [:a1,:b2,:c3],
      [:c1,:b2,:a3]

    # Declaring the playing board

    @board = {
      :a1 => " ", :a2 => " ", :a3 => " ",
      :b1 => " ", :b2 => " ", :b3 => " ",
      :c1 => " ", :c2 => " ", :c3 => " "
    }

    @corners = @positions.select {|k,v| v % 2 == 0} # list of all corners

    @turns = possible_moves.keys.count # number of turns left in the game

    # Deciding who will play first
    
    @cpu = rand() > 0.5 ? 'X' : 'O'
    @user = @cpu == 'X' ? 'O' : 'X'

    # Comment the following lines to make the first draw random
    @cpu = 'O'
    @user = 'X' # user will always go first

    @last_move = nil # variable to control game flow

    # Banner
    
    put_line
    puts("Welcome to The Unbeatable TicTacToe master")
    put_line

    # Position Helper
    
    puts("a1 | a2 | a3")
    puts("-- | -- | --")
    puts("b1 | b2 | b3")
    puts("-- | -- | --")
    puts("c1 | c2 | c3")

    start_game(@user == 'X') # Starting game
  end

  # Start Game

  def start_game(user_starts_first)
    if (user_starts_first)
      user_move
    else
      cpu_move
    end
  end

  # Gets user input
  # Prompts if incorrect move/input is made
  # Exits if the input is 'exit'

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

  # Function to control the user's move

  def user_move
    input = get_input
    @board[input] = @user
    @last_move = "user"
    check_status
  end

  # Function to control the cpu's move
  # The logic for the victory is written in here

  def cpu_move
    is_cpu_going_to_win = possible_victory("cpu")
    is_user_going_to_win = possible_victory("user")

    # Make cpu make the winning move if possible
    if is_cpu_going_to_win != 0
      @board[is_cpu_going_to_win] = @cpu
    # If user can win, block user's move
    elsif is_user_going_to_win != 0
      @board[is_user_going_to_win] = @cpu
    # Otherwise make the next move on basis of standard winning strategy
    else
      # If center is empty and it's not the first move of the game cpu moves to center
      if @board[:b2] == " " && @last_move != nil
        @board[:b2] = @cpu
      elsif @corners.count == 4 || (@corners.count <= 2 && @corners.count > 0) # choose random corner
        random_corner= @corners.keys.sample
        @board[random_corner] = @cpu
      elsif @corners.count == 3 # if only three corners are empty
        occupied_corner = @positions.select {|k,v| v % 2 == 0 && @board[k] == @cpu}
        if !occupied_corner.empty?
          occupied_corner_value = @positions[occupied_corner.keys.first]
          possible_corners = @positions.select {|k,v| v + occupied_corner_value == 10}
          possible_corner = possible_corners.keys.first
          @board[possible_corner] = @cpu
        else
          first_corner = @corners.keys.first
          first_corner_value = @corners[first_corner]
          possible_corners = @corners.select {|k,v| v + first_corner_value == 10}
          random_corner = possible_corners.keys.sample
          @board[random_corner] = @cpu
        end
      else #make random move
        puts "Time for random move"
        @board[possible_moves.keys.sample] = @cpu
      end
    end
    @last_move = "cpu"
    check_status
  end

  # HELPERS

  # Returns list of possible moves

  def possible_moves
    return @board.select {|k,v| v == " "}
  end

  # Updates the available corners

  def update_corners
    @corners.delete_if {|k,v| @board[k] != " "}
  end

  # Updates the number of turns left after each move

  def update_turns
    @turns = possible_moves.keys.count
  end

  # Displays error if incorrect input is made
  
  def wrong_input
    puts("Wrong Input: The input should be of the form A1, B2, C3 or similar.")
    get_input
  end

  # Displays error if the move was made on wrong tile

  def wrong_move
    puts("Wrong Move: The tile you wish to move to is not empty.")
    get_input
  end

  # CHECK STATUS OF GAME

  # The driving force of the game.
  # Updates the corners, turns
  # Checks if the game is a win or a draw
  
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

  # Check if the user has a chance of winning
  # if yes, then return position to block
  # else, does nothing

  def possible_victory(who)
    pos = 0
    @victories.each do |victory|
      sum = 0
      count = 0
      if who == "user"
        # If there are no moves by cpu in any victory condition then check if user can win
        if !(victory.detect {|key| @board[key] == @cpu})
          victory.each do |key|
            if @board[key] == @user
              sum += @positions[key]
              count += 1
            end
          end
        end
      # Check whether cpu can win
      elsif who == "cpu"
        if !(victory.detect {|key| @board[key] == @user})
          victory.each do |key|
            if @board[key] == @cpu
              sum += @positions[key]
              count += 1
            end
          end
        end
      end
      if sum < 15 && count == 2
        pos = @positions.key(15 - sum) # return position for making next move
        return pos
      end
    end
    # If it's a unique winning case where the user can get two possible winning spaces
    # Check if the user has one move on two corners in any diagonal
    if ((@board[:a1] == @user && @board[:c3] == @user) || (@board[:a3] == @user && @board[:c1] == @user)) && @board[:b2] == @cpu && who == "user"
      # Decide move
      if @board[:a2] == " " && @board[:c2] == " "
        pos = rand() > 0.5 ? 7 : 3
      elsif @board[:a2] == " "
        pos = 7
      elsif @board[:c2] == " "
        pos = 3
      end
    end
    return (pos != 0)? @positions.key(pos) : 0
  end

  # Checks if either user or cpu has won the game
  
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

  # Check if the game is ending in a draw
  
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

  # VISUAL HELPERS

  # Draws a line with the provided character
  
  def put_line(char = '*')
    puts("#{char}" * 42)
  end

  # Draws the board with the inputs on the tile space
  
  def draw_board
    puts(" #{@board[:a1]} | #{@board[:a2]} | #{@board[:a3]}")
    puts(" - | - | -")
    puts(" #{@board[:b1]} | #{@board[:b2]} | #{@board[:b3]}")
    puts(" - | - | -")
    puts(" #{@board[:c1]} | #{@board[:c2]} | #{@board[:c3]}")
  end

end