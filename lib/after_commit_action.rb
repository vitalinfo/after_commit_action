require 'active_record'

if defined?(ActiveRecord::Base)
  require 'after_commit_action/base'
  ActiveRecord::Base.include AfterCommitAction
end
