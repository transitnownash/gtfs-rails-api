class NextbusController < ApplicationController
  # GET /nextbus/route-:route_gid/direction-:direction_id
  def show
    route = Route.find_by_route_gid(params[:route_gid])
    nextbus = StopTime
              .joins('JOIN trips t ON t.id = stop_times.trip_id')
              .joins('JOIN routes r ON t.route_id = r.id')
              .where('r.route_gid = ? OR r.route_short_name', params[:route_gid], params[:route_gid])
              .where('stop_times.stop_sequence = ?', 1)
              .where('direction_id = ?', params[:direction_id])
              .where("service_gid IN (SELECT s.service_gid FROM calendars s WHERE #{Date.today.strftime('%A').downcase} = 1 AND DATE(NOW()) BETWEEN s.start_date AND s.end_date)")
              .where('service_gid NOT IN (SELECT cd.service_gid FROM calendar_dates cd WHERE cd.date != DATE(NOW()) AND cd.exception_type != 2)')
              .order('stop_times.arrival_time')
    render json: {
      route: route,
      nextbus: nextbus.as_json(include: [:trip, :stop])
    }
  end

  # GET /nextbus/route-:route_gid/direction-:direction_id/stop-:stop_gid
  def show_by_stop
    route = Route.find_by_route_gid(params[:route_gid])
    nextbus = StopTime
              .joins('JOIN trips t ON t.id = stop_times.trip_id')
              .joins('JOIN routes r ON t.route_id = r.id')
              .joins('JOIN stops s ON s.id = stop_times.stop_id')
              .where('r.route_gid = ? OR r.route_short_name = ?', params[:route_gid], params[:route_gid])
              .where('s.stop_gid = ? OR s.stop_code = ?', params[:stop_gid], params[:stop_gid])
              .where('direction_id = ?', params[:direction_id])
              .where("service_gid IN (SELECT s.service_gid FROM calendars s WHERE #{Date.today.strftime('%A').downcase} = 1 AND DATE(NOW()) BETWEEN s.start_date AND s.end_date)")
              .where('service_gid NOT IN (SELECT cd.service_gid FROM calendar_dates cd WHERE cd.date != DATE(NOW()) AND cd.exception_type != 2)')
              .order('stop_times.arrival_time')
    render json: {
      route: route,
      nextbus: nextbus.as_json(include: [:trip, :stop])
    }
  end
end
