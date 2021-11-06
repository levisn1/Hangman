require 'csv'
class Game
  attr_accessor :lifes, :board, :date, :magic_word
  def initialize(options = {})
    @lifes = options[:lifes] || 3
    @date = options[:date] || Time.new
    @magic_word = options[:magic_word] || self.magic_word_generator
    @board = options[:board] || Array.new(@magic_word.length, '_')
  end

  def magic_word_generator
    array_words = Array.new
    File.open("/home/luis/code/levisn1/Progetti/Hangman/lib/words.txt").readlines.each do |line|
      array_words << line.strip
    end
    array_words.select {|x| x.length >= 5 && x.length <= 11 }.sample.downcase.split('')
  end

  def in_game
    puts "La parola misteriosa ha #{@magic_word.length} lettere"
    puts "Tentativi rimasti a disposizione #{@lifes}"
    puts "parola misteriosa: #{@magic_word}"
    while @lifes != 0
      p @board
      puts "Scegli una lettera"
      guess = gets.chomp
      if @magic_word.include?(guess)
        @magic_word.each_with_index do |x, index|
          if x == guess
            @board[index] = guess
            p @board
            if @board == @magic_word
              puts "Complimenti hai indovinato la parola misteriosa!"
              return
            end
          end
        end
      else
        @lifes -= 1
        puts "La lettera #{guess} non e` presente nella parola magica"
        puts "Vite rimanenti #{@lifes}"
      end
      save_game(@magic_word, @lifes, @date, @board)
    end
    puts "Hai terminato le vite. GAME OVER"
    return
  end

  def save_game(magic_word,lifes,date,board)
    puts "Vuoi salvare il gioco?"
    puts "1 - Si"
    puts "2 - No"
    answer = gets.chomp
    if answer.to_i == 2
      puts "non ho salvato"
      return
    else
      filepath = '/home/luis/code/levisn1/Progetti/Hangman/lib/saved_games.csv'
      csv_options = { col_sep: ',' }
      if(File.file?('/home/luis/code/levisn1/Progetti/Hangman/lib/saved_games.csv'))
        CSV.open(filepath, 'a+') do |csv|
        csv << [magic_word, lifes, date, board]
        end
      else
        CSV.open(filepath, 'a+') do |csv|
        csv << ['Magic Word', 'Lifes', 'Date','Board']
        csv << [magic_word, lifes, date, board]
        end
      end
    end
  end

  def display_saved_games
    csv_table = CSV.table('/home/luis/code/levisn1/Progetti/Hangman/lib/saved_games.csv')
    if csv_table.count == 0
      puts 'Non hai nessun salvataggio'
      self.in_game
    else
      j = 1
      CSV.foreach('/home/luis/code/levisn1/Progetti/Hangman/lib/saved_games.csv') do |row|
        puts "#{j} - Vite: #{row[1]} Data: #{row[2]} Completamento: #{row[3]}"
        j += 1
      end
    end
  end

  def load_game(selection)
    csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }
    filepath = '/home/luis/code/levisn1/Progetti/Hangman/lib/saved_games.csv'
    CSV.foreach(filepath, csv_options) do |row|
      puts "#{row['Magic Word']}, a #{row['Lifes']} beer from #{row['Origin']}"
    end
  end

  def start
    puts "Benvenuto Luis"
    puts "1 - Nuova Partita"
    puts "2 - Carica una vecchia Partita"
    selection = gets.chomp.to_i
  end
end

new_game = Game.new
if new_game.start == 1
  new_game.in_game
else
  puts "Seleziona un salvataggio"
  new_game.display_saved_games
  selection = gets.chomp.to_i
  new_game.load_game(selection)
  new_game.in_game
end
