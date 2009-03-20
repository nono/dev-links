require 'redis'

class Link
  attr_accessor :url, :description, :score
  attr_reader :id, :errors

  def initialize
    @score = 0
    @errors = []
  end

  # Validates this instance,
  # if ok, saves it in redis and return true
  # else, return false
  def save
    return false if !valid?
    # TODO
    true
  end

  def new_record?
    !!@id
  end

  def valid?
    false # TODO
  end

  def to_s
    "Link: #{@url}"
  end

  # Return the 20 more popular links
  def self.popular
    # TODO
    []
  end

end
