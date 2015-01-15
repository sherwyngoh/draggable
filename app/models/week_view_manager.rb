class WeekViewManager

  def self.submit start_date, shift_array, company_id
    @date   = start_date.to_date
    @shifts = shift_array

    test    = Employee.find(@shifts.sample['employeeID']).company_id == company_id
    return false unless test

    self.remove_shifts @date, company_id

    time_zone = Company.find(company_id).time_zone
    self.add_shifts @shifts, time_zone
  end

  def self.remove_shifts start_date, company_id
    WeekViewManager.get_shifts(start_date, company_id).delete_all
  end

  def self.add_shifts shifts, time_zone
    Time.use_zone time_zone do
      shifts.each do |shift|
        start  = (shift['date'].to_s  + ' ' + shift['startHour'].to_s + ':' + shift['startMin'].to_s).to_datetime
        finish = start + shift['length'].hours # to account for overnight shifts
        Shift.create(employee_id: shift['employeeID'], start: start, finish: finish, break_hours: shift['breakHours'], length: shift['length'])
      end
    end
  end

  def self.create_common_shifts commonTimings, company_id
    company = Company.find(company_id)
    company.common_timings.delete_all
    commonTimings.each do |timing|
      start  = (timings['date'].to_s  + ' ' + timings['startHour'].to_s + ':' + timings['startMin'].to_s).to_datetime
      finish = start + timings['durationHours'].hours + timings['durationMins'].minutes # to account for overnight timings
      company.common_timings.build(start: start, finish: finish, company_id: company_id)
    end
    company.save
  end

  def self.get_shifts start_date, company_id
    Company.find(company_id).shifts.where(date: date..(date + 6.days))
  end

end