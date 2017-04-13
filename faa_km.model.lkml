connection: "red_flight"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: accidents {}

explore: aircraft {}

explore: aircraft_models {}

explore: airports {}

explore: cal454 {}

explore: carriers {}

explore: flights {
  fields: [ALL_FIELDS*,-flights.origin,-flights.id2]
  join: origin_airport {
    from: airports
    relationship: many_to_one
    sql_on: ${origin_airport.code}=${flights.origin} ;;
  }

  join: airports_facts {
    relationship: many_to_one
    sql_on: ${origin_airport.code}=${airports_facts.airport} ;;
  }

}

explore: flights_by_day {}

explore: ontime {}

explore: temp2 {}
