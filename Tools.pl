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

sort_contains([], _) :- !.

sort_contains([_|_], []) :- false, !.

sort_contains([H|L1], [H|L2]) :- sort_contains(L1, L2), !.

sort_contains(L1, [_|L2]) :- sort_contains(L1, L2).

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

is_absorpt_by_any(Item, List) :-
    member(X, List),
    sort_contains(X, Item).

filtered_not_absorpt_by(Item, List, Out) :-
    findall(X, (
        member(X, List),
        not(sort_contains(Item, X))
    ), Out).

absorption_law([H|T], List_out) :-
    aggregate([State, In, Out] >> 
        (
            filtered_not_absorpt_by(In, State, FS),
            (is_absorpt_by_any(In, FS) -> (Out = FS) ; (sort([In|FS], Out))) 
        ), [H], T, List_out).

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
    
%find_and_replace(In, Out, Find, Repace).

find_and_replace([], [], _, _) :- !.
find_and_replace([F|Ti], [R|To], F, R) :- find_and_replace(Ti, To, F, R), !.
find_and_replace([H|Ti], [H|To], F, R) :- find_and_replace(Ti, To, F, R).

find_and_replace_string(In, Out, Find, Repace) :- 
    string_to_list(Find, [Findc]), 
    string_to_list(Repace, [Repacec]), 
    string_to_list(In, Inl), 
    find_and_replace(Inl, Outl, Findc, Repacec), 
    string_to_list(Out, Outl).

take(0, _, []) :- !.
take(_, [], []) :- !.
take(N, [H|T], [H|To]) :- N1 is N-1, take(N1, T, To).