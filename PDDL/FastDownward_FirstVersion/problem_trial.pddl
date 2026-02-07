(define (problem uno)
        (:domain ricochet_robot_fastdownward_no_charge)
        (:objects
                red black - robot
                c1 c2 c3 c4 c5 - cell
        )

        (:init
                (wall_to_the_left_of c1)
                (wall_to_the_left_of c5)
                (wall_to_the_top_of c1)
                (wall_to_the_top_of c2)
                (wall_to_the_top_of c3)
                (wall_to_the_top_of c4)
                (wall_to_the_right_of c4)
                (wall_to_the_right_of c5)
                (wall_to_the_bottom_of c1)
                (wall_to_the_bottom_of c2)
                (wall_to_the_bottom_of c3)
                (wall_to_the_bottom_of c5)

                (cell_adj_to_the_right_of c1 c2)(cell_adj_to_the_right_of c2 c3)(cell_adj_to_the_right_of c3 c4)
                (cell_adj_to_the_left_of c4 c3)(cell_adj_to_the_left_of c3 c2)
                (cell_adj_to_the_left_of c2 c1)
                (cell_adj_to_the_top_of c5 c4)
                (cell_adj_to_the_bottom_of c4 c5)

                (cell_aligned_to_the_right_of c1 c2)
                (cell_aligned_to_the_right_of c1 c3)(cell_aligned_to_the_right_of c1 c4)
                (cell_aligned_to_the_left_of c2 c1)
                (cell_aligned_to_the_right_of c2 c3)
                (cell_aligned_to_the_right_of c2 c4)
                (cell_aligned_to_the_left_of c3 c1)
                (cell_aligned_to_the_left_of c3 c2)
                (cell_aligned_to_the_right_of c3 c4)
                (cell_aligned_to_the_left_of c4 c1)
                (cell_aligned_to_the_left_of c4 c2)
                (cell_aligned_to_the_left_of c4 c3)

                (cell_aligned_to_the_top_of c5 c4)
                (cell_aligned_to_the_bottom_of c4 c5)

                (robot_at red c2)
                (= (battery_level red) 10)
                (= (necessary_battery_level) 1)
                (= (max_battery_level) 10)
                (occupied c2)
                (robot_at black c4)
                (occupied c4)

        )

        (:goal(and(robot_at red c4))
        )
)