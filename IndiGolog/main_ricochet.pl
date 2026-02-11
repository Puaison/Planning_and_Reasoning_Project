%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD INDIGOLOG PLAIN (OFFLINE) + DOMAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dir(indigolog_plain, F), consult(F).
:- [ricochet].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN (controllers)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
    findall(C, proc(control(C), _), L),
    repeat,
    format('Controllers available: ~w~n', [L]),
    write('Select controller (atom, e.g. test_reach_station): '),
    read(S), nl,
    member(S, L),
    format('Executing controller: *~w*~n', [S]), !,
    indigolog(control(S)).

main(C) :-
    format('Executing controller: *~w*~n', [C]),
    indigolog(control(C)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFFLINE TASKS (Legality + Projection) via simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rr_init_state(st(PR, PB, PBu, B, MC, SID)) :-
    initially(pos(red), PR),
    initially(pos(black), PB),
    initially(pos(blue), PBu),
    initially(battery_red, B),
    initially(move_count, MC),
    initially(station_id, SID).

rr_occ_without(red,   _PR, PB, PBu, [PB, PBu]).
rr_occ_without(black, PR, _PB, PBu, [PR, PBu]).
rr_occ_without(blue,  PR, PB, _PBu, [PR, PB]).

rr_get_pos(red,   st(PR,_,_,_,_,_), PR).
rr_get_pos(black, st(_,PB,_,_,_,_), PB).
rr_get_pos(blue,  st(_,_,PBu,_,_,_), PBu).

rr_set_pos(red,   New, st(_PR,PB,PBu,B,MC,SID), st(New,PB,PBu,B,MC,SID)).
rr_set_pos(black, New, st(PR,_PB,PBu,B,MC,SID), st(PR,New,PBu,B,MC,SID)).
rr_set_pos(blue,  New, st(PR,PB,_PBu,B,MC,SID), st(PR,PB,New,B,MC,SID)).

rr_set_battery(NewB, st(PR,PB,PBu,_B,MC,SID), st(PR,PB,PBu,NewB,MC,SID)).
rr_inc_mc(st(PR,PB,PBu,B,MC,SID), st(PR,PB,PBu,B,MC2,SID)) :- MC2 is MC + 1.

% --- executability (legality) ---

rr_executable(move(red,_D),  st(_PR,_PB,_PBu,B,_MC,_SID)) :- B =\= 0.
rr_executable(move(black,_), _).
rr_executable(move(blue,_),  _).

rr_executable(recharge, st(PR,_PB,_PBu,B,_MC,SID)) :-
    PR =:= SID,
    B =\= 10.

rr_executable(set_battery(_), _).

% --- transition (apply one action) ---

rr_apply(move(R,D), S0, S2) :-
    rr_get_pos(R, S0, CurrID),
    S0 = st(PR,PB,PBu,B,MC,SID),
    rr_occ_without(R, PR, PB, PBu, Occ),
    dynamic_stop_id(CurrID, D, Occ, NewID),
    ( NewID =:= CurrID -> fail ; true ),           
    rr_set_pos(R, NewID, S0, S1),
    rr_inc_mc(S1, S1a),
    ( R == red ->
        B2 is B - 1,
        rr_set_battery(B2, S1a, S2)
    ;   S2 = S1a
    ).

rr_apply(recharge, S0, S1) :-
    rr_set_battery(10, S0, S1).

rr_apply(set_battery(NewB), S0, S1) :-
    rr_set_battery(NewB, S0, S1).

% --- simulate a whole sequence ---

rr_simulate(SEQ, SF) :-
    rr_init_state(S0),
    rr_simulate_from(SEQ, S0, SF).

rr_simulate_from([], S, S).
rr_simulate_from([A|Rest], S0, SF) :-
    rr_executable(A, S0),
    rr_apply(A, S0, S1),
    rr_simulate_from(Rest, S1, SF).

% printer for final state
rr_print_state(st(PR,PB,PBu,B,MC,SID)) :-
    format("Final state: PR=~w PB=~w PBu=~w Bred=~w MC=~w SID=~w~n",
           [PR,PB,PBu,B,MC,SID]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TASKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

legality_task :-
    format("Write the sequence of actions '[a1(), ..., an()].' :~n", []),
    read(SEQ), nl,
    (   rr_simulate(SEQ, SF)
    ->  format("Sequence ~w IS EXECUTABLE~n", [SEQ]),
        rr_print_state(SF)
    ;   format("Sequence ~w is NOT executable~n", [SEQ])
    ).

projection_task_charge :-
    format("Write the sequence of actions '[a1(), ..., an()].' :~n", []),
    read(SEQ), nl,
    (   rr_simulate(SEQ, st(_PR,_PB,_PBu,B,_MC,_SID))
    ->  ( B =\= 0
        -> format("After executing ~w, red STILL HAS CHARGE (battery=~w).~n", [SEQ, B])
        ;  format("After executing ~w, red has NO CHARGE (battery=0).~n", [SEQ])
        )
    ;   format("Sequence ~w is NOT executable, so projection is undefined.~n", [SEQ])
    ).

goal_in_to_id(ID, ID) :-
    integer(ID), ID >= 1, ID =< 16, !.

goal_in_to_id(c(R,C), ID) :-
    integer(R), integer(C),
    between(1,4,R), between(1,4,C),
    pos_to_id(c(R,C), ID), !.

goal_in_to_id(Other, _) :-
    format("ERROR: invalid goal-position input: ~w~n", [Other]),
    fail.

projection_task_not_reached :-
    format("Write the goal-position (ID 1..16 or c(R,C)). Example: 4. or c(1,4).~n", []),
    read(GOAL_IN), nl,
    goal_in_to_id(GOAL_IN, GID),
    format("Write the sequence of actions '[a1(), ..., an()].' :~n", []),
    read(SEQ), nl,
    (   rr_simulate(SEQ, st(PR,_PB,_PBu,_B,_MC,_SID))
    ->  ( PR =\= GID
        -> format("After executing ~w, red HAS NOT reached goal-position ~w (ID=~w). Final PR=~w.~n",
                  [SEQ, GOAL_IN, GID, PR])
        ;  format("After executing ~w, red HAS reached goal-position ~w (ID=~w).~n",
                  [SEQ, GOAL_IN, GID])
        )
    ;   format("Sequence ~w is NOT executable, so projection is undefined.~n", [SEQ])
    ).