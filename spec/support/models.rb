# frozen_string_literal: true

# These classes provide a very simple database for testing purposes.

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

# Record to hold an author.  Each author can create a number of postings.  They can also comment on other author's
# posting.
class Author < ApplicationRecord
  has_many :postings
  has_many :comments
end

# Record to hold a posting.
class Posting < ApplicationRecord
  belongs_to :author
  has_and_belongs_to_many :categories
end

module Comments
  # A comment on a posting.
  class Comment < ApplicationRecord
    belongs_to :author
    belongs_to :posting
  end
end

class Category < ApplicationRecord
  has_and_belongs_to_many :postings
end
