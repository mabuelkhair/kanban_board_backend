class Comment < ApplicationRecord
  belongs_to :card
  belongs_to :owner ,:class_name=>'User'
  has_many :replies, class_name: "Comment",
                          foreign_key: "comment_id"
 
  belongs_to :comment, class_name: "Comment", optional: true
end
