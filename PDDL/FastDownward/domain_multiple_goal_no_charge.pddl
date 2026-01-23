(define (domain ricochet_robot)

  (:requirements :derived-predicates :adl :equality :typing
  )

  (:types
    robot cell - object

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

    (free_line_right ?from - cell ?to - cell)
    (free_line_left ?from - cell ?to - cell)
    (free_line_top ?from - cell ?to - cell)
    (free_line_bottom ?from - cell ?to - cell)

    (visited ?r - robot ?c - cell)
    (visit_before ?r - robot ?c1 - cell ?c2 - cell)
  )

  (:derived
    (free_line_right ?from - cell ?to - cell)
    (and
      (cell_aligned_to_the_right_of ?from ?to)
      (not (= ?from ?to))
      (forall
        (?c - cell)
        (or
          (not (and(cell_aligned_to_the_right_of ?from ?c)
              (not(cell_aligned_to_the_right_of ?to ?c))))
          (and(not (occupied ?c))
            (not(wall_to_the_left_of ?c)))
        )
      ))
  )

  (:derived
    (free_line_left ?from - cell ?to - cell)
    (and
      (cell_aligned_to_the_left_of ?from ?to)
      (not (= ?from ?to))
      (forall
        (?c - cell)
        (or
          (not (and(cell_aligned_to_the_left_of ?from ?c)
              (not(cell_aligned_to_the_left_of ?to ?c))))
          (and(not (occupied ?c))
            (not(wall_to_the_right_of ?c)))
        )
      ))
  )

  (:derived
    (free_line_top ?from - cell ?to - cell)
    (and
      (cell_aligned_to_the_top_of ?from ?to)
      (not (= ?from ?to))
      (forall
        (?c - cell)
        (or
          (not (and(cell_aligned_to_the_top_of ?from ?c)
              (not(cell_aligned_to_the_top_of ?to ?c))))
          (and(not (occupied ?c))
            (not(wall_to_the_bottom_of ?c)))
        )
      ))
  )

  (:derived
    (free_line_bottom ?from - cell ?to - cell)
    (and
      (cell_aligned_to_the_bottom_of ?from ?to)
      (not (= ?from ?to))
      (forall
        (?c - cell)
        (or
          (not (and(cell_aligned_to_the_bottom_of ?from ?c)
              (not(cell_aligned_to_the_bottom_of ?to ?c))))
          (and(not (occupied ?c))
            (not(wall_to_the_top_of ?c)))
        )
      ))
  )

  (:action slide_right
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and

      (not (exists
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or(wall_to_the_right_of ?to)
        (exists
          (?c - cell)
          (and(occupied ?c)(cell_adj_to_the_right_of ?to ?c)))) (robot_at ?r ?from)(free_line_right ?from ?to))
    :effect (and (not(robot_at ?r ?from))
      (visited ?r ?to)
      (not(occupied ?from))(robot_at ?r ?to)(occupied ?to)
      (increase (total-cost) 1)
    )
  )

  (:action slide_left
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and
      (not (exists
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or(wall_to_the_left_of ?to)
        (exists
          (?c - cell)
          (and(occupied ?c)(cell_adj_to_the_left_of ?to ?c)))) (robot_at ?r ?from)(free_line_left ?from ?to))
    :effect (and (not(robot_at ?r ?from))
      (visited ?r ?to)
      (not(occupied ?from))(robot_at ?r ?to)(occupied ?to)
      (increase (total-cost) 1)
    )
  )

  (:action slide_up
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and
      (not (exists
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))
      (or(wall_to_the_top_of ?to)
        (exists
          (?c - cell)
          (and(occupied ?c)(cell_adj_to_the_top_of ?to ?c)))) (robot_at ?r ?from)(free_line_top ?from ?to))
    :effect (and (not(robot_at ?r ?from))
      (visited ?r ?to)
      (not(occupied ?from))(robot_at ?r ?to)(occupied ?to)
      (increase (total-cost) 1)
    )
  )

  (:action slide_down
    :parameters (?r - robot ?from - cell ?to - cell)
    :precondition (and
      (not (exists
          (?c - cell)
          (and
            (visit_before ?r ?c ?to)
            (not (visited ?r ?c))
          )))

      (or(wall_to_the_bottom_of ?to)
        (exists
          (?c - cell)
          (and(occupied ?c)(cell_adj_to_the_bottom_of ?to ?c)))) (robot_at ?r ?from)(free_line_bottom ?from ?to))
    :effect (and (not(robot_at ?r ?from))
      (visited ?r ?to)
      (not(occupied ?from))(robot_at ?r ?to)(occupied ?to)
      (increase (total-cost) 1)
    )
  )
)