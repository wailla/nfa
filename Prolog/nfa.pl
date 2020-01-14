%%%% Villa Fabio 829583

%%%%-*- mode:prolog -*-
% 1- is_regexp()

%Arity (only for seq and or)
f_arity(seq, Arity):- Arity >=2, !.
f_arity(or, Arity):- Arity>=2, !.

%Base case: atomic
regexp(RE) :- is_regexp(RE).
is_regexp(RE) :- atomic(RE), !.

%Base case: epsilon o insieme vuoto

is_regexp(epsilon).

%Recursive case: sequence

is_regexp(RE) :- RE=..[seq | RE1], functor(RE, Functor, Arity),
    f_arity(Functor, Arity), regexp(RE1).
is_regexp([RE1 | RE2]) :- regexp(RE1), is_regexp(RE2).

%Recursive case: or

is_regexp(RE) :- RE=..[or | RE1],
    functor(RE, Functor, Arity), f_arity(Functor, Arity), is_regexp(RE1).
is_regexp([RE1 | RE2]) :- is_regexp(RE1), is_regexp(RE2).

%Recursive case: star Kleene closing

is_regexp(star(RE)) :- is_regexp(RE).

%Recursive case: Plus

is_regexp(plus(RE)) :- is_regexp(RE).

% 2- nfa_regexp_comp:
% Base case
nfa_regexp_comp(FA_Id, RE):-
    is_regexp(RE),
    nonvar(FA_Id),
    gensym(q, Initial),
    assert(nfa_initial(FA_Id, Initial)),
    gensym(q, Final),
    assert(nfa_final(FA_Id, Final)),
    nfa_regexp_comp(FA_Id, RE, Initial, Final).

% Recursive case:

nfa_regexp_comp(FA_Id, RE, Initial, Final):-
    RE=..[seq | RE1],
    nfa_regexp_comp_seq(FA_Id, RE1, Initial, Final).

nfa_regexp_comp(FA_Id, RE, Initial, Final):-
    RE=..[or | RE1],
    nfa_regexp_comp_or(FA_Id, RE1, Initial, Final).

nfa_regexp_comp(FA_Id, RE, Initial, Final):-
    RE=..[star | RE1],
    nfa_regexp_comp_star(FA_Id, RE1, Initial, Final).

nfa_regexp_comp(FA_Id, RE, Initial, Final):-
    RE=..[plus | RE1],
    nfa_regexp_comp_plus(FA_Id, RE1, Initial, Final).

% Read single character:

nfa_regexp_comp(FA_Id, RE, Initial, Final) :-
    atomic(RE),
    assert(nfa_delta(FA_Id, RE, Initial, Final)).

% Or:

nfa_regexp_comp_or(FA_Id, [RE|REs], Initial, Final):-
    atomic(RE),
    gensym(q, Stat1),
    assert(nfa_delta(FA_Id, espsilon, Initial, Stat1)),
    gensym(q, Stat2),
    assert(nfa_delta(FA_Id, RE, Stat1, Stat2)),
    assert(nfa_delta(FA_Id, espsilon, Stat2, Final)),
    nfa_regexp_comp_or(FA_Id, REs, Initial, Final).

nfa_regexp_comp_or(_, [], _, _):-!.

% sequence:

nfa_regexp_comp_seq(FA_Id, [RE|REs], Initial, Final):-
    atomic(RE),
    gensym(q, Stat1),
    assert(nfa_delta(FA_Id, RE, Initial, Stat1)),
    nfa_regexp_comp_seq1(FA_Id, REs, Stat1, Final).

nfa_regexp_comp_seq1(FA_Id, [RE|REs], Stat1, Final):-
    atomic(RE),
    gensym(q, Stat2),
    assert(nfa_delta(FA_Id, REs, Stat1, Stat2)),
    nfa_regexp_comp_seq1(FA_Id, REs, Stat2, Final).


nfa_regexp_comp_seq1(FA_Id, RE, State, Final):-
    assert(nfa_delta(FA_Id, RE, State, Final)).

% star:

nfa_regexp_comp_star(FA_Id, RE, Initial, Final):-
    assert(nfa_delta(FA_Id, epsilon, Initial, Final)),
    gensym(q, State),
    assert(nfa_delta(FA_Id, epsilon, Initial, State)),
    assert(nfa_delta(FA_Id, RE, State, State)),
    assert(nfa_delta(FA_Id, epsilon, State, Final)).

% Plus:

nfa_regexp_comp_plus(FA_Id, RE1, Initial, Final):-
    gensym(q, N_State),
	  assert(nfa_delta(FA_Id, RE1, Initial, N_State)),
	  assert(nfa_delta(FA_Id, RE1, Initial, N_State)),
	  gensym(q, Final),
	  assert(nfa_delta(FA_Id, espsilon, N_State, Final)).

% 3- nfa_test

nfa_test(FA_Id, [Input|Inputs]):-
    nfa_initial(FA_Id, Initial),
    nfa_delta(FA_Id, Input, Initial, State),
    nfa_test(FA_Id, Inputs, State).

nfa_test(FA_Id, Input):-
    nfa_initial(FA_Id, Initial),
    nfa_delta(FA_Id, epsilon, Initial, State),
    nfa_test(FA_Id, Input, State).

nfa_test(FA_Id, [Input|Inputs], Istate):-
    nfa_delta(FA_Id, Input, Istate, State),
    nfa_test(FA_Id, Inputs, State).

nfa_test(FA_Id, Input, IState):-
    nfa_delta(FA_Id, epsilon, IState, State),
    nfa_test(FA_Id, Input, State).

nfa_test(FA_Id, [], Final):-
    nfa_final(FA_Id, Final),!.


% 4- nfa_list and nfa_clear
%CLEAR

nfa_clear(FA_Id) :-
    retract(nfa_delta(FA_Id, _, _, _)),
    nfa_clear(FA_Id).

nfa_clear(FA_Id) :-
    retract(nfa_initial(FA_Id, _)),
    retract(nfa_final(FA_Id, _)).

nfa_clear :-
    retractall(nfa_initial(_, _)),
    retractall(nfa_final(_, _)),
    retractall(nfa_delta(_, _, _, _)).

%LIST

nfa_list(FA_Id) :-
    listing(nfa_delta(FA_Id, _, _, _)),
    listing(nfa_final(FA_Id, _)),
    listing(nfa_initial(FA_Id, _)).

nfa_list :-
    listing(nfa_delta(_, _, _, _)),
    listing(nfa_initial(_, _)),
    listing(nfa_final(_, _)).

%%%% -*- eof: nfa.pl -*-
