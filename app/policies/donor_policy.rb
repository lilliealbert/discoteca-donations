# frozen_string_literal: true

class DonorPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end
end
