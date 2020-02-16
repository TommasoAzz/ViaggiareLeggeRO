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

# Verso del viaggio (Andata, Ritorno)
set V;

##########################
# VARIABILI DEL PROBLEMA #
##########################

# Budget utilizzato per una compagnia t in T
var b{T} >= 0;

# Numero di volte in cui viene scelta la corsa c in C della compagnia t in T nel verso v in V
var x{T, C, V} >= 0 integer;

# 1: La corsa c in C della compagnia t in T nel verso v in V puo' essere scelta
# 0: La corsa c in C della compagnia t in T nel verso v in V NON puo' essere scelta
var y{T, C, V} binary;

# 1: la gift card della compagnia t in T viene emessa
# 0: la gift card della compagnia t in T NON viene emessa
var z{T} binary;

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

# Numero di viaggi da pianificare
param N >= 0 integer;

# Numero di viaggi necessari per l'emissione della gift card da parte della compagnia t in T
param nViaggiGC{T} >= 0 integer;

# Valore della gift card emessa da parte della compagna t in T
param vScontoGC{T} >= 0;

# Numero massimo di corse effettuabili con la compagnia t in T
param maxTratte{T} >= 0 integer;

# Big M
param M >= 0;

########################
# MODELLO DEL PROBLEMA #
########################

# Funzione obiettivo (problema di minimo)
minimize tempoTotaleViaggi:
	sum{t in T} sum{c in C} sum{v in V} (d[t, c, v] * x[t, c, v]);

# Il budget totale a disposizione viene diviso per tutte le compagnie (necessario per applicare correttamente gli sconti dati dalle gift card)
subject to suddivisioneBudget:
	sum{t in T} b[t] <= B;

# Va rispettato il budget complessivo per tutti i viaggi acquistati, tenendo conto dell'emissione delle gift card
subject to budgetTotale{t in T}:
	sum{c in C} sum{v in V} p[t, c, v] * x[t, c, v] = b[t] + vScontoGC[t] * z[t];

# Possono  essere  scelte  solo  le  corse  che  rispettano  il  tempo  massimo  per  corsa  richiesto
subject to sceltaCorse{t in T, c in C, v in V}:
	d[t, c, v] * y[t, c, v] <= D;

# Devono essere pianificati esattamente tanti viaggi quanti richiesti
subject to numeroViaggiPianificati{v in V}:
	sum{t in T} sum{c in C} x[t, c, v] = N;
	
# Vanno rispettati i limiti massimi di tratte per ogni compagnia
subject to maxTratteCompagnia{t in T}:
    sum{c in C} sum{v in V} x[t, c, v] <= maxTratte[t];

# Creazione di un legame fra x e y, infatti non posso avere y = 0, x > 0 (attivazione delle variabili binarie)
subject to attivazioneVariabiliBinarie{t in T, c in C, v in V}:
	x[t, c, v] <= y[t, c, v] * N;

# Emissione delle gift card (attivazione delle variabili binarie)
subject to giftCard{t in T}:
	sum{c in C} sum{v in V} x[t, c, v] >= nViaggiGC[t] * z[t];
