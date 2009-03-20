require 'redis'
$redis = Redis.new

class RecordNotFound < Exception
end


class Link
  attr_accessor :url, :description, :score
  attr_reader :id, :errors, :created_at

  def initialize
    @score = 0
    @errors = []
  end

  # Validates this instance,
  # if ok, saves it in redis and return true
  # else, return false
  def save
    return false if !valid?
    @id = self.class.next_id
    $redis[attr_key :url]         = @url
    $redis[attr_key :description] = @description
    $redis[attr_key :score]       = @score
    # TODO $redis["links:#{@id}:created_at"]  = DateTime.now
    true
  end

  def new_record?
    !@id
  end

  def valid?
    @errors = []
    @errors << "Veuillez donner une URL"         if @url.nil?         || '' == @url
    @errors << "Veuillez donner une description" if @description.nil? || '' == @description
    @errors.empty?
  end

  def attr_key(attribute, id=nil)
    "links:#{id || @id}:#{attribute}"
  end

  def load(id)
    @id          = id
    @url         = $redis[attr_key :url]
    @description = $redis[attr_key :description]
    @score       = $redis[attr_key :score]
    self
  end

  def self.find(id)
    raise RecordNotFound unless $redis.key?("links:#{id}:url") # TODO created_at
    Link.new.load(id)
  end

  def self.all
    keys = $redis.keys("links:*:url") # TODO created_at
    keys.map do |key|
      key = key.scan(/\d+/).first
      Link.new.load(key)
    end
  end

  # Return the 20 more popular links
  def self.popular
    # TODO
    []
  end

  def self.next_id
    $redis.incr("links:next_id")
  end

end
