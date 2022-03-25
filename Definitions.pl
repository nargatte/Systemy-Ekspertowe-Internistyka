data_table_csv("DataTable.csv").

premises([a,b,c,d]).
decision(e).

fuzzy_attributes([a,b]).

% gaussian(Mean, Deviation)
% trapezoid(Mean, Up_length, Down_length)
% rectangle(Mean, Length)
% triangle(Mean, Length)

fuzzy_function(a, 0, triangle(0,2)).
fuzzy_function(a, 1, triangle(1,2)).

fuzzy_function(b, 0, triangle(5,2)).
fuzzy_function(b, 1, triangle(15,2)).

% max, weighted_average, softmax
defuzzyfication(softmax).

attribute_name(a, "Atr. pierwszy", "Jaki jest attrybutu pierwszego?").
value_name(a, 0, "Nie").
value_name(a, 1, "Tak").