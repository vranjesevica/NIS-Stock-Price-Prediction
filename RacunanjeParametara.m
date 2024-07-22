% Podaci za period od 20.5. do 31.5.
closing_p = [849;842;848;841;846;845;847;846;842;840];
pc = [83;-71;83;-59;12-24;12;48;24;-221];
op = [845;842;846;846;847;859;846;841;840;842];
hp = [859;850;850;868;865;860;850;847;850;842];
lp = [845;840;841;840;840;843;846;841;840;840];
v = [4220;14117;2830;7442;27377;18748;285;190;488;15923];
b = [849;842;848;842;46;847;846;842;842;840];


podaci_za_racunanje = racunanje(closing_p, pc, op, hp, lp,v, b,inputs, ADL(end));

rezultati = net(podaci_za_racunanje);

disp("Minimalna vrednost za narednih pet dana:");
disp(rezultati(1));
disp("Maksimalna vrednost za narednih pet dana:");
disp(rezultati(2));
