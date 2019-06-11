class IssuesController< ApplicationController

  before_filter :load_object, only: [:edit, :update]
  before_filter :load_objects, only: [:index]

  ALLOWED_ATTRIBUTES = [:description, :priority, :status, :last_modified_at]
  DATE_FIELDS = [:last_modified_at]
  STRING_FIELDS  = [:description, :priority, :status]
  MAPPING = {
    last_modified_at: :updated_at
  }

  def index
  end

  def search
    if params[:query].present?
        search_input = params[:query].include?('&') ? params[:query].split('&') : [params[:query]]
        @conditions = "1=1" # return all result
        search_keys = search_input.each do |search_key|
            parse_key = search_key.split(':')
            key = parse_key[0]
            value = parse_key[1]
            next unless ALLOWED_ATTRIBUTES.include? key.to_sym
            @conditions << construct_sql_query(key, value)
        end
        @issues = Issue.where(@conditions).to_a
        render :index
    end
  end

  def edit
  end

  def update
    if params[:issue].present? && @issue.update_attributes(params[:issue].symbolize_keys)
      load_objects
      redirect_to issues_path
    else
      render :edit
    end
  end

  private

    def load_object
      @issue = Issue.find(params[:id])
    end

    def load_objects
      @issues = Issue.all.to_a
    end

    def construct_sql_query(key, value)
      return "" if value.empty?
      if DATE_FIELDS.include? (key.to_sym)
        dates = value.split(',')
        # Assume date field query shoud have both start and end date for filter in array, 
        # we should parse at frontend and send in post call
        start_date = dates[0]
        end_date = dates[1]
        query = " and #{MAPPING[key.to_sym]} >  '" + start_date + "' and #{MAPPING[key.to_sym]} < '" + end_date + "'"
      elsif STRING_FIELDS.include?(key.to_sym)
        query = " and #{key} like '%" + value + "%'"
      end
      query
    end
end
