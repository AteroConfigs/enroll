class App < ActiveRecord::Base

  ext_scaffold_additional_attributes :txt_current_grade, :txt_status, :txt_type, :current_grade

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

  def self.this_year
    return 2013
  end

  def current_grade
    return grade + (App.this_year - grade_in_year)
  end

  #
  # This is necessary to navigate the issue around
  # current_grade being a calculated field 
  # and the real values it is based on (grade, grade_in_year)
  #
  # We reverse the current_grade calculation at the form
  # submit stage (which is why we deal with text values),
  # and then let the normal ActiveRecord validations occur
  #
  # We might be able to move this to current_grade= later
  #
  def self.grade_from_params(params)
    if params.has_key?('current_grade') && params.has_key?('grade_in_year')
      cg = params['current_grade'].to_i
      giy = params['grade_in_year'].to_i
      grade = cg - (App.this_year - giy)

      params['grade'] = grade.to_s
      params.delete('current_grade')
    end
  end

  def txt_current_grade
    g = current_grade
    return 'k' if g == 0
    g.to_s
  end

  def self.wait_list_for_txt_grade(query, include_zero = false)
    mapping = { 
      'k' => 0,
      '1' => 1,
      '2' => 2,
      '3' => 3,
      '4' => 4,
      '5' => 5,
      '6' => 6,
      '7' => 7,
      '8' => 8,
    }

    bag = App.wait_list(include_zero)

    return bag[mapping[query]]
  end

  def self.wait_list(include_zero = false)
    apps = App.find :all

    apps.reject! { |o| o.txt_status != 'wait' }
    if not include_zero
      apps.reject! { |o| o.wait_list_position == 0 }
    end

    bag = {}
    (0..8).each do | grade |
      bag[grade] = apps.select { |e| e.current_grade == grade }.sort_by { |a| a.wait_list_position }
    end
    return bag
  end

  def move_to_end_of_waitlist()
    all_apps = App.wait_list
    my_grades_apps = all_apps[self.current_grade]

    if my_grades_apps.empty?
      self.wait_list_position = 1
    else
      self.wait_list_position = my_grades_apps.last.wait_list_position + 1
    end

    save
  end

  def self.normalize_waitlist_for_txt_grade(txt_grade)

    apps = App.wait_list_for_txt_grade(txt_grade)

    touched = false
    apps.each_with_index {
      | app, idx |
      if app.wait_list_position != (idx + 1)
        touched = true
      end
    }

    if not touched
      return 0
    end

    apps.each_with_index {
      | app, idx |
      app.wait_list_position = (idx + 1)
      app.save
    }

    return 1

  end

  def self.display_headers
    %w( first_name last_name application_date orientation_date
tour_date code txt_current_grade txt_status txt_type
street_1 street_2 city state zip father_first_name
father_last_name father_phone_cell father_phone_home father_phone_work
father_email_home father_email_work father_street_1 father_street_2
father_city father_state father_zip mother_first_name mother_last_name
mother_phone_cell mother_phone_home mother_phone_work mother_email_home
mother_email_work mother_street_1 mother_street_2 mother_city mother_state
mother_zip notes siblings birthdate)
  end

  def self.required_headers
    %w( first_name last_name application_date orientation_date
tour_date code grade
street_1 street_2 city state zip father_first_name
father_last_name father_phone_cell father_phone_home father_phone_work
father_email_home father_email_work father_street_1 father_street_2
father_city father_state father_zip mother_first_name mother_last_name
mother_phone_cell mother_phone_home mother_phone_work mother_email_home
mother_email_work mother_street_1 mother_street_2 mother_city mother_state
mother_zip notes siblings birthdate)
  end

  def self.import_from_csv(file_obj)
    require 'fastercsv'
    csv = FasterCSV.new(file_obj, { :headers => true})
    const_headers = %w( status sequence_number wait_list_position )
    headers = required_headers
    special_csv_header = [ 'grade', 'In District?' ]
    grade_mapping = { 
      'k' => 0,
      '0' => 0,
      '1' => 1,
      '2' => 2,
      '3' => 3,
      '4' => 4,
      '5' => 5,
      '6' => 6,
      '7' => 7,
      '8' => 8,
    }
    data = []
    csv.each do |row|
      next if row['first_name'].nil?
      r = {}
      begin
        row.each_with_index do |fld,idx|
          r['status'] = 0
          if headers.include? fld[0]
            r[fld[0]] = fld[1]
          end
          if fld[0] == 'grade' && fld[0]
            r['grade'] = grade_mapping[fld[1].downcase]
            r['grade_in_year'] = self.this_year
          end
          if fld[0] == 'In District?'
            if fld[1]
              r['priority_type'] = (fld[1].upcase[0...1] == "Y" ? 3 : 4)
            else
              r['priority_type'] = 3
            end
          end
        end
        data << r
      rescue Exception => e
        p row
        p r
        raise
      end
    end
    bulks = data.map { |h| Bulk.new(h) }
    if bulks.any? { |a| not a.valid? }
      return ['fail', (bulks.find { |a| not a.valid? }).errors.inspect ]
    end

    if Bulk.count > 0
      return ['fail', "Previous upload not cleared - preventing duplication" ]
    end

    bulks.each { |b| b.save! }

    return ['ok', "saved bulk upload" ]
  end

end

App.inheritance_column = 'blblblb'
