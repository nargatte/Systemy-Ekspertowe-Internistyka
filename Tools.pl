range(_, 0, []) :- !.

range(Start, Count, List) :- 
    Prev_c is Count-1,
    Next_s is Start+1,
    range(Next_s, Prev_c, Rest),
    List = [Start|Rest].

not_contains(Inner, Outer) :-
    member(I, Inner),
    not(member(I, Outer)).

contains(Inner, Outer) :- not(not_contains(Inner, Outer)).

aggregate(_, State, [], State) :- !.

aggregate(Pred, State, [H|T], R) :- 
    call(Pred, State, H, N),
    aggregate(Pred, N, T, R).

smallest_list([H|T], L) :-
    aggregate([L1,L2,Lr]>>(
        length(L1, Ll1),
        length(L2, Ll2),
        Ll1 < Ll2 -> Lr = L1 ; Lr = L2
    ), H, T, L).

absorption_law([],[]) :- !.

absorption_law(Cd, [S_dis|T_out]) :-
    smallest_list(Cd, S_dis),
    findall(X, (
        member(X, Cd),
        not_contains(S_dis, X)
    ), R),
    absorption_law(R, T_out).

con_dis_to_dis_con_x([],[[]]) :- !.

con_dis_to_dis_con_x([H|T], R) :-
    con_dis_to_dis_con(T, Rr),
    findall(X, (
        member(E, H),
        member(Er, Rr),
        L = [E|Er],
        sort(L, X)
    ), Rx),
    sort(Rx, R).

con_dis_to_dis_con(Cd, Dc) :-
    con_dis_to_dis_con_x(Cd, Dc_x),
    absorption_law(Dc_x, Dc).

one_level_flatten([],[]) :- !.

one_level_flatten([H_in|T_in], Out) :-
    one_level_flatten(T_in, T_out),
    reverse(H_in,H_in_r),
    aggregate([State,E,R]>>(R = [E|State]), T_out, H_in_r, Out).
    