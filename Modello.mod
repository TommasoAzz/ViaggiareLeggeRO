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

# Prezzo della c-esima (c in C) corsa nel verso v in V con la compagnia t in T
param p{T, C, V} >= 0;

# Durata della c-esima (c in C) corsa nel verso v in V con la compagnia t in T
param d{T, C, V} >= 0;

# Budget massimo per tutti i viaggi effettuati
param B >= 0;

# Durata massima di un viaggio
param D >= 0;

# Minimo numero di viaggi
param N >= 0;

# Numero di viaggi necessari per l'emissione della Gift Card da parte della compagnia t in T
param nViaggiGC{T};

# Valore della Gift Card emessa da parte della compagna t in T
param vScontoGC{T};

# Tempo aggiuntivo richiesto per almeno un viaggio pur di rientrare nel budget richiesto
param tempoAgg;

# Big M
param M >= 0;

##########################
# VARIABILI DEL PROBLEMA #
##########################

# Budget utilizzato per ogni compagnia
var b{T} >= 0;

# 1: È necessario tempoAgg per almeno una corsa pur di assicurarsi una pianificazione dal costo rientrante nel budget
# 0: NON è necessario tempoAgg per almeno una corsa pur di assicurarsi una pianificazione dal costo rientrante nel budget
var w binary;

# Numero totale di volte in cui è stata scelta la c-esima (c in C) corsa della compagnia t in T nel verso v in V
var x{T, C, V} >= 0 integer;

# 1: La c-esima (c in C) corsa della compagnia t in T nel verso v in V può essere scelta
# 0: La c-esima (c in C) corsa della compagnia t in T nel verso v in V NON può essere scelta
var y{T, C, V} binary;

# 1: Viene emessa la Gift Card di vScontoGC[t] (t in T) perché sono stati effettuati nViaggiGC[t] (t in T)
# 0: NON viene emessa la Gift Card di vScontoGC[t] (t in T) perché NON sono stati effettuati nViaggiGC[t] (t in T)
var z{T} binary;

########################
# MODELLO DEL PROBLEMA #
########################

# Funzione obiettivo (problema di minimo)
minimize tempoTotaleViaggi:
	# (sum{t in T} sum{c in C} sum{v in V} p[t, c, v] * x[t, c, v]) - sum{t in T} (vScontoGC[t] * z[t]);
	sum{t in T} sum{c in C} sum{v in V} (d[t, c, v] * x[t, c, v]);

# La suddivisione del budget per acquistare biglietti fra le tre compagnie deve sommare a B
s.t. suddivisioneBudget:
	sum{t in T} b[t] = B;

# Va rispettato il budget complessivo per tutti i viaggi
s.t. budgetTotale{t in T}:
	sum{c in C} sum{v in V} p[t, c, v] * x[t, c, v] <= b[t] + vScontoGC[t] * z[t];

# Selezione delle corse che possono essere acquistate poiché rispettano il tempo massimo per corsa richiesto
s.t. sceltaCorse{t in T, c in C, v in V}:
	d[t, c, v] * y[t, c, v] <= D;

# Rispetto del minimo numero di viaggi che devo essere fatti nel periodo considerato
s.t. minimoNumeroViaggi{v in V}:
	sum{t in T} sum{c in C} x[t, c, v] >= N;

# Attivazione delle variabili binarie (non posso avere x > 0 se y = 0)
s.t. attivazioneVariabiliBinarie{t in T, c in C, v in V}:
	x[t, c, v] <= y[t, c, v] * M;

# Emissione di Gift Card
s.t. giftCard{t in T}:
	sum{c in C} sum{v in V} x[t, c, v] >= nViaggiGC[t] * z[t];
