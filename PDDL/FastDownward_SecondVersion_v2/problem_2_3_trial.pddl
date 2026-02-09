(define (problem trial)
    (:domain ricochet_robot_fastdownward_no_charge_second_version)
(:objects
    red black - robot
    ; Grid cells c_i_j
    c_1_1 c_1_2 c_1_3
    c_2_1 c_2_2 c_2_3
    - cell
)

(:init
    ; Walls on the grid perimeter
    (wall_to_the_left_of c_1_1)
    (wall_to_the_right_of c_1_3)
    (wall_to_the_left_of c_2_1)
    (wall_to_the_right_of c_2_3)
    (wall_to_the_top_of c_1_1)
    (wall_to_the_bottom_of c_2_1)
    (wall_to_the_top_of c_1_2)
    (wall_to_the_bottom_of c_2_2)
    (wall_to_the_top_of c_1_3)
    (wall_to_the_bottom_of c_2_3)

    ; Adjacent cells
    (cell_adj_to_the_right_of c_1_1 c_1_2)
    (cell_adj_to_the_left_of c_1_2 c_1_1)
    (cell_adj_to_the_bottom_of c_1_1 c_2_1)
    (cell_adj_to_the_top_of c_2_1 c_1_1)
    (cell_adj_to_the_right_of c_1_2 c_1_3)
    (cell_adj_to_the_left_of c_1_3 c_1_2)
    (cell_adj_to_the_bottom_of c_1_2 c_2_2)
    (cell_adj_to_the_top_of c_2_2 c_1_2)
    (cell_adj_to_the_bottom_of c_1_3 c_2_3)
    (cell_adj_to_the_top_of c_2_3 c_1_3)
    (cell_adj_to_the_right_of c_2_1 c_2_2)
    (cell_adj_to_the_left_of c_2_2 c_2_1)
    (cell_adj_to_the_right_of c_2_2 c_2_3)
    (cell_adj_to_the_left_of c_2_3 c_2_2)

    ; Cells between others on same row
    (cell_between_row_of c_1_1 c_1_3 c_1_2)
    (cell_between_row_of c_1_3 c_1_1 c_1_2)
    (cell_between_row_of c_2_1 c_2_3 c_2_2)
    (cell_between_row_of c_2_3 c_2_1 c_2_2)


    (robot_at red c_1_1)
    (occupied c_1_1)
    (visited red c_1_1)

    (robot_at black c_2_2)
    (occupied c_2_2)
    (visited black c_2_2)

    (wall_to_the_bottom_of c_1_1)
    (wall_to_the_top_of c_2_1)

)   

(:goal(and(visited red c_2_1))
    )
    (:metric minimize
        (total-cost)
    )

)