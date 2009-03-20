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
    $redis[attr_key :created_at]  = DateTime.now
    $redis.push_head("links:list", @id)
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

  def score_plus
    @score = $redis.incr(attr_key :score)
  end

  def score_minus
    @score = $redis.decr(attr_key :score)
  end

  def attr_key(attribute)
    "links:#{@id}:#{attribute}"
  end

  def load(id)
    @id          = id
    @url         = $redis[attr_key :url]
    @description = $redis[attr_key :description]
    @score       = $redis[attr_key :score]
    @created_at  = $redis[attr_key :created_at]
    self
  end

  def self.find(id)
    raise RecordNotFound unless $redis.key?("links:#{id}:created_at")
    Link.new.load(id)
  end

  def self.all(keys=nil)
    keys ||= $redis.list_range("links:list", 0, -1)
    keys.map { |id| Link.new.load(id) }
  end

  # Return the 20 more popular links
  def self.popular
    return [] unless $redis.key?('links:list')
    keys = $redis.sort 'links:list', :by => 'links:*:score', :order => 'DESC', :limit => [0,20]
    all(keys)
  end

  def self.next_id
    $redis.incr("links:next_id")
  end

end
