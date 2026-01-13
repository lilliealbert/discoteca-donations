# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :volunteer, :record

  def initialize(volunteer, record)
    @volunteer = volunteer
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    volunteer&.admin?
  end

  class Scope
    def initialize(volunteer, scope)
      @volunteer = volunteer
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :volunteer, :scope
  end
end
