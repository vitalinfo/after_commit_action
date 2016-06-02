# use this module to defer actions to the after-commit hook. this is useful if you want
# to trigger actions in after_create, after_destroy and after_update callbacks but want
# to execute them outside of the transaction (for example, to avoid deadlocks).
#
# Usage:
# after_create :my_hook
# def my_hook
#   execute_after_commit { puts "This is called after committing the transaction. "}
# end
require 'active_support/concern'

module AfterCommitAction
  extend ActiveSupport::Concern

  included do
    after_commit :_execute_after_commit_hook
  end

  def execute_after_commit(&block)
    return block.call if ActiveRecord::Base.connection.open_transactions.zero?

    ActiveRecord::Base.connection.add_transaction_record(self)

    @_execute_after_commit ||= []
    @_execute_after_commit << block
  end

  private

  def _execute_after_commit_hook
    @_execute_after_commit.shift.call until @_execute_after_commit.blank?
  rescue
    if defined?(Exceptional)
      # Rails quietly swallows exceptions in after-commit actions; to avoid missing these
      # exceptions, we pass them to Exceptional explicitly
      Exceptional.context(after_commit_entity: self.inspect)
      Exceptional.handle($!, "execute_after_commit")
    else
      Rails.logger.error "Error in execute_after_commit block: #{$!.inspect}"
    end
    raise
  end
end
