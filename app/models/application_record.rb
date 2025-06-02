class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  extend Kaminari::ActiveRecordModelExtension
end
