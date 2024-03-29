start :-
    set_prolog_flag(encoding, utf8),
    consult("Definitions.pl"),
    consult("Tools.pl"),
    consult("ObjectsLoad.pl"),
    consult("RoughSetTheory.pl"),
    consult("FuzzyMethotsTheory.pl"),
    consult("Interface.pl"),
    data_table_csv(Csv),
    assert_data_table(Csv),
    print_removed_objects_full_repetition,
    retract_full_repetition,
    print_apptoximations,
    print_ind_classes,
    print_removed_objects_inconsistency,
    retract_inconsistency,
    print_reducts,
    print_reduct,
    print_core,
    print_attributes_to_remove,
    retract_attributes,
    print_attributes,
    assert_rules,
    print_rules,
    ask_dec_loop.

zapytaj_ponownie :- ask_dec_loop.