class ApplicationController < ActionController::API
  before_action :set_expires_in

  def paginate_results(records)
    page = params[:page] ? params[:page].to_i : 1
    per_page = params[:per_page] ? params[:per_page].to_i : 100
    data = records.paginate(page: page, per_page: per_page)
    {
      total: records.count,
      per_page: page,
      page: per_page,
      data: data
    }
  end

  def set_expires_in
    expires_in 30.minutes
  end
end
