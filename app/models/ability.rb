class Ability
  include CanCan::Ability

  def initialize user
    if user
      if user.can_edit?
        can :edit, :catalog
      end
    end
  end
end
