# Progetto di Ricerca Operativa, A.A. 2019/2020
# Tommaso Azzalin, matricola: 1169740
#
# Modello del problema "Viaggiare LeggeRO"

########################
# INSIEMI DEL PROBLEMA #
########################

# Compagnie di trasporto
set T;

# Corse giornaliere
set C;

# Verso del viaggio (A: Andata, R: Ritorno)
set V;

##################################################
# PARAMETRI (COSTANTI DELL'ISTANZA DEL PROBLEMA) #
##################################################

# Prezzo della corsa c in C nel verso v in V con la compagnia t in T
param p{T, C, V} >= 0;

# Durata della corsa c in C nel verso v in V con la compagnia t in T
param d{T, C, V} >= 0;

# Budget massimo per tutti i viaggi da pianificare
param B >= 0;

# Durata massima di una tratta
param D >= 0;

# Numero di viaggi
param N >= 0 integer;

# Numero di viaggi necessari per l'emissione della Gift Card da parte della compagnia t in T
param nViaggiGC{T} >= 0 integer;

# Valore della Gift Card emessa da parte della compagna t in T
param vScontoGC{T} >= 0;

# Numero massimo di corse che possono essere effettuate con la compagnia t in T
param maxTratte{T} >= 0 integer;

# Big M
param M >= 0;

##########################
# VARIABILI DEL PROBLEMA #
##########################

# Budget utilizzato per ogni compagnia
var b{T} >= 0;

# Numero di volte in cui viene scelta la corsa c in C della compagnia t in T nel verso v in V
var x{T, C, V} >= 0 integer;

# 1: La corsa c in C della compagnia t in T nel verso v in V puo' essere scelta
# 0: La corsa c in C della compagnia t in T nel verso v in V NON puo' essere scelta
var y{T, C, V} binary;

# 1: la gift card della compagnia t in T viene emessa
# 0: la gift card della compagnia t in T non viene emessa
var z{T} binary;

########################
# MODELLO DEL PROBLEMA #
########################

# Funzione obiettivo (problema di minimo)
minimize tempoTotaleViaggi:
	sum{t in T} sum{c in C} sum{v in V} (d[t, c, v] * x[t, c, v]);

# La suddivisione del budget per acquistare biglietti fra le tre compagnie deve sommare a B
s.t. suddivisioneBudget:
	sum{t in T} b[t] <= B;

# Va rispettato il budget complessivo per tutti i viaggi
s.t. budgetTotale{t in T}:
	sum{c in C} sum{v in V} p[t, c, v] * x[t, c, v] = b[t] + vScontoGC[t] * z[t];

# Selezione delle corse che possono essere acquistate dato che rispettano il tempo massimo per corsa richiesto
s.t. sceltaCorse{t in T, c in C, v in V}:
	d[t, c, v] * y[t, c, v] <= D;

# Rispetto del numero di viaggi che devo essere fatti nel periodo considerato
s.t. minimoNumeroViaggi{v in V}:
	sum{t in T} sum{c in C} x[t, c, v] = N;
	
# Rispetto del numero di tratte che si vogliono percorrere con una certa compagnia (0: nessuna, N' (t.c. N' > N): 'qualsiasi') 
s.t. maxTratteCompagnia{t in T}:
    sum{c in C} sum{v in V} x[t, c, v] <= maxTratte[t];

# Attivazione delle variabili binarie (non posso avere x > 0 se y = 0)
s.t. attivazioneVariabiliBinarie{t in T, c in C, v in V}:
	x[t, c, v] <= y[t, c, v] * M;

# Emissione di Gift Card
s.t. giftCard{t in T}:
	sum{c in C} sum{v in V} x[t, c, v] >= nViaggiGC[t] * z[t];
