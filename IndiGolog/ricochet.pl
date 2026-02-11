:- discontiguous execute/2.
:- discontiguous exog_occurs/1.
:- discontiguous prim_action/1.
:- discontiguous prim_fluent/1.
:- discontiguous initially/2.
:- discontiguous poss/2.
:- discontiguous causes_val/4.
:- discontiguous proc/2.
:- discontiguous fun_fluent/1.
:- discontiguous rel_fluent/1.

:- dynamic static_stop_id/3.
:- dynamic seen/2.
:- dynamic printed_bound/1.

cache(_) :- fail.

% ------------------------------------------------------------------
% IndiGolog interface (logs)
% ------------------------------------------------------------------
execute(A, S) :-
  format('>>> EXEC: ~w~n', [A]),
  ( catch(show_state(S), _, true) -> true ; true ).

show_state(S) :-
  ( current_predicate(holds/3) ->
      holds(pos(red),   PR,  S),
      holds(pos(black), PB,  S),
      holds(pos(blue),  PBu, S),
      holds(battery_red,B,   S),
      holds(move_count, MC,  S)
  ; current_predicate(holds/2) ->
      holds(pos(red),   PR),
      holds(pos(black), PB),
      holds(pos(blue),  PBu),
      holds(battery_red,B),
      holds(move_count, MC)
  ;
    !, fail
  ),
  format('    state: MC=~w, Bred=~w~n', [MC, B]),
  format('    pos:   red=~w black=~w blue=~w~n', [PR, PB, PBu]).

% ------------------------------------------------------------------
% Utilities: ID <-> (R,C)  (board 4x4)
% ------------------------------------------------------------------
max_row(4).
max_col(4).

pos_to_id(c(R,C), ID) :-
  integer(R), integer(C),
  between(1,4,R), between(1,4,C),
  ID is (R-1)*4 + C.

id_to_pos(ID, c(R,C)) :-
  integer(ID), ID >= 1, ID =< 16,
  R is ((ID-1)//4)+1,
  C is ((ID-1) mod 4)+1.

dir(n). dir(s). dir(e). dir(w).

robot(red).
robot(black).
robot(blue).

% ------------------------------------------------------------------
% Map: charging station + walls
% Charging station at (1,4) => ID=4
% ------------------------------------------------------------------
charging_station_id(4).

% Perimeter walls
wall_at(1,  C, n) :- between(1,4,C).
wall_at(4,  C, s) :- between(1,4,C).
wall_at(R,  1, w) :- between(1,4,R).
wall_at(R,  4, e) :- between(1,4,R).

% Internal walls (as agreed):
% 1) between (1,2)-(1,3)
wall_at(1,2,e). wall_at(1,3,w).
% 2) between (2,2)-(2,3)
wall_at(2,2,e). wall_at(2,3,w).
% 3) between (2,3)-(3,3)
wall_at(2,3,s). wall_at(3,3,n).
% 4) between (3,1)-(4,1)
wall_at(3,1,s). wall_at(4,1,n).

% Step in direction
next_step(R,C,n, R2,C) :- R2 is R-1.
next_step(R,C,s, R2,C) :- R2 is R+1.
next_step(R,C,e, R,C2) :- C2 is C+1.
next_step(R,C,w, R,C2) :- C2 is C-1.

opposite(n,s). opposite(s,n). opposite(e,w). opposite(w,e).

% ------------------------------------------------------------------
% Primitive actions
% ------------------------------------------------------------------
prim_action(move(R,D)) :- robot(R), dir(D).
prim_action(recharge).                 % only affects red battery, cost 0, no move_count increment

% Optional setup (handy for tests)
prim_action(set_battery(B)) :- integer(B), B >= 0, B =< 10.

% ------------------------------------------------------------------
% Fluents
% ------------------------------------------------------------------
prim_fluent(pos(R)) :- robot(R).     % ID 1..16
prim_fluent(battery_red).            % only red
prim_fluent(move_count).             % increments only on move

% charging station
prim_fluent(station_id).
fun_fluent(station_id).

% ------------------------------------------------------------------
% Needed by eval_bat.pl (projection tasks): declare functional fluents
% and allow equality-forms as "relational" fluents, e.g. battery_red=B
% ------------------------------------------------------------------

% Functional fluents 
fun_fluent(pos(R)) :- robot(R).
fun_fluent(battery_red).
fun_fluent(move_count).

