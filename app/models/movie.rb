class Movie < ActiveRecord::Base
  RATINGS = %w[G PG PG-13 R NC-17] # %w[] shortcut for array of strings
  validates :title, :presence => true
  validates :release_date, :presence => true
  validate :released_1930_or_later # defined below
  validates :rating, :inclusion => {:in => RATINGS}, :unless => :grandfathered?

  def released_1930_or_later
    errors.add(:release_date, 'must be 1930 or later') if
      self.release_date < Date.parse('1 Jan 1930')
  end
  def grandfathered? ; self.release_date >= '1 Jan 1930' ; end

  class Movie::InvalidKeyError < StandardError ; end

  def self.api_key
    '8a0baf42226d82299eef342e0d527fd2'
  end

  def self.find_in_tmdb(string)
    Tmdb.api_key = self.api_key
    begin
      TmdbMovie.find(:title => string)
    rescue ArgumentError => tmdb_error
      raise Movie::InvalidKeyError, tmdb_error.message
    rescue RuntimeError => tmdb_error
      if tmdb_error.message =~ /status code '404'/
        raise Movie::InvalidKeyError, tmdb_error.message
      else
        raise RuntimeError, tmdb_error.message
      end
    end
  end
end
