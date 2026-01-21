(define (domain ricochet_robot)

    (:requirements
  	:numeric-fluents
        :adl
        :equality
        :typing
    )

    (:types robot cell - object

    )

    (:predicates
     (robot_at ?r - robot ?c - cell)
     (occupied ?c - cell)
     (cell_aligned_to_the_right_of ?c1 - cell ?c2 - cell)
     (cell_aligned_to_the_top_of ?c1 - cell ?c2 - cell)
     (cell_aligned_to_the_left_of ?c1 - cell ?c2 - cell)
     (cell_aligned_to_the_bottom_of ?c1 - cell ?c2 - cell)
     (wall_to_the_right_of ?c - cell)
     (wall_to_the_left_of ?c - cell)
     (wall_to_the_top_of ?c - cell)
     (wall_to_the_bottom_of ?c - cell)
     (cell_adj_to_the_top_of ?c1 - cell ?c2 - cell)
     (cell_adj_to_the_bottom_of ?c1 - cell ?c2 - cell)
     (cell_adj_to_the_right_of ?c1 - cell ?c2 - cell)
     (cell_adj_to_the_left_of ?c1 - cell ?c2 - cell)
     
     (charging_station_cell ?c - cell)
    )
    
    
	
(:functions (total-cost) - number
    		(battery_level ?r - robot) - number
    		(max_battery_level) - number
    		(necessary_battery_level) - number
    )

    (:action slide_right
  :parameters (?r - robot ?from - cell ?to - cell)
  :precondition
    (and
      (robot_at ?r ?from)
      (>=(battery_level ?r)(necessary_battery_level))
      ;; ostacolo finale (muro o robot)
      (or
        (wall_to_the_right_of ?to)
        (exists (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_right_of ?to ?c)
          )
        )
      )

      ;; free_line_right (logica inline)
      (and
        (cell_aligned_to_the_right_of ?from ?to)
        (not (= ?from ?to))

        (forall (?c - cell)
          (or
            (not (and
                   (cell_aligned_to_the_right_of ?from ?c)
                   (not (cell_aligned_to_the_right_of ?to ?c))
                 ))
            (and
              (not (occupied ?c))
              (not (wall_to_the_left_of ?c))
            )
          )
        )
      )
    )
  :effect
    (and
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (decrease (battery_level ?r) (necessary_battery_level))
      (increase (total-cost) 1)
    )
)
(:action slide_down
  :parameters (?r - robot ?from - cell ?to - cell)
  :precondition
    (and
      (robot_at ?r ?from)
      (>=(battery_level ?r)(necessary_battery_level))
      (or
        (wall_to_the_bottom_of ?to)
        (exists (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_bottom_of ?to ?c)
          )
        )
      )

      (and
        (cell_aligned_to_the_bottom_of ?from ?to)
        (not (= ?from ?to))

        (forall (?c - cell)
          (or
            (not (and
                   (cell_aligned_to_the_bottom_of ?from ?c)
                   (not (cell_aligned_to_the_bottom_of ?to ?c))
                 ))
            (and
              (not (occupied ?c))
              (not (wall_to_the_top_of ?c))
            )
          )
        )
      )
    )
  :effect
    (and
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (decrease (battery_level ?r) (necessary_battery_level))
      (increase (total-cost) 1)
    )
)

(:action slide_up
  :parameters (?r - robot ?from - cell ?to - cell)
  :precondition
    (and
      (robot_at ?r ?from)
      (>=(battery_level ?r)(necessary_battery_level))

      (or
        (wall_to_the_top_of ?to)
        (exists (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_top_of ?to ?c)
          )
        )
      )

      (and
        (cell_aligned_to_the_top_of ?from ?to)
        (not (= ?from ?to))

        (forall (?c - cell)
          (or
            (not (and
                   (cell_aligned_to_the_top_of ?from ?c)
                   (not (cell_aligned_to_the_top_of ?to ?c))
                 ))
            (and
              (not (occupied ?c))
              (not (wall_to_the_bottom_of ?c))
            )
          )
        )
      )
    )
  :effect
    (and
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (decrease (battery_level ?r) (necessary_battery_level))
      (increase (total-cost) 1)
    )
)
(:action slide_left
  :parameters (?r - robot ?from - cell ?to - cell)
  :precondition
    (and
      (robot_at ?r ?from)
      (>=(battery_level ?r)(necessary_battery_level))

      (or
        (wall_to_the_left_of ?to)
        (exists (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_left_of ?to ?c)
          )
        )
      )

      (and
        (cell_aligned_to_the_left_of ?from ?to)
        (not (= ?from ?to))

        (forall (?c - cell)
          (or
            (not (and
                   (cell_aligned_to_the_left_of ?from ?c)
                   (not (cell_aligned_to_the_left_of ?to ?c))
                 ))
            (and
              (not (occupied ?c))
              (not (wall_to_the_right_of ?c))
            )
          )
        )
      )
    )
  :effect
    (and
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (decrease (battery_level ?r) (necessary_battery_level))
      (increase (total-cost) 1)
    )
)

(:action recharge
:parameters(?r - robot ?c - cell)
:precondition(and(robot_at ?r ?c)(charging_station_cell ?c))
:effect(and(assign (battery_level ?r)(max_battery_level))(increase (total-cost) 2))
)





)
