objects_not_eql(O1, O2, As) :- 
    member(A, As),
    object_value(O1, A, V1),
    object_value(O2, A, V2),
    V1 \= V2.
    
objects_eql(O1, O2, As) :- not(objects_not_eql(O1, O2, As)).

ind_class(O, As, C) :- 
    objects(Os),
    findall(I, (member(I, Os), objects_eql(O, I, As)), C).

down_approximation(Os, As, S) :-
    findall(O, (
        member(O, Os),
        ind_class(O, As, C),
        contains(C, Os)
    ), S).

up_approximation(Os, As, S) :-
    findall(C, (
        member(O, Os),
        ind_class(O, As, C)
    ), Ss),
    flatten(Ss, F),
    sort(F, S).

ind_classes(As, Cs) :-
    findall(X, (
        objects(Os),
        member(O, Os),
        ind_class(O, As, X)
    ), L),
    sort(L, Cs).

objects_to_remove_full_repetition(Os_remove) :-
    attributes(As),
    ind_classes(As, Cs),
    maplist([In,Out]>>(In = [Out|_]), Cs, Os_stay),
    objects(Os),
    subtract(Os, Os_stay, Os_remove).

retract_full_repetition :-
    objects_to_remove_full_repetition(Os_remove),
    retract_objects(Os_remove).

decision_accuracy(V, Acc) :-
    decision(D),
    findall(X, object_value(X,D,V), Os),
    premises(Ps),
    down_approximation(Os, Ps, C),
    length(C, Acc).

object_better_than(O1, O2) :-
    decision(D),
    object_value(O1,D,V1),
    object_value(O2,D,V2),
    decision_accuracy(V1,Acc1),
    decision_accuracy(V2,Acc2),
    (Acc1 > Acc2).

best_object(Os, O) :-
    findall(F, (
        member(F, Os),
        not((member(X, Os), object_better_than(X, F)))
    ), [O|_]).

objects_to_remove_inconsistency(Os_remove) :-
    premises(As),
    ind_classes(As, Cs),
    maplist(best_object, Cs, Os_stay),
    objects(Os),
    subtract(Os, Os_stay, Os_remove).

retract_inconsistency :-
    objects_to_remove_inconsistency(Os_remove),
    retract_objects(Os_remove).

discernibility_attributes(O1, O2, As, Res) :-
    findall(A, (
        member(A, As),
        object_value(O1, A, V1),
        object_value(O2, A, V2),
        V1 \= V2
    ), Res).

discernibility_function(As, Con_dis) :-
    findall(Dis, (
        objects(Os),
        member(O1, Os),
        member(O2, Os),
        O1 < O2,
        discernibility_attributes(O1, O2, As, Dis)
    ), L_con_dis),
    sort(L_con_dis, Con_dis).

reducts(Rs) :-
    premises(Ps),
    discernibility_function(Ps, Cd),
    absorption_law(Cd, Cdr),
    con_dis_to_dis_con(Cdr, Rs).

reduct(R) :-
    reducts(Rs),
    smallest_list(Rs, R).

core(C) :-
    premises(Ps),
    discernibility_function(Ps, Cd),
    absorption_law(Cd, Cdr),
    findall(X, (
        member(X, Cdr),
        length(X, Xl),
        Xl =:= 1
    ), L),
    flatten(L, C).

attributes_to_remove(As_remove) :-
    premises(Ps),
    reduct(R),
    subtract(Ps, R, As_remove).

retract_attributes :-
    attributes_to_remove(As_remove),
    retract_attributes(As_remove).

object_different_decision(O1, O2) :-
    decision(D),
    objects(Os),
    member(O2, Os),
    object_value(O1,D,V1),
    object_value(O2,D,V2),
    V1 \= V2.

dissimilarity_function(O, Dc) :-
    findall(X, (
        premises(P),
        object_different_decision(O, Odd),
        discernibility_attributes(O, Odd, P, X)
    ), L),
    absorption_law(L, Cd),
    con_dis_to_dis_con(Cd, Dc).

eq_gen(O, Con, Eqs) :-
    maplist({O}/[A,Eq]>>(
        object_value(O,A,V),
        Eq =.. [eq,A,V]
    ),Con,Eqs).

object_eq_gen(O, Eqs) :-
    dissimilarity_function(O, Dc),
    maplist({O}/[As, Out]>>eq_gen(O, As, Out), Dc, Eqs).

decision_rules(Dv, Rs) :-
    findall(Eqs, (
        decision(D),
        object_value(O, D, Dv),
        object_eq_gen(O, Eqs)
    ), Eqss),
    one_level_flatten(Eqss, Eqsx),
    absorption_law(Eqsx, Eqsr),
    decision(D),
    maplist({D,Dv}/[In, Out]>>(
        Eq_r =.. [eq,D,Dv],
        Out =.. [rule,In,Eq_r]
    ), Eqsr, Rs).

assert_rules :-
    decision(D),
    attribute_values(D, Dvs),
    maplist(decision_rules,Dvs,Rss),
    flatten(Rss,Rs),
    sort(Rs,Srs),
    retractall(rule(_,_)),
    maplist(assertz, Srs).

