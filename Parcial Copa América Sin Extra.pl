% Base de conocimientos
grupo(1,[arg,parag,uru,jam]).
grupo(2,[chile,bol,mex,ecu]).
grupo(3,[bra,peru,col,vene]).

gol(higuain,parag,tiempo(2,38),semi).
gol(dimaria,parag,tiempo(2,8),semi).
gol(dimaria,parag,tiempo(1,47),semi).
gol(pastore,parag,tiempo(1,27),semi).
gol(rojo,parag,tiempo(1,15),semi).
gol(aguero,parag,tiempo(2,30),semi).
gol(barrios,arg,tiempo(1,43),semi).
gol(vargas,peru,tiempo(1,42),semi).
gol(vargas,peru,tiempo(2,19),semi).
gol(guerrero,chile,tiempo(2,15),semi).
gol(tevez,col,penales(8),cuartos).
gol(messi,col,penales(1),cuartos).
gol(falcao,arg,penales(2),cuartos).

gol(aguero,uru,tiempo(2,21),grupos).
gol(higuain,jam,tiempo(1,11),grupos).
gol(messi,parag,tiempo(1,36),grupos).
gol(aguero,parag,tiempo(1,29),grupos).
gol(valdez,arg,tiempo(2,15),grupos).
gol(barrios,arg,tiempo(2,45),grupos).

equipo(arg,[higuain,dimaria,pastore,rojo,aguero,messi,tevez]).
equipo(parag,[barrios,valdez]).
equipo(jam,[marley,rastafari,bolt]).
equipo(uru,[suarez,cabani,francescoli,mugica,tabare,artigas]).
equipo(chile,[bravo,vargas,sanchez,allende,neruda,parra,jara,hurtado,mistral]).
equipo(peru,[guerrero]).
equipo(col,[falcao,rodriguez]).
equipo(bra,[]).
equipo(vene,[]).
equipo(mex,[]).
equipo(ecu,[]).
equipo(bol,[]).

fase(grupos).
fase(cuartos).
fase(semi).
fase(final).

% 1) Partidos sin goles
% Son dos equipos que jugaron en la fase de grupos (por estar en 
% el mismo grupo) y que ninguno le hizo un gol al otro.

partidoSinGoles(Equipo1,Equipo2):-
    partidoFaseGrupos(Equipo1,Equipo2),
    not(hizoGol(Equipo1,Equipo2,grupos)),
    not(hizoGol(Equipo2,Equipo1,grupos)).

partidoFaseGrupos(E1,E2):-
    grupo(_,Equipos),
    member(E1,Equipos),
    member(E2,Equipos),
    E1\=E2.

% Simplifica varias partes de la solucion, abstrayendose de que jugador
% fue el que hizo el gol y manejandolo a nivel equipo

hizoGol(Equipo1,Equipo2,Fase):-
    esDelEquipo(Jugador,Equipo1),
    gol(Jugador,Equipo2,_,Fase).

esDelEquipo(J,P):-equipo(P,Js),member(J,Js).
 
% 2) Ganador
% Gana si la cantidad de goles que un equipo le hizo al otro es mayor
% que la cantidad que el otro le hizo, en la misma fase.
% Si son equipos que no jugaron, ambas cantidades son 0 y no hay
% ganador.

ganador(Equipo1,Equipo2,Fase):-
    fase(Fase),
    cantidadGoles(Equipo1,Equipo2,Fase,Goles1),
    cantidadGoles(Equipo2,Equipo1,Fase,Goles2),
    Goles1>Goles2.

% Es importante generar los dos equipos para que sea inversible.
% La fase no es inversible, debe llegar unificada.
% Si se pregunta por equipos que no jugaron, la cantidad es 0. Hay % que tener cuidado con esto al utilizarlo.

cantidadGoles(Equipo,Adversario,Fase,Cantidad):-
    equipo(Equipo,_),
    equipo(Adversario,_),
    findall(_,hizoGol(Equipo,Adversario,Fase),Goles),
    length(Goles,Cantidad).

% 3) Invicto
%un equipo al que no le ganaron.
invicto(E):-
    equipo(E,_),
    not(ganador(_,E,grupos)).

% 4) Ganó por penales
% Un equipo que gano y que uno de sus jugadores hizo un gol en la
% definicion por penales.
% Aparte, es el jugador que hizo el panal decisivo, porque todos los
% demas penales convertidos tienen un numero de orden menor o igual al
% suyo.
% Todo en la misma fase y frente al mismo equipo adversario

ganoPorPenales(Equipo,Jugador):-
    ganador(Equipo,Adversario,Fase),
    esDelEquipo(Jugador,Equipo),
    gol(Jugador,Adversario,penales(NOrden),Fase),
    forall(gol(_,Adversario,penales(N),Fase),N=<NOrden).

%5) Premios Conmebol
% Conviene juntar los puntos por cada gol del jugador,
% independientemente de como o cuando fue cada uno (gracias al
% polimorfismo) y asi sumar los valores y calcular el importe.

premio(Jugador,Premio):-
    esDelEquipo(Jugador,_),
    findall(Cantidad, unidadesPorGol(Jugador,Cantidad),Cantidades),
    sumlist(Cantidades,Total),
    Premio is Total * 100.

unidadesPorGol(Jugador, Cantidad):-
    gol(Jugador,_,Gol,Fase),
    unidades(Gol,Unidades),
    coeficienteFase(Fase,Coef),
    Cantidad is Unidades * Coef.

% Para no repetir logica, utilizamos un coeficiente que duplica en la
% fase final.
coeficienteFase(final,2).
coeficienteFase(Fase,1):- Fase \= final.

% Con polimorfismo en base a los functores, resolvemos facilmente las
% unidades que corresponden a cada tipo de gol
unidades(tiempo(1,_),50).
unidades(tiempo(2,Minuto),Minuto).
unidades(penales(N),Cantidad):-Cantidad is N * 10.
