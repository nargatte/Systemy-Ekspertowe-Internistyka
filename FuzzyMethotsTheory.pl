mean(Pred, Mean) :- Pred =.. [_,Mean|_].

function_value(gaussian(M, D), X, Y) :- 
    Y is exp(-((X-M)^2)/(2*D^2)).

function_value(rectangle(M,L), X, Y) :-
    ((M-L/2 =< X) , (X =< M+L/2)) -> Y = 1 ; Y = 0.

function_value(triangle(M,L), X, Y) :-
    abs(M-X ,Abs), Y1 is -2/L*Abs + 1, Y is max(0, Y1).

function_value(binary(V), V, 1) :- !.
function_value(binary(_), _, 0).

function_value(trapezoid(M, L_up, L_down), X, Y) :-
    function_value(rectangle(M, L_up), X, Y_r),
    function_value(triangle(M-L_up/2, L_down-L_up), X, Y_t1),
    function_value(triangle(M+L_up/2, L_down-L_up), X, Y_t2),
    Y is max(Y_r,max(Y_t1, Y_t2)).

attribute_rule_function(eq(A, V), F) :-
    (fuzzy_function(A, V, X)) -> F = X ; F =.. [binary, V].

apply_eq(Ar, Input, Out) :-
    attribute_rule_function(Ar, F),
    function_value(F, Input, Out).

apply_eqs(Eqs, Anss, Out) :-
    findall(X, (
        member(Eq, Eqs),
        Eq =.. [_, A, _],
        member(Ans, Anss),
        Ans =.. [_, A, V_a],
        apply_eq(Eq, V_a, X)
    ), Vs),
    min_list(Vs, Out).
    
apply_decision_value(V_d, Anss, Out) :-
    findall(X, (
        rule(Eqs, eq(_, V_d)),
        apply_eqs(Eqs, Anss, App_out),
        length(Eqs, Eqs_len),
        X is App_out * e ^ Eqs_len
    ), Vs),
    sum_list(Vs, Out).
    
apply_answer(Anss, Out) :-
    decision(D),
    attribute_values(D, Dvs),
    maplist({Anss}/[V_d, Out_1]>>(
        apply_decision_value(V_d, Anss, Out_2), 
        Out_1 = [V_d, Out_2]
    ), Dvs, Out).

value_normalizator(In, Out) :-
    findall(X, (
        member(X1, In),
        X1 = [_, X]    
    ), L),
    max_list(L, Max),
    findall(X2, (
        member(X3, In),
        X3 = [Dec, V],
        V_norm is V / Max * e,
        X2 = [Dec, V_norm]
    ), Out).
    
% max, weighted_average, softmax

apply_defuzzyfication(max, [H|T], Out) :-
    aggregate([[D1,V1],[D2,V2],[Do,Vo]]>>(
        (V1 > V2) -> (Vo = V1, Do = D1); (Vo = V2, Do = D2)),
    H, T, [Out,_]).

apply_defuzzyfication(softmax, In, Out) :-
    value_normalizator(In, In1),
    maplist([I,O] >> (I = [_,V], O is exp(V)), In1, Vs),
    sum_list(Vs, Sum),
    maplist({Sum}/[[D,V1],[O1, D]] >> (O1 is exp(V1)/Sum), In1, Out1),
    sort(Out1, Out2),
    reverse(Out2, Out3),
    maplist([A,[B,C]] >> (A = [C,B]), Out3, Out).
    
apply_defuzzyfication(weighted_average, In, Out) :-
    decision(D),
    maplist({D}/[I,O1,O2] >> (
        I = [D1,O1],
        fuzzy_function(D, D1, Pred),
        mean(Pred, Mean),
        O2 is O1*Mean
        ), In, Vs1, Vs2),
    sum_list(Vs1, Sum1),
    sum_list(Vs2, Sum2),
    Out is Sum2/Sum1.