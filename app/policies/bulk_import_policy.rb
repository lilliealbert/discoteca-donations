# frozen_string_literal: true

class BulkImportPolicy < ApplicationPolicy
  def new?
    admin?
  end

  def create?
    admin?
  end
end