% eval_bat expects rel_fluent
rel_fluent(Expr) :-
    nonvar(Expr),
    Expr = (F = _V),
    fun_fluent(F).

% ------------------------------------------------------------------
% Initial state
% ------------------------------------------------------------------
initially(pos(red),   2). %red robot at (1,2)
initially(pos(blue),  7). %blue robot at (3,1)
initially(pos(black), 9). %black robot at (2,3)

initially(battery_red, 10). %initial battery of red=10
initially(move_count, 0).   %moves counter
initially(station_id, 4).   % station at (1,4) => ID=4

% ------------------------------------------------------------------
% Preconditions (poss)
% ------------------------------------------------------------------
% Red needs battery >= 1, it can move iff battery is not zero
poss(move(red,_), neg(battery_red=0)).
% Others infinite battery
poss(move(R,_), true) :- robot(R), R \= red.

% recharge allowed iff red is on station and battery is not full
poss(recharge,
  and(pos(red)=ID,
  and(station_id=ID,
      neg(battery_red=10)
  ))).

% setup always allowed
poss(set_battery(_), true).

% ------------------------------------------------------------------
% Effects (causes_val)
% ------------------------------------------------------------------
% Battery only for red
causes_val(move(red,_), battery_red, B2, (battery_red=B1, B2 is B1 - 1)).
causes_val(recharge,    battery_red, 10, true).
causes_val(set_battery(B), battery_red, B, true).

% Move counter only on move
causes_val(move(_,_), move_count, C2, (move_count=C1, C2 is C1 + 1)).

% ------------------------------------------------------------------
% FAST STOP COMPUTATION (static + dynamic stop)
% ------------------------------------------------------------------

% Occupied list without the moving robot (IDs of the other 2 robots)
occ_ids_without(red,   _PR, PB, PBu, [PB, PBu]).
occ_ids_without(black, PR, _PB, PBu, [PR, PBu]).
occ_ids_without(blue,  PR, PB, _PBu, [PR, PB]).

% Static stop: depends only on walls
static_stop_pos(c(R,C), D, c(FR,FC)) :-
  ( wall_at(R,C,D) ->
      FR=R, FC=C
  ;
      next_step(R,C,D, NR,NC),
      static_stop_pos(c(NR,NC), D, c(FR,FC))
  ).

compute_static_stop_all :-
  retractall(static_stop_id(_,_,_)),
  forall(
    ( between(1,16,ID), dir(D) ),
    (
      id_to_pos(ID, P),
      static_stop_pos(P, D, P2),
      pos_to_id(P2, SID),
      assertz(static_stop_id(ID,D,SID))
    )
  ).

:- initialization(compute_static_stop_all).

% Enumerate IDs from Start (excluded) to StaticStop (included) step-by-step
ray_ids_until(StartID, D, StaticStopID, Ray) :-
  id_to_pos(StartID, c(R,C)),
  id_to_pos(StaticStopID, c(Rs,Cs)),
  ray_ids_until_pos(c(R,C), D, c(Rs,Cs), [], Rev),
  reverse(Rev, Ray).

ray_ids_until_pos(c(R,C), _D, c(R,C), Acc, Acc) :- !.
ray_ids_until_pos(c(R,C), D, Target, Acc, Out) :-
  next_step(R,C,D, R2,C2),
  pos_to_id(c(R2,C2), ID2),
  ray_ids_until_pos(c(R2,C2), D, Target, [ID2|Acc], Out).

first_hit([], _Occ, none).
first_hit([ID|Rest], Occ, Hit) :-
  ( member(ID, Occ) -> Hit = ID
  ; first_hit(Rest, Occ, Hit)
  ).

dynamic_stop_id(StartID, D, OccIDs, StopID) :-
  static_stop_id(StartID, D, StaticStopID),
  ray_ids_until(StartID, D, StaticStopID, Ray),
  first_hit(Ray, OccIDs, Hit),
  ( Hit = none ->
      StopID = StaticStopID
  ;
      id_to_pos(Hit, c(Rh,Ch)),
      opposite(D, Dopp),
      next_step(Rh,Ch,Dopp, Rs,Cs),
      pos_to_id(c(Rs,Cs), StopID)
  ).

% Position effects for move
causes_val(move(R,D), pos(R), NewID, (
  pos(red)=PR, pos(black)=PB, pos(blue)=PBu,
  occ_ids_without(R, PR, PB, PBu, Occ),
  pos(R)=CurrID,
  dynamic_stop_id(CurrID, D, Occ, NewID)
)).

