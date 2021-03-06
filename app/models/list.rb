class List < ApplicationRecord

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :owner ,:class_name=>'User'
  has_and_belongs_to_many :users
  has_many :cards
  # == Validations ==========================================================
  validates_length_of :title, maximum: 100, allow_nil: false, allow_blank: false
  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Methods ========================================================

end
