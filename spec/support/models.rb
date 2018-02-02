class Author < ActiveRecord::Base
  has_many :postings
  has_many :comments
end

class Posting < ActiveRecord::Base
  belongs_to :author
end

class Comment < ActiveRecord::Base
  belongs_to :author
  belongs_to :posting
end