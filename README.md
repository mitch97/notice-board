# Bacheca progetti

Pagina web locale, in un solo file (`bacheca.html`), per tenere sott'occhio i miei progetti: stato, attività da fare, storico e note. Non ha server né librerie: legge e scrive direttamente i file `.md` nella cartella dei progetti.

## Requisiti
- Chrome o Edge (serve la File System Access API; Firefox e Safari non funzionano).
- Una cartella di progetti organizzata come descritto sotto.
- Per il solo script `utilscrypt.py`: Python 3 e `pip install cryptography`.

## Avvio
1. Apri `bacheca.html` con Chrome o Edge (doppio clic o trascinala nel browser).
2. Premi il pulsante per scegliere la cartella dei progetti e consenti l'accesso in lettura e scrittura.
3. Chrome chiede di nuovo il permesso a ogni avvio: è un limite del browser. Scegli "Consenti a ogni visita".
4. Dopo ogni modifica al codice della pagina fai Ctrl+F5, perché il browser tiene la vecchia versione.

## Struttura attesa della cartella
```
<cartella progetti>/
  _STATO-PROGETTI.json      stato di visualizzazione (creato dalla bacheca)
  <progetto>/
    SAL.md                  recap; un progetto esiste solo se ha questo file
    STORICO.md              diario, si aggiunge in fondo
    TODO.md                 attività aperte
    UTILS.enc               note e credenziali cifrate (oppure UTILS.md in chiaro)
    *.md, *.txt, *.pdf      altri documenti, mostrati nella scheda Documenti
```

### Formato dei file
- **SAL.md**: la riga `Ultimo aggiornamento: AAAA-MM-GG` fornisce la data mostrata nelle schede.
- **TODO.md**: sezioni con titoli `##` o `###`; ogni attività è una riga
  `- [ ] **P1** **Titolo breve** — dettagli`
  Marcatori: `[ ]` da fare, `[~]` in corso, `[?]` in attesa, `[t]` in test, `[x]` fatta. Priorità `P1`, `P2`, `P3` oppure assente. Il titolo in grassetto (max 5 parole) si vede nell'elenco, i dettagli si aprono con un clic. Senza grassetto la bacheca ricava il titolo dalle prime parole.
- Le attività si possono creare dalla bacheca ("+ Nuova attività"): la riga viene scritta in `TODO.md` nel formato sopra.
- Spostare un'attività dalla bacheca modifica direttamente `TODO.md`. Quando passa a fatta viene aggiunta in fondo alla riga la data (`✓2026-10-21`), che si toglie se la riporti in un'altra colonna.
- **Stato dei progetti**: `_STATO-PROGETTI.json` salva per ogni progetto `stato` (`attesa`, `test` o `terminato`; assente = in corso), colore, nome mostrato e scadenza.

## Cosa fa
- Elenco dei progetti in vista a blocchi, a elenco o **kanban** (In attesa / In corso / Test / Terminato), con ordinamento per priorità, alfabetico, ultima modifica o manuale (trascinando).
- **Kanban del progetto**: scheda dedicata con le colonne In attesa / Da fare / In corso / Test / Fatto (ultimi 14 giorni). Si trascina o si usa "Sposta"; avviso se ci sono più di 3 attività in corso. Le colonne sono sempre ordinate per priorità (P1, P2, P3); dentro la stessa priorità si può cambiare l'ordine trascinando le schede (vale l'ordine delle righe del `TODO.md`).
- Scadenza, colore e nome mostrato per ogni progetto, salvati in `_STATO-PROGETTI.json`.
- Vista "Da fare" con tutte le attività aperte, con opzione "In corso in alto".
- Sezioni SAL, TODO, STORICO, UTILS e Documenti per progetto, con ricerca globale.
- Segnare un progetto come terminato e riaprirlo.

## UTILS cifrati
- Le credenziali stanno in `UTILS.enc`, cifrato con AES-256-GCM (chiave ricavata dalla password con PBKDF2-SHA256, 600000 iterazioni).
- La password non viene salvata da nessuna parte: resta in memoria e la sezione si blocca dopo 5 minuti di inattività.
- Per cifrare un `UTILS.md` esistente usa il pulsante nella scheda UTILS del progetto: il file in chiaro viene sostituito da un segnaposto.
- `utilscrypt.py` fa la stessa operazione da riga di comando: `dec(percorso, password)` restituisce il testo, `enc(testo, password, percorso)` scrive il file cifrato. Il formato è compatibile con quello della bacheca.

## Dati che non vanno nel repository
Questo repository contiene solo lo strumento. I dati dei progetti (SAL, STORICO, TODO, UTILS, `_STATO-PROGETTI.json`) restano sul PC e sono esclusi dal `.gitignore`. Non committare mai file con credenziali: la cronologia di Git li conserva per sempre.
