# Unit representing a profile and it's different states
class Profile
  class << self
    attr_accessor :store
  end

  self.store = {
    id: 0
  }

  def self.build_valid(extra = {})
    new({
      'id' => store[:id] += 1,
      'created_at' => Time.new,
      'Name' => 'John Rush',
      'Email' => 'example@gmail.com',
      'Gender' => 'M',
      'Phone' => '+35922333232',
      'Employed' => 'Y',
      'Education' => 'Graduate',
      'Married' => 'Y',
      'Age' => '18'
    }.merge(extra))
  end

  attr_reader :data
  alias to_h data

  def initialize(data = {})
    @data = data
  end

  def [](key)
    data[key]
  end
end
