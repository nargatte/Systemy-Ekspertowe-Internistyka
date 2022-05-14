name_of_attribute(A, Name) :- find_and_replace_string(A, Name, "_", " ").

attribute_list_pp([]) :- !.

attribute_list_pp([A]) :- name_of_attribute(A, N), write(N), !.

attribute_list_pp([A|As]) :-
    name_of_attribute(A, N), write(N), write(", "), attribute_list_pp(As).

name_of_value(_, V, Name) :- find_and_replace_string(V, Name, "_", " ").

print_removed_objects_full_repetition :-
    objects_to_remove_full_repetition(Fr),
    write("Liczba obiektów usuniętych przez pełne powtórzenie: "),
    length(Fr, Frl),
    print(Frl), write('\n').

print_apptoximations :-
    decision(D),
    attribute_values(D, Vs),
    maplist({D}/[V]>>(
        name_of_value(D, V, N),
        premises(Ps),
        findall(X, (object_value(X, D, V)), Xs),
        sort(Xs, S),
        write("Klasa decyzyjności: "),
        attribute_list_pp([N]), write('\n'),
        write("Wielkość dolnej aproksymacji: "),
        down_approximation(S, Ps, Down_ap),
        length(Down_ap, Down_ap_l),
        print(Down_ap_l), write('\n'),
        write("Wielkość górnej aproksymacji: "),
        up_approximation(S, Ps, Up_ap),
        length(Up_ap, Up_ap_l),
        print(Up_ap_l), write('\n')
    ), Vs).

print_ind_classes :-
    premises(Ps),
    ind_classes(Ps, Cs),
    write("Liczba klas nierozróżnialności: "),
    length(Cs, Csl),
    print(Csl), write('\n').

print_removed_objects_inconsistency :-
    objects_to_remove_inconsistency(I),
    write("Liczba obiektów usuniętych przez nierozróżnialność: "),
    length(I, Il),
    print(Il), write('\n').

print_reducts :-
    reducts(Rs),
    write("Liczba reduktów: "), length(Rs, Rsl), print(Rsl), write('\n').

print_reduct :-
    reduct(R),
    write("Wybrany redukt: "), attribute_list_pp(R), write('\n').

print_core :-
    core(C),
    write("Core: "), attribute_list_pp(C), write('\n').

print_attributes_to_remove :-
    attributes_to_remove(As),
    write("Usunięte atrybuty: "), attribute_list_pp(As), write('\n').

print_attributes :-
    attributes(As),
    write("Pozostałe atrybuty: "), attribute_list_pp(As), write('\n').

print_eq(eq(A, V)) :-
    name_of_attribute(A, An),
    name_of_value(A, V, Vn),
    write(An), write(" == "), write(Vn).

print_eqs([H]) :- print_eq(H), !.

print_eqs([H|T]) :- print_eq(H), write(" & "), print_eqs(T).

print_rule(rule(Eqs, eq(D, Dv))) :-
    name_of_value(D, Dv, Dvn),
    print_eqs(Eqs), write(" ==> "), write(Dvn), write('\n').

print_rule_list([]) :- !.
print_rule_list([R|L]) :- print_rule(R), print_rule_list(L).

max_eq_rule(Max) :-
    findall(Len, (
        rule(X, _),
        length(X, Len)
    ), L),
    max_list(L, Max).

print_rules_by_size(Size) :-
    findall(R, (
        rule(X, Y),
        length(X, Size),
        R =.. [rule, X, Y]
    ), Rl),
    length(Rl, Rll),
    write("Liczba zasad z "), write(Size), write(" warunkami: "), write(Rll), write("\nPrzykładowe zasady: \n"),
    random_permutation(Rl, Rrl),
    take(10, Rrl, Srl),
    print_rule_list(Srl).

print_rules :-
    write("Wielkość zbioru zasad:\n"),
    findall([X,Y], (
        rule(X, Y)
    ), L),
    length(L, Ll),
    print(Ll), write('\n'),
    max_eq_rule(Max),
    range(1, Max, Rl),
    findall(_,(
        member(Rel, Rl),
        print_rules_by_size(Rel)
    ), _).

get_ask(A, Name) :- 
    attribute_question(A, Name1) -> Name = Name1 ; 
    string_concat("Jaka jest wartość atrybutu ", A, Name2),
    string_concat(Name2, "?", Name).

ask_for_nonfuzzy(A, eq(A, Answer)) :-
    get_ask(A, Ask),
    write(Ask), write('\n'),
    attribute_values(A, Vs),
    length(Vs, Len),
    range(1, Len, Range),
    maplist({A}/[Num, Val] >> (
        name_of_value(A, Val, Vn),
        print(Num), write(": "), write(Vn), write('\n')
    ), Range, Vs),
    read(Read),
    ((integer(Read), 1 =< Read, Read =< Len) -> nth1(Read, Vs, Answer);
        write("Niepoprawna odpowedź, proszę wprowadzić jeszcze raz.\n"),
        ask_for_nonfuzzy(A, eq(A, Answer))).
    
ask_for_fuzzy(A, eq(A, Answer)) :-
    (special_ask_attributes(Saa), member(A, Saa)) -> ask_question(A, Answer);
    get_ask(A, Ask),
    write(Ask), write('\n'),
    read(Answer).

ask_for_attribute(A, Ans) :-
    fuzzy_attributes(Fas),
    (member(A, Fas) -> ask_for_fuzzy(A, Ans); ask_for_nonfuzzy(A, Ans)).

ask(Anss) :-
    premises(Ps),
    attributes(As),
    intersection(Ps, As, S),
    maplist(ask_for_attribute, S, Anss).

print_decision(softmax,  Dec) :-
    decision(D),
    maplist({D}/[[V, Val]]>>(
        name_of_value(D, V, Vn),
        Pval is Val * 100,
        write(Vn), write(": "), format("~2f%\n", [Pval])
    ), Dec).

print_decision(max,  Dec) :-
    decision(D),
    name_of_value(D, Dec, Vn),
    write(Vn), write('\n').

print_decision(weighted_average,  Dec) :-
    format("~2f\n", [Dec]).

ask_dec :-
    ask(Anss),
    apply_answer(Anss, Dec),
    defuzzyfication(DF),
    apply_defuzzyfication(DF, Dec, Out),
    write("Odpowiedź systemu expertowego to:\n"),
    print_decision(DF, Out).

ask_dec_loop :-
    ask_dec,
    ask_dec_loop.
