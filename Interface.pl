name_of_attribute(A, Name) :-
    attribute_name(A, Name1, _) -> Name = Name1 ; string_concat("Atrybut ", A, Name).

name_of_value(A, V, Name) :-
    value_name(A, V, Name1) -> Name = Name1 ; Name = V.

print_removed_objects_full_repetition :-
    objects_to_remove_full_repetition(Fr),
    write("Obiekty usunięte przez pełne powtórzenie: "),
    print(Fr), write('\n').

print_apptoximations :-
    decision(D),
    attribute_values(D, Vs),
    maplist({D}/[V]>>(
        name_of_value(D, V, N),
        premises(Ps),
        findall(X, (object_value(X, D, V)), Xs),
        sort(Xs, S),
        write("Klasa nierozrużnialności "),
        print(N), write('\n'),
        write("Dolna aproksymacja: "),
        down_approximation(S, Ps, Down_ap),
        print(Down_ap), write('\n'),
        write("Górna aproksymacja: "),
        up_approximation(S, Ps, Up_ap),
        print(Up_ap), write('\n')
    ), Vs).

print_ind_classes :-
    premises(Ps),
    ind_classes(Ps, Cs),
    write("Klasy nierozrużnialności: "),
    print(Cs), write('\n').

print_removed_objects_inconsistency :-
    objects_to_remove_inconsistency(I),
    write("Obiekty usunięte przez nierozróżnialność: "),
    print(I), write('\n').

print_reducts :-
    reducts(Rs),
    write("Redukty: "), print(Rs), write('\n').

print_core :-
    core(C),
    write("Core: "), print(C), write('\n').

print_attributes_to_remove :-
    attributes_to_remove(As),
    write("Usunięte atrybuty: "), print(As), write('\n').

print_eq(eq(A, V)) :-
    name_of_attribute(A, An),
    name_of_value(A, V, Vn),
    write(An), write(" == "), write(Vn).

print_eqs([H]) :- print_eq(H), !.

print_eqs([H|T]) :- print_eq(H), write(" & "), print_eqs(T).

print_rule(rule(Eqs, eq(D, Dv))) :-
    name_of_value(D, Dv, Dvn),
    print_eqs(Eqs), write(" ==> "), write(Dvn), write('\n').

print_rules :-
    write("Minimalny zbiór zasad:\n"),
    findall(_, (
        rule(A, B),
        print_rule(rule(A, B))
    ), _).

get_ask(A, Name) :- 
    attribute_name(A, _, Name1) -> Name = Name1 ; 
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
        write(Vn), write(": "), format("~2f%\n", [Val])
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