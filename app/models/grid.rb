class Grid < ActiveRecord::Base

  belongs_to :game
  has_many :blocks
  has_many :valid_grids

  ROW_SIZE = 15
  COLUMN_SIZE = 15
  NO_OF_WORDS_RANGE = 10..15
  ALL_ALPHABETS = ('a'..'z').to_a
  HORIZONTAL = 'horizontal'
  VERTICAL = 'vertical'
  INVALID_WORD_SIZES = [0, 1]

  class << self
    def create_grid(game_id)
      grid = Grid.create!(:game_id => game_id)
      grid.create_blocks
      grid
    end
  end

  def create_blocks
    no_of_words = rand(NO_OF_WORDS_RANGE)
    create_blank_blocks
    fill_blocks(no_of_words)
  end

  def valid_words
    self.valid_grids.collect(&:word)
  end

  def valid_grids_found_by_player_id(player_id)
    self.valid_grids.where(:found_by_player_id => player_id)
  end

  def no_of_columns
    self.blocks.collect(&:column).max + 1
  end

  private

  def create_blank_blocks
    (0...ROW_SIZE).each do |row|
      (0...COLUMN_SIZE).each do |column|
        Block.create_block(self.id, row, column)
      end
    end
  end

  def fill_blocks(no_of_words)
    fill_with_valid_words(no_of_words)
    fill_random
  end

  def fill_with_valid_words(no_of_words)
    (0..no_of_words).each do
      flag = true
      while flag
        position = [rand(ROW_SIZE), rand(COLUMN_SIZE)]
        next if self.blocks.where(:row => position[0], :column => position[1]).with_no_letter.blank?
        direction = rand(2) == 0 ? HORIZONTAL : VERTICAL
        try_count = 0
        while try_count < 5
          max_word_size = get_max_word_size(position, direction)
          if INVALID_WORD_SIZES.include?(max_word_size)
            try_count += 1
            next
          end
          word_size = rand(2..max_word_size)
          found, word = DictionaryService.get_service.get_word(word_size, self.valid_words)
          unless found
            try_count += 1
            next
          end
          blocks = send("take_#{direction}_blocks".to_sym, position, word.size)
          fill_word_in_blocks(word, blocks)
          create_valid_grid(direction, blocks)
          flag = false
        end
      end
    end
  end

  def get_max_word_size(position, direction)
    case direction
      when HORIZONTAL
        get_horizontal_max_word_size(position)
      when VERTICAL
        get_vertical_max_word_size(position)
      else
        raise "Invalid directioon"
    end
  end

  def get_horizontal_max_word_size(position)
    min_column = self.blocks.with_letter.where(:row => position[0]).
        where('"column" >= ?', position[1]).collect(&:column).min
    min_column ||= COLUMN_SIZE
    min_column - position[1]
  end

  def get_vertical_max_word_size(position)
    min_row = self.blocks.with_letter.where(:column => position[1]).
        where('"row" >= ?', position[0]).collect(&:row).min
    min_row ||= ROW_SIZE
    min_row - position[0]
  end

  def take_horizontal_blocks(position, size)
    required_columns = (0...size).collect{|i| position[1] + i}
    self.blocks.where(:row => position[0], :column => required_columns).order('"column"').all
  end

  def take_vertical_blocks(position, size)
    required_rows = (0...size).collect{|i| position[0] + i}
    self.blocks.where(:column => position[1], :row => required_rows).order('"row"').all
  end

  def fill_word_in_blocks(word, blocks)
    word.split('').each_with_index do |letter, index|
      blocks[index].update_attributes!(:letter => letter)
    end
  end

  def create_valid_grid(direction, blocks)
    ValidGrid.create_valid_grid(self.id, direction, blocks)
  end

  def fill_random
    self.blocks.with_no_letter.each do |block|
      block.update_attributes!(:letter => ALL_ALPHABETS.shuffle.first)
    end
  end
end
