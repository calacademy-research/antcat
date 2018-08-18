class Ability
  include CanCan::Ability

  def initialize user
    if user
      if user.has_role? :editor
        can :edit, :catalog
      end
    end
  end
end
