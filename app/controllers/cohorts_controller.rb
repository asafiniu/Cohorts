class CohortsController < ApplicationController
  @@zone = ActiveSupport::TimeZone.new("Pacific Time (US & Canada)")
  @@num_of_weeks_back = 8
  @@cutoff_date = DateTime.new(2013, 7, 31) - @@num_of_weeks_back.weeks

  def index
    @cohorts = {}
    @largest_num_of_days = 0
    User.joins(:orders).find_each(batch_size: 5) do |u|
        user_created_at = u.created_at.in_time_zone(@@zone)
        if user_created_at > @@cutoff_date
            user_created_range = _get_week_range_str(user_created_at)
            if !@cohorts.has_key?(user_created_range)
                @cohorts[user_created_range] = {"users" => 0}
            end

            # Count orders this user made
            u.orders.each_with_index do |o, i|
                order_created_at = o.created_at.in_time_zone(@@zone)

                # Set date range as the cohort key
                key = _get_week_range_str(order_created_at)
                if !@cohorts.has_key?(key)
                    @cohorts[key] = {"users" => 0}
                end

                # Count number of users who ordered in this time frame
                @cohorts[key]["users"] += 1

                days_after_signup = (order_created_at.to_date - user_created_at.to_date).to_i
                bottom_of_range = (days_after_signup / 7) * 7
                sub_key = "%d - %d days" % [bottom_of_range, bottom_of_range + 6]
                if !@cohorts[key].has_key?(sub_key)
                    @cohorts[key][sub_key] = {
                        "orderers" => 0,
                        "first_timers" => 0
                    }
                end

                # Count number of orders made
                @cohorts[key][sub_key]["orderers"] += 1
                if i == 0
                    # Count number of first-time orders made
                    @cohorts[key][sub_key]["first_timers"] += 1
                end

                # Save the largest number of days past signup for table dimensions
                if days_after_signup > @largest_num_of_days
                    @largest_num_of_days = days_after_signup
                end
            end
        end
    end
  end

  private
  def _get_week_range_str(datetime_obj)
    week_range_str = ''
    if datetime_obj
        week_range_str = '%s - %s' % [
            datetime_obj.at_beginning_of_week.strftime("%m/%d"),
            datetime_obj.at_end_of_week.strftime("%m/%d")
        ]
    end

    return week_range_str
  end
end