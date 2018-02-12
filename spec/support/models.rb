# These classes provide a very simple database for testing purposes.

# Record to hold an author.  Each author can create a number of postings.  They can also comment on other author's
# posting.
class Author < ActiveRecord::Base
  has_many :postings
  has_many :comments
end

# Record to hold a posting.
class Posting < ActiveRecord::Base
  belongs_to :author
end

# A comment on a posting.
class Comment < ActiveRecord::Base
  belongs_to :author
  belongs_to :posting
end