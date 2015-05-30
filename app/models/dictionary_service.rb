class DictionaryService

  FILENAME = File.dirname(__FILE__) + '/words.txt'

  def initialize
    @word_hash ||= get_words
  end

  class << self
    def get_service
      @service ||= DictionaryService.new
    end
  end

  def get_words
    hash = {}
    f = File.open(FILENAME, 'r')
    f.each_line do |word|
      word.gsub!("\n", '')
      word = word.split("\'")[0]
      word_size = word.size
      next if word_size <= 1
      hash[word_size] ||= []
      hash[word_size] << word.downcase
    end
    f.close
    hash
  end

  def get_word(size, ignore_words = [])
    possible_words = @word_hash[size].uniq - ignore_words
    return [false, nil] if possible_words.blank?
    random_index = rand(possible_words.size)
    [true, possible_words[random_index]]
  end
end