(define (domain ricochet_robot_enhsp_with_charge_first_version)

  (:requirements :numeric-fluents :adl :equality :typing
  )

  (:types
    robot cell - object

  )

  (:predicates
    (robot_at ?r - robot ?c - cell) ;Robot r is at cell c
    (occupied ?c - cell) ;Cell c is occupied by something (than can be either a robot or an obstacle)
    (cell_aligned_to_the_right_of ?c1 - cell ?c2 - cell) ;cell c2 is in the same row and on the right side of cell c1
    (cell_aligned_to_the_top_of ?c1 - cell ?c2 - cell) ;cell c2 is in the same coloumn and above cell c1
    (cell_aligned_to_the_left_of ?c1 - cell ?c2 - cell) ;cell c2 is in the same row and on the left side of cell c1
    (cell_aligned_to_the_bottom_of ?c1 - cell ?c2 - cell) ;cell c2 is in the same coloumn and below cell c1
    (wall_to_the_right_of ?c - cell) ;there is a wall to the right side of cell c
    (wall_to_the_left_of ?c - cell) ;there is a wall to the left side of cell c
    (wall_to_the_top_of ?c - cell) ;there is a wall to the top side of cell c
    (wall_to_the_bottom_of ?c - cell) ;there is a wall to the bottom side of cell c
    (cell_adj_to_the_top_of ?c1 - cell ?c2 - cell) ;cell c2 is above the cell c1 and they are adjacent
    (cell_adj_to_the_bottom_of ?c1 - cell ?c2 - cell) ;cell c2 is below the cell c1 and they are adjacent
    (cell_adj_to_the_right_of ?c1 - cell ?c2 - cell) ;cell c2 is on the right side of cell c1 and they are adjacent
    (cell_adj_to_the_left_of ?c1 - cell ?c2 - cell) ;cell c2 is on the left side of cell c1 and they are adjacent

    (charging_station_cell ?c - cell) ;In cell c there is a charging station

    (visited ?r - robot ?c - cell) ;Robot r has visited cell c
    (visit_before ?r - robot ?c1 - cell ?c2 - cell) ;Robot r has to visit cell c1 before reaching cell c2
  )

  (:functions
    (total-cost) - number
    (battery_level ?r - robot) - number
    (max_battery_level) - number
    (necessary_battery_level) - number
  )

  (:action slide_right ;move robot r by sliding right until an obstacle (like a robot) or a wall is reached
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and

      (not (exists ;there is no cell c that robot r has to visit before reaching the cell "?to"
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or ;there is either a wall or an obstacle to the right of the "?to" cell that stops the robot
        (wall_to_the_right_of ?to)
        (exists
          (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_right_of ?to ?c)
          )))

      ;This is the inline version of the derived predicates that verifies if the path between "?from" and "?to" (endpoints excluded) is in the same row, in the direction "right" and it is free from any type of obstacle
      (and
        (cell_aligned_to_the_right_of ?from ?to) ;The cell "?to" is on the right side of the cell "?from" and in the same row
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to" in the same row, it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (= ?c ?from) ;the cell "?from" is not considered in the check for the free path
            (= ?c ?to) ;the cell "?to" is not considered in the check for the free path
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_right_of ?from ?c)
                (not (cell_aligned_to_the_right_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the left and right side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_right_of ?c))
              (not (wall_to_the_left_of ?c))
            ))))

      (cell_aligned_to_the_right_of ?from ?to) ;"?to" cell is on the right side of the "?from" cell and in the same row
      (not (wall_to_the_right_of ?from)) ;there is no wall to the right of the "?from" cell that can block the slide action at the beginning of the movement
      (not(occupied ?to)) ;"?to" cell is not occupied

      (robot_at ?r ?from) ;robot r is at cell "?from"
      (>= (battery_level ?r) (necessary_battery_level)) ;The robot r has enough battery (necessary_battery_level) to execute the slide action
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
      (decrease
        ;In order to perform the action, the robot r consumes energy equal to necessary_battery_level
        (battery_level ?r)
        (necessary_battery_level))
      (increase (total-cost) 1) ;increase the total cost of the plan by 1 unit
    )
  )

  (:action slide_down ;move robot r by sliding down until an obstacle (like a robot) or a wall is reached
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and

      (not (exists ;there is no cell c that robot r has to visit before reaching the cell "?to"
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or ;there is either a wall or an obstacle to the bottom of the "?to" cell that stops the robot
        (wall_to_the_bottom_of ?to)
        (exists
          (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_bottom_of ?to ?c)
          )))

      ;This is the inline version of the derived predicates that verifies if the path between "?from" and "?to" (endpoints excluded) is in the same column, in the direction "down" and it is free from any type of obstacle
      (and
        (cell_aligned_to_the_bottom_of ?from ?to) ;The cell "?to" is below the cell "?from" and in the same column
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to" in the same column, it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (= ?c ?from) ;the cell "?from" is not considered in the check for the free path
            (= ?c ?to) ;the cell "?to" is not considered in the check for the free path
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_bottom_of ?from ?c)
                (not (cell_aligned_to_the_bottom_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the top and bottom side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_top_of ?c))
              (not (wall_to_the_bottom_of ?c))
            ))))
      
      (cell_aligned_to_the_bottom_of ?from ?to) ;"?to" cell is below the "?from" cell and in the same column
      (not (wall_to_the_bottom_of ?from)) ;there is no wall to the bottom of the "?from" cell that can block the slide action at the beginning of the movement
      (not(occupied ?to)) ;"?to" cell is not occupied 

      (robot_at ?r ?from) ;robot r is at cell "?from"
      (>= (battery_level ?r) (necessary_battery_level)) ;The robot r has enough battery (necessary_battery_level) to execute the slide action
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
      (decrease
        ;In order to perform the action, the robot r consumes energy equal to necessary_battery_level
        (battery_level ?r)
        (necessary_battery_level))
      (increase (total-cost) 1) ;increase the total cost of the plan by 1 unit
    )
  )

  (:action slide_up ;move robot r by sliding up until an obstacle (like a robot) or a wall is reached
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and

      (not (exists ;there is no cell c that robot r has to visit before reaching the cell "?to"
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or ;there is either a wall or an obstacle to the top of the "?to" cell that stops the robot
        (wall_to_the_top_of ?to)
        (exists
          (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_top_of ?to ?c)
          )))

      ;This is the inline version of the derived predicates that verifies if the path between "?from" and "?to" (endpoints excluded) is in the same column, in the direction "up" and it is free from any type of obstacle
      (and
        (cell_aligned_to_the_top_of ?from ?to) ;The cell "?to" is above the cell "?from" and in the same column
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to" in the same column, it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (= ?c ?from) ;the cell "?from" is not considered in the check for the free path
            (= ?c ?to) ;the cell "?to" is not considered in the check for the free path
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_top_of ?from ?c)
                (not (cell_aligned_to_the_top_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the bottom and top side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_top_of ?c))
              (not (wall_to_the_bottom_of ?c))
            ))))

      (cell_aligned_to_the_top_of ?from ?to) ;the cell "?to" is above the cell "?from" and in the same column
      (not (wall_to_the_top_of ?from)) ;there is no wall to the top of the "?from" cell that can block the slide action at the beginning of the movement
      (not(occupied ?to)) ;"?to" cell is not occupied

      (robot_at ?r ?from) ;robot r is at cell "?from"
      (>= (battery_level ?r) (necessary_battery_level)) ;The robot r has enough battery (necessary_battery_level) to execute the slide action
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
      (decrease
        ;In order to perform the action, the robot r consumes energy equal to necessary_battery_level
        (battery_level ?r)
        (necessary_battery_level))
      (increase (total-cost) 1) ;increase the total cost of the plan by 1 unit
    )
  )

  (:action slide_left ;move robot r by sliding left until an obstacle (like a robot) or a wall is reached
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and

      (not (exists ;there is no cell c that robot r has to visit before reaching the cell "?to"
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or ;there is either a wall or an obstacle to the left of the "?to" cell that stops the robot
        (wall_to_the_left_of ?to)
        (exists
          (?c - cell)
          (and
            (occupied ?c)
            (cell_adj_to_the_left_of ?to ?c)
          )))

      ;This is the inline version of the derived predicates that verifies if the path between "?from" and "?to" (endpoints excluded) is in the same row, in the direction "left" and it is free from any type of obstacle
      (and
        (cell_aligned_to_the_left_of ?from ?to) ;The cell "?to" is on the left side of the cell "?from" and in the same row
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to" in the same row, it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (= ?c ?from) ;the cell "?from" is not considered in the check for the free path
            (= ?c ?to) ;the cell "?to" is not considered in the check for the free path
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_left_of ?from ?c)
                (not (cell_aligned_to_the_left_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the right and left side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_right_of ?c))
              (not (wall_to_the_left_of ?c))
            ))))

      (cell_aligned_to_the_left_of ?from ?to) ;the cell "?to" is on the left side of the cell "?from" and in the same row
      (not (wall_to_the_left_of ?from)) ;there is no wall to the left of the "?from" cell that can block the slide action at the beginning of the movement
      (not(occupied ?to)) ;"?to" cell is not occupied

      (robot_at ?r ?from) ;robot r is at cell "?from"
      (>= (battery_level ?r) (necessary_battery_level)) ;The robot r has enough battery (necessary_battery_level) to execute the slide action
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
      (decrease
        ;In order to perform the action, the robot r consumes energy equal to necessary_battery_level
        (battery_level ?r)
        (necessary_battery_level))
      (increase (total-cost) 1) ;increase the total cost of the plan by 1 unit
    )
  )

  (:action recharge ;recharge the battery of robot r of the amount "max_battery_level"
    :parameters (?r - robot ?c - cell)
    :precondition (and ;the robot r is in a cell that houses a charging station
      (robot_at ?r ?c)
      (charging_station_cell ?c)
    )
    :effect (and
      (assign (battery_level ?r) (max_battery_level)) ;the battery level of robot r is set to max_battery_level
    )
  )

)