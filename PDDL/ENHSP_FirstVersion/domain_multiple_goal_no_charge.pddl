(define (domain ricochet_robot_enhsp_no_charge_first_version)

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

    (visited ?r - robot ?c - cell) ;Robot r has visited cell c
    (visit_before ?r - robot ?c1 - cell ?c2 - cell) ;Robot r has to visit cell c1 before reaching cell c2
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

      ;This is the inline version of the derived predicates that verifies if the path between the cells "?from" and "?to" is free from any type of obstacle
      (and
        (cell_aligned_to_the_right_of ?from ?to) ;The cell "?to" is on the right side of the cell "?from" and in the same row
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to",it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_right_of ?from ?c)
                (not (cell_aligned_to_the_right_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the left side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_left_of ?c))
            ))))

      (robot_at ?r ?from) ;robot r is at cell "?from"
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
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

      ;This is the inline version of the derived predicates that verifies if the path between the cells "?from" and "?to" is free from any type of obstacle
      (and
        (cell_aligned_to_the_bottom_of ?from ?to) ;The cell "?to" is below the cell "?from" and in the same column
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to",it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_bottom_of ?from ?c)
                (not (cell_aligned_to_the_bottom_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the top side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_top_of ?c))
            ))))

      (robot_at ?r ?from) ;robot r is at cell "?from"
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
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

      ;This is the inline version of the derived predicates that verifies if the path between the cells "?from" and "?to" is free from any type of obstacle
      (and
        (cell_aligned_to_the_top_of ?from ?to) ;The cell "?to" is above the cell "?from" and in the same column
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to",it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_top_of ?from ?c)
                (not (cell_aligned_to_the_top_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the bottom side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_bottom_of ?c))
            ))))

      (robot_at ?r ?from) ;robot r is at cell "?from"
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
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

      ;This is the inline version of the derived predicates that verifies if the path between the cells "?from" and "?to" is free from any type of obstacle
      (and
        (cell_aligned_to_the_left_of ?from ?to) ;The cell "?to" is on the left side of the cell "?from" and in the same row
        (not (= ?from ?to))

        (forall ;For all the cells "?c" that are between "?from" and "?to",it must be free from any obstacle to allow the slide action
          (?c - cell)
          (or
            (not (and ;If the cell "?c" is between "?from" and "?to" it IMPLIES that...
                (cell_aligned_to_the_left_of ?from ?c)
                (not (cell_aligned_to_the_left_of ?to ?c))
              ))
            (and ;...the cell "?c" must be free from any obstacle (not occupied and no wall on the right side that can block the slide)
              (not (occupied ?c))
              (not (wall_to_the_right_of ?c))
            ))))

      (robot_at ?r ?from) ;robot r is at cell "?from"
    )
    :effect (and ;the robot is no more in the "?from" cell and is now in the "?to" cell and the "?to" cell is now occupied and visited
      (not (robot_at ?r ?from))
      (not (occupied ?from))
      (robot_at ?r ?to)
      (occupied ?to)
      (visited ?r ?to)
      (increase (total-cost) 1) ;increase the total cost of the plan by 1 unit
    )
  )

)