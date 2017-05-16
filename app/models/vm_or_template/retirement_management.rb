module VmOrTemplate::RetirementManagement
  extend ActiveSupport::Concern
  include RetirementMixin

  def retired_validated?
    ['off', 'never'].include?(state)
  end

  def retired_invalid_reason
    "has state: [#{state}]"
  end
end
