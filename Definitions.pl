data_table_csv("baza-wiedzy.csv").

premises([kaszel,temperatura,bmi,samopoczucie,osłabienie,ból_mięśni,ból_w_klatce_piersiowej,duszność,ból_gardła,chrypa,katar,kichanie,bladość,omdlenia,ciśnienie_tętnicze,zaburzenia_pracy_serca,zaburzenia_widzenia,zawroty_głowy,cukrzyca,zaburzenia_pamięci]).
decision(diagnoza).

fuzzy_attributes([temperatura, bmi, ciśnienie_tętnicze]).

% gaussian(Mean, Deviation)
% trapezoid(Mean, Up_length, Down_length)
% rectangle(Mean, Length)
% triangle(Mean, Length)

fuzzy_function(temperatura, niska, trapezoid(35, 2, 4)).
fuzzy_function(temperatura, w_normie, triangle(36.6, 1)).
fuzzy_function(temperatura, podwyższona, triangle(37, 1)).
fuzzy_function(temperatura, wysoka, trapezoid(38, 2, 4)).

fuzzy_function(bmi, wygłodzenie, gaussian(15.5, 2)).
fuzzy_function(bmi, wychudzenie, gaussian(16.5, 2)).
fuzzy_function(bmi, niedowaga, gaussian(17.75, 2)).
fuzzy_function(bmi, normalna, trapezoid(21.75, 6.5, 8)).
fuzzy_function(bmi, nadwaga, trapezoid(27.5, 5, 7)).
fuzzy_function(bmi, otyłość, trapezoid(35, 10, 12)).

fuzzy_function(ciśnienie_tętnicze, niskie, trapezoid(115, 5, 9)).
fuzzy_function(ciśnienie_tętnicze, w_normie, trapezoid(125, 5, 9)).
fuzzy_function(ciśnienie_tętnicze, wysokie, trapezoid(135, 5, 9)).

% max, weighted_average, softmax
defuzzyfication(softmax).

attribute_question(kaszel, "Czy masz kaszel?").
attribute_question(temperatura, "Ile wynosi Twoja temperatura ciała?\nPodaj wartość swojej temperatury ciała (°C):").
attribute_question(samopoczucie, "Jakie jest Twoje samopoczucie?").
attribute_question(osłabienie, "Czy czujesz się osłabiony?").
attribute_question(ból_mięśni, "Czy bolą Cię mięśnie?").
attribute_question(ból_w_klatce_piersiowej, "Czy odczuwasz ból w klatce piersiowej?").
attribute_question(duszność, "Czy masz duszności?").
attribute_question(ból_gardła, "Czy boli Cię gardło?").
attribute_question(chrypa, "Czy masz chrypę?").
attribute_question(katar, "Czy masz katar?").
attribute_question(kichanie, "Czy występuje częsty odruch kichania?").
attribute_question(bladość, "Czy Twoja skóra przejawia widoczną bladość?").
attribute_question(omdlenia, "Czy pojawiły się omdlenia?").
attribute_question(ciśnienie_tętnicze, "Jakie masz ciśnienie tętnicze?\nPodaj wartość swojego ciśnienia tętniczego górnego (mm Hg):").
attribute_question(zaburzenia_pracy_serca, "Czy odczuwasz zaburzenia pracy serca?").
attribute_question(zaburzenia_widzenia, "Czy występują zaburzenia widzenia?").
attribute_question(zawroty_głowy, "Czy odczuwasz zawroty głowy?").
attribute_question(cukrzyca, "Czy masz cukrzycę?").
attribute_question(zaburzenia_pamięci, "Czy występują zaburzenia pamięci?").

special_ask_attributes([bmi]).

ask_question(bmi, V) :-
    write("Podaj swoją wagę (kg):\n"), read(Weight),
    write("Podaj swój wzrost (cm):\n"), read(Heigh),
    V is Weight / (Heigh / 100) ^ 2.
