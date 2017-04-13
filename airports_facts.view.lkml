view: airports_facts {

# view: airports_facts {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
derived_table: {
  sql:
    Select *, case when departure_count_rank<=48 then airport when departure_count_rank is null then 'other' else 'other' end as rankGroup from
    (
    Select
    flights.origin as airport,
    count(*) as airport_departures_count,
    rank() over(order by airport_departures_count desc) as departure_count_rank,
    min(dep_time) as first_flight,
    max(dep_time) as last_flight
    from
    airports left join flights on airports.code=flights.origin
    group by 1
    ) Basic_and_departures_info
    left join
    (
    Select
    flights.destination,
    count(*) as airport_destinations_count
    from
    airports left join flights on airports.code=flights.destination
    group by 1
    ) arrivals_info on arrivals_info.destination=Basic_and_departures_info.airport;;
  }

  dimension: airport {
    primary_key: yes
  }

  dimension: airport_departures_count{
    type: number
    sql:  ${TABLE}.airport_departures_count ;;
  }

  dimension: first_flight {
    type: date
  }

  dimension: last_flight {
    type: date
  }

  dimension: airport_arrivals_count {
    type: number
    sql:  ${TABLE}.airport_destinations_count ;;
  }

  dimension: years_first_flight_to_last {
    type: number
    value_format: "0.###"
    sql:(${last_flight}-${first_flight})*1.0/365.25 ;;
  }

  dimension: rankGroup {}

  measure: airport_total_departures_count{
    type: sum
    sql: ${airport_departures_count} ;;
  }

  measure: airport_total_destinations_count{
    type: sum
    sql: ${airport_arrivals_count} ;;
  }

}
