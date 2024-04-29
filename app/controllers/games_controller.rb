class GamesController < ApplicationController
  def new
    alphabet = ('a'..'z').to_a
    @letters = 10.times.map { alphabet.sample }.join
  end

  def score
    @suggested_word = params[:suggested_word].to_s.downcase
    @original_grid = params[:original_grid].to_s.downcase
    @result = if word_in_grid?(@suggested_word, @original_grid) && valid_english_word?(@suggested_word)
                "Congratulations! #{@suggested_word} is a valid English word!"
              elsif word_in_grid?(@suggested_word, @original_grid)
                "Sorry, but #{@suggested_word} does not seem to be a valid English word."
              else
                "Sorry, but #{@suggested_word} can't be built out of #{@original_grid}."
              end
  end

  private

  def word_in_grid?(word, grid)
    grid_counts = grid.chars.tally
    word.chars.all? { |char| word.count(char) <= grid_counts[char].to_i }
  end

  def valid_english_word?(word)
    uri = URI("https://wagon-dictionary.herokuapp.com/#{word}")
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
    json['found']
  rescue StandardError => e
    Rails.logger.error "API request failed: #{e.message}"
    false
  end
end
