# Authorization rules for member records.
#
# Read actions (index/show) are open to every authenticated user. Write actions
# (create/new/update/edit/destroy) are restricted to 宮主 (status: master).
class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.master?
  end

  def update?
    user.master?
  end

  def destroy?
    user.master?
  end
end
