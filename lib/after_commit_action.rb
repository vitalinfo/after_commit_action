require 'active_record'

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.raise_in_transactional_callbacks = true if ActiveRecord::VERSION::MAJOR < 5
  require 'after_commit_action/base'
  ActiveRecord::Base.include AfterCommitAction
end
