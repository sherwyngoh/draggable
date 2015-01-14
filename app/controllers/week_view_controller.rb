class WeekViewController < ApplicationController
  def index
  end

  def publish
    WeekViewManager.submit params['date'], params['shifts'], company_id
  end

  def common_shifts
    WeekViewManager.create_common_shifts params['commonTimings'], company_id
  end
end