% ------------------------------------------------------------------
% SEARCH SUPPORT: objective, closure, heuristic, pruning, branching
% ------------------------------------------------------------------

% Objective: reach charging station with red
proc(reached_station, [
  ?(pos(red)=ID),
  ?(station_id=ID)
]).

% Zero-cost closure: auto-recharge if possible
proc(zero_cost_closure,
  ndet(
    [ ?(pos(red)=PR),
      ?(station_id=PR),
      ?(battery_red=B),
      ?(B \= 10),
      recharge,
      zero_cost_closure
    ],
    []
  )
).

% Admissible lower bound to station (ignores walls/robots, safe under-estimate)
same_row(ID1, ID2) :- id_to_pos(ID1, c(R,_)), id_to_pos(ID2, c(R,_)).
same_col(ID1, ID2) :- id_to_pos(ID1, c(_,C)), id_to_pos(ID2, c(_,C)).

lb_to_target(PR, TID, LB) :-
  ( PR =:= TID -> LB = 0
  ; (same_row(PR,TID) ; same_col(PR,TID)) -> LB = 1
  ; LB = 2
  ).

proc(prune_h(Max), [
  ?(pos(red)=PR),
  ?(station_id=TID),
  ?(lb_to_target(PR,TID,LB)),
  ?(LB =< Max)
]).

% Transposition pruning
reset_seen :- retractall(seen(_,_)).

make_key(PR, PB, PBu, Bred, k(PR,PB,PBu,Bred)).

prune_or_mark_key(Max, Key) :-
  ( seen(Key,Best), Best >= Max ->
      !, fail
  ;
      retractall(seen(Key,_)),
      assertz(seen(Key,Max))
  ).

proc(prune_state(Max), [
  ?(pos(red)=PR), ?(pos(black)=PB), ?(pos(blue)=PBu),
  ?(battery_red=Bred),
  ?(make_key(PR,PB,PBu,Bred,Key)),
  ?(prune_or_mark_key(Max,Key))
]).

% Move generator: compute stop first, skip no-op
proc(move_eff(R,D), [
  ?(pos(R)=ID0),
  ?(pos(red)=PR), ?(pos(black)=PB), ?(pos(blue)=PBu),
  ?(occ_ids_without(R, PR, PB, PBu, Occ)),
  ?(dynamic_stop_id(ID0, D, Occ, FID)),
  ?(FID \= ID0),
  move(R,D)
]).

proc(any_move_eff_red,
  ndet(move_eff(red,n),
  ndet(move_eff(red,e),
  ndet(move_eff(red,s),
       move_eff(red,w))))).

proc(any_move_eff_black,
  ndet(move_eff(black,n),
  ndet(move_eff(black,e),
  ndet(move_eff(black,s),
       move_eff(black,w))))).

proc(any_move_eff_blue,
  ndet(move_eff(blue,n),
  ndet(move_eff(blue,e),
  ndet(move_eff(blue,s),
       move_eff(blue,w))))).

proc(any_move_eff,
  ndet(any_move_eff_red,
  ndet(any_move_eff_black,
       any_move_eff_blue))).

% Main bounded solver (IDDFS on move budget)
proc(handle_reach_station(Max), [
  zero_cost_closure,
  ndet(
    reached_station,
    [ prune_state(Max),
      prune_h(Max),
      ?(Max > 0),
      any_move_eff,
      pi(m, [ ?(m is Max - 1),
              handle_reach_station(m) ])
    ]
  )
]).

% Bound log
reset_printed_bound :- retractall(printed_bound(_)).

announce_bound(Max) :-
  ( printed_bound(Max) -> true
  ; assertz(printed_bound(Max)),
    format('>> trying MaxMoves=~w~n', [Max])
  ).

proc(minimize_moves_bounded(Max, Limit),
  ndet(
    [ ?(announce_bound(Max)),
      handle_reach_station(Max)
    ],
    [ ?(Max < Limit),
      pi(m, [ ?(m is Max + 1),
              minimize_moves_bounded(m, Limit) ])
    ]
  )).

% ------------------------------------------------------------------
% TEST CONTROLLERS
% ------------------------------------------------------------------

proc(control(test_reach_station), [
  ?(reset_seen), ?(reset_printed_bound),
  set_battery(10),
  search(minimize_moves_bounded(0, 40))
]).