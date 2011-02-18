class Bulk < ActiveRecord::Base

  def txt_type
    tbl = {
      0 => 'sibling',
      1 => 'staff',
      2 => 'on leave',
      3 => 'in district',
      4 => 'out of district',
    }
    n = self.priority_type

    return tbl[n]
  end

  def txt_type2
    tbl = {
      0 => 'sibling',   # 0
      1 => 'staff',     # 0
      2 => 'on leave',     # 1
      3 => 'in district',  # 2
      4 => 'out of district', # 3
    }
    n = self.priority_type

    return tbl[n]
  end


  def txt_status
    tbl = {
      0 => 'wait',
      1 => 'offer',
      2 => 'declined',
      3 => 'attending',
      4 => 'on leave',
      5 => 'left',
      6 => 'graduated',
      7 => 'removed',
    }
    n = self.status

    return tbl[n]
  end

  def current_grade
    return -1 if grade.nil?
    return grade + (App.this_year - grade_in_year)
  end

  def txt_current_grade
    g = current_grade
    return 'k' if g == 0
    g.to_s
  end

end

