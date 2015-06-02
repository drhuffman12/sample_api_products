class Product
  include Mongoid::Document
  field :name, type: String
  field :type, type: String
  field :length, type: Integer
  field :width, type: Integer
  field :height, type: Integer
  field :weight, type: Integer

  include Mongoid::Timestamps

  validates_uniqueness_of :name, :scope => [:type]
  validates_presence_of :name, :type
  validates_numericality_of :length, :greater_than => 0
  validates_numericality_of :width, :greater_than => 0
  validates_numericality_of :height, :greater_than => 0
  validates_numericality_of :weight, :greater_than => 0
end
