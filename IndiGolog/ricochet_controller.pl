:- discontiguous execute/2.
:- discontiguous exog_occurs/1.
:- discontiguous prim_action/1.
:- discontiguous initially/2.
:- discontiguous poss/2.
:- discontiguous causes_val/4.
:- discontiguous causes_true/3.
:- discontiguous causes_false/3.
:- discontiguous proc/2.
:- discontiguous fun_fluent/1.
:- discontiguous rel_fluent/1.
:- discontiguous target_id/1.

actionNum(X, X).
cache(_) :- fail.

% ------------------------------------------------------------------
% DOMAIN & GEOMETRY
% ------------------------------------------------------------------
target_id(N) :- between(1, 16, N).

pos_to_id(c(R,C), ID) :-
  integer(R), integer(C), between(1,4,R), between(1,4,C),
  ID is (R-1)*4 + C.

id_to_pos(ID, c(R,C)) :-
  integer(ID), ID >= 1, ID =< 16,
  R is ((ID-1)//4)+1, C is ((ID-1) mod 4)+1.

dir(n). dir(s). dir(e). dir(w).
robot(red). robot(black). robot(blue).
charging_station_id(4).

% Walls
wall_at(1,  C, n) :- between(1,4,C).
wall_at(4,  C, s) :- between(1,4,C).
wall_at(R,  1, w) :- between(1,4,R).
wall_at(R,  4, e) :- between(1,4,R).
wall_at(1,2,e). wall_at(1,3,w).
wall_at(2,2,e). wall_at(2,3,w).
wall_at(2,3,s). wall_at(3,3,n).
wall_at(3,1,s). wall_at(4,1,n).

next_step(R,C,n, R2,C) :- R2 is R-1.
next_step(R,C,s, R2,C) :- R2 is R+1.
next_step(R,C,e, R,C2) :- C2 is C+1.
next_step(R,C,w, R,C2) :- C2 is C-1.
opposite(n,s). opposite(s,n). opposite(e,w). opposite(w,e).

% ------------------------------------------------------------------
% ACTIONS
% ------------------------------------------------------------------
prim_action(move(R,D)) :- robot(R), dir(D).
prim_action(recharge).
prim_action(set_battery(B)) :- integer(B).
prim_action(say(S)).
prim_action(show_report).

% Exogenous Actions
exog_action(add_goal(N))      :- target_id(N).
exog_action(stop_game).
exog_action(spawn_robot(R,N)) :- robot(R), target_id(N).
exog_action(despawn_robot(R)) :- robot(R).

prim_action(add_goal(N))      :- exog_action(add_goal(N)).
prim_action(stop_game)        :- exog_action(stop_game).
prim_action(spawn_robot(R,N)) :- exog_action(spawn_robot(R,N)).
prim_action(despawn_robot(R)) :- exog_action(despawn_robot(R)).

prim_action(dismiss_goal(N)) :- target_id(N).
prim_action(unset_new_goal_event).
prim_action(wait_exog_action).

% ------------------------------------------------------------------
% FLUENTS
% ------------------------------------------------------------------
fun_fluent(pos(R)) :- robot(R).
fun_fluent(battery_red).
fun_fluent(move_count).
fun_fluent(station_id).
fun_fluent(active_goals).

rel_fluent(goal_active(_)). 
rel_fluent(new_goal_event).
rel_fluent(stop_requested).
rel_fluent(robot_config_changed).

% ------------------------------------------------------------------
% INITIAL STATE
% ------------------------------------------------------------------
initially(pos(red),   2).
initially(pos(blue),  7).
initially(pos(black), 9).
initially(battery_red, 10).
initially(move_count, 0).
initially(station_id, 4).

initially(goal_active(_), false).
initially(new_goal_event, false).
initially(active_goals, []).
initially(stop_requested, false).
initially(robot_config_changed, false).

% ------------------------------------------------------------------
% PRECONDITIONS & EFFECTS
% ------------------------------------------------------------------
poss(move(red,_), and(pos(red)>0, neg(battery_red=0))).
poss(move(R,_), pos(R)>0) :- robot(R), R \= red.
poss(recharge, and(pos(red)=ID, and(station_id=ID, neg(battery_red=10)))).
poss(set_battery(_), true).
poss(say(_), true).
poss(show_report, true).

poss(add_goal(_), true).
poss(stop_game, true).
poss(spawn_robot(_,_), true).
poss(despawn_robot(_), true).

poss(dismiss_goal(N), pos(red)=N).
poss(unset_new_goal_event, true).
poss(wait_exog_action, true).

% Physics Effects
causes_val(move(R,D), pos(R), NewID, (
  pos(red)=PR, pos(black)=PB, pos(blue)=PBu,
  occ_ids_without(R, PR, PB, PBu, Occ),
  pos(R)=CurrID,
  dynamic_stop_id(CurrID, D, Occ, NewID)
)).
causes_val(move(red,_), battery_red, B2, (battery_red=B1, B2 is B1 - 1)).
causes_val(recharge,    battery_red, 10, true).
causes_val(move(_,_), move_count, C2, (move_count=C1, C2 is C1 + 1)).

% Spawn/Despawn
causes_val(spawn_robot(R, N), pos(R), N, true).
causes_val(despawn_robot(R), pos(R), 0, true).
causes_true(spawn_robot(_,_), robot_config_changed, true).
causes_true(despawn_robot(_), robot_config_changed, true).

% Goal/Stop Management
causes_true(add_goal(N), goal_active(N), true).
causes_true(add_goal(_), new_goal_event, true).
causes_true(stop_game, stop_requested, true).

causes_false(dismiss_goal(N), goal_active(N), true).
causes_false(unset_new_goal_event, new_goal_event, true).
causes_false(unset_new_goal_event, robot_config_changed, true).

causes_val(add_goal(N), active_goals, NewL, 
    (active_goals=L, (member(N,L) -> NewL=L ; NewL=[N|L]))).
causes_val(dismiss_goal(N), active_goals, NewL, 
    (active_goals=L, delete(L, N, NewL))).

% ------------------------------------------------------------------
% STOP COMPUTATION
% ------------------------------------------------------------------
active_robot_pos(P) :- integer(P), P > 0.

occ_ids_without(red,   _PR, PB, PBu, Occ) :- 
    findall(P, (member(P, [PB, PBu]), active_robot_pos(P)), Occ).
occ_ids_without(black, PR, _PB, PBu, Occ) :- 
    findall(P, (member(P, [PR, PBu]), active_robot_pos(P)), Occ).
occ_ids_without(blue,  PR, PB, _PBu, Occ) :- 
    findall(P, (member(P, [PR, PB]),  active_robot_pos(P)), Occ).

static_stop_pos(c(R,C), D, c(FR,FC)) :-
  ( wall_at(R,C,D) -> FR=R, FC=C
  ; next_step(R,C,D, NR,NC), static_stop_pos(c(NR,NC), D, c(FR,FC)) ).

:- dynamic static_stop_id/3.
compute_static_stop_all :-
  retractall(static_stop_id(_,_,_)),
  forall((between(1,16,ID), dir(D)),
    (id_to_pos(ID, P), static_stop_pos(P, D, P2), pos_to_id(P2, SID), assertz(static_stop_id(ID,D,SID)))).
:- initialization(compute_static_stop_all).

ray_ids_until(StartID, D, StaticStopID, Ray) :-
  id_to_pos(StartID, c(R,C)), id_to_pos(StaticStopID, c(Rs,Cs)),
  ray_ids_until_pos(c(R,C), D, c(Rs,Cs), [], Rev), reverse(Rev, Ray).
ray_ids_until_pos(c(R,C), _D, c(R,C), Acc, Acc) :- !.
ray_ids_until_pos(c(R,C), D, Target, Acc, Out) :-
  next_step(R,C,D, R2,C2), pos_to_id(c(R2,C2), ID2),
  ray_ids_until_pos(c(R2,C2), D, Target, [ID2|Acc], Out).
first_hit([], _Occ, none).
first_hit([ID|Rest], Occ, Hit) :- (member(ID, Occ) -> Hit = ID ; first_hit(Rest, Occ, Hit)).

dynamic_stop_id(StartID, D, OccIDs, StopID) :-
  static_stop_id(StartID, D, StaticStopID),
  ray_ids_until(StartID, D, StaticStopID, Ray),
  first_hit(Ray, OccIDs, Hit),
  ( Hit = none -> StopID = StaticStopID
  ; id_to_pos(Hit, c(Rh,Ch)), opposite(D, Dopp),
    next_step(Rh,Ch,Dopp, Rs,Cs), pos_to_id(c(Rs,Cs), StopID) ).

% ------------------------------------------------------------------
% PROCEDURES
% ------------------------------------------------------------------
proc(reached_target(TargetID), [ ?(pos(red)=TargetID) ]).

proc(move_eff(R,D), [
  ?(pos(R)=ID0), ?(pos(R)>0),
  ?(pos(red)=PR), ?(pos(black)=PB), ?(pos(blue)=PBu),
  ?(occ_ids_without(R, PR, PB, PBu, Occ)),
  ?(dynamic_stop_id(ID0, D, Occ, FID)),
  ?(FID \= ID0),
  move(R,D)
]).

proc(any_move_eff,
  ndet(
    ndet(move_eff(red,n), ndet(move_eff(red,e), ndet(move_eff(red,s), move_eff(red,w)))),
    ndet(
        ndet(move_eff(black,n), ndet(move_eff(black,e), ndet(move_eff(black,s), move_eff(black,w)))),
        ndet(move_eff(blue,n), ndet(move_eff(blue,e), ndet(move_eff(blue,s), move_eff(blue,w))))
    )
  )
).

proc(solve_goal(TargetID, Max), [
  ndet(reached_target(TargetID),
    [ ?(Max > 0), any_move_eff, pi(m, [ ?(m is Max - 1), solve_goal(TargetID, m) ]) ])
]).

proc(find_path_to(TargetID, Max, Limit),
  ndet(solve_goal(TargetID, Max),
    [ ?(Max < Limit), pi(m, [?(m is Max+1), find_path_to(TargetID, m, Limit)]) ])
).

proc(serve_goal_plan(N), [
    say("Planning path..."),
    search(find_path_to(N, 0, 10), "Piano Trovato"),
    say("Goal reached!"),
    dismiss_goal(N)
]).

% ------------------------------------------------------------------
% CONTROLLERS
% ------------------------------------------------------------------
proc(some_pending, some(n, and(target_id(n), goal_active(n)))).

% 1. BASE: Finisce il goal corrente prima di ascoltare nuovi eventi
proc(control(base_ricochet), [
    prioritized_interrupts([
        interrupt(stop_requested, [ show_report, ?(fail) ]),
        interrupt(some_pending, 
            pi(n, [
                ?(and(target_id(n), goal_active(n))), 
                unset_new_goal_event,
                serve_goal_plan(n) 
            ])
        ),
        interrupt(true, ?(wait_exog_action))
    ])
]).

% 2. REACTIVE: Interrompe se arriva un nuovo goal o cambia la mappa
proc(control(reactive_ricochet), [
    prioritized_interrupts([
        interrupt(stop_requested, [ show_report, ?(fail) ]),
        interrupt(some_pending,
            pi(n, [
                ?(and(target_id(n), goal_active(n))),
                unset_new_goal_event,
                gexec(and(neg(new_goal_event), neg(robot_config_changed)),
                      serve_goal_plan(n))
            ])
        ),
        interrupt(true, ?(wait_exog_action))
    ])
]).

% ------------------------------------------------------------------
% INTERFACE
% ------------------------------------------------------------------
execute(show_report, _) :-
    format('--- FINAL REPORT GENERATED ---~n', []), !.
execute(A, S) :- format('>>> EXEC: ~w~n', [A]), (catch(show_state(S),_,true)->true;true).
show_state(S) :-
  ( current_predicate(holds/2) -> holds(pos(red),PR), holds(active_goals, L)
  ; holds(pos(red),PR,S), holds(active_goals, L, S) ),
  format('    STATE: Red=~w, Goals=~w~n', [PR, L]).