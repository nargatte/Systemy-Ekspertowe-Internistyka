read_csv(Csv, As, Vss) :-
    csv_read_file(Csv, [Ar|Vrs]),
    Ar =.. [_|As],
    maplist([In,Out]>>(In=..[_|Out]), Vrs, Vss).

assert_objects_values(As, Vss) :- 
    length(Vss, Len),
    range(0, Len, Range),
    maplist({As}/[Vs,I]>>(
        maplist(
            {I}/[A,V]>>assertz(object_value(I,A,V)), As, Vs
        )),Vss, Range).

assert_data_table(Csv) :-
    retractall(object_value(_,_,_)),
    read_csv(Csv, As, Vss),
    assert_objects_values(As, Vss).

attributes(As) :-
    findall(X, object_value(_,X,_), L),
    sort(L, As).

objects(Os) :-
    findall(X, object_value(X,_,_), L),
    sort(L, Os).

attribute_values(A, Vs) :-
    findall(X, object_value(_,A,X), L),
    sort(L, Vs).

lising_data_table :-
    listing(object_value).

retract_objects(Os) :-
    maplist([R]>>retractall(object_value(R,_,_)), Os).

retract_attributes(As) :-
    maplist([R]>>retractall(object_value(_,R,_)), As).