class Block < ActiveRecord::Base

  belongs_to :grid
  belongs_to :valid_grid

  scope :with_no_letter, where(:letter => nil)
  scope :with_letter, where('letter is not NULL')

  class << self
    def create_block(grid_id, row, column)
      Block.create(:row => row, :column => column, :grid_id => grid_id)
    end
  end
end
