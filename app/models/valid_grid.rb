class ValidGrid < ActiveRecord::Base

  belongs_to :grid
  has_many :blocks
  has_one :found_by_player, :class_name => 'Player'

  scope :found, where('found_by_player_id is not NULL')
  scope :not_found, where(:found_by_player_id => nil)

  class << self
    def create_valid_grid(grid_id, direction, blocks)
      valid_grid = ValidGrid.create!(:grid_id => grid_id, :direction => direction)
      blocks.each{ |block| block.update_attributes!(:valid_grid_id => valid_grid.id) }
      valid_grid
    end
  end

  def blocks_in_order
    self.blocks.order("#{get_block_order.inspect}").all
  end

  def word
    self.blocks_in_order.collect(&:letter).sum
  end

  def update_found_by(player_id)
    self.update_attributes!(:found_by_player_id => player_id)
  end

  private

  def get_block_order
    case self.direction
      when Grid::HORIZONTAL
        "column"
      when Grid::VERTICAL
        "row"
      else
        raise "Invalid direction"
    end
  end
end
