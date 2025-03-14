"konfiguracja podswietlania
syntax on
set autoindent

"Ustawienia wcięć:
set ts=4 " długość znaku TAB
set sts=4 " ilość spacji zamiast TABa

" Wyświetlanie linijki:
set ruler " włączenie linijki
" set rulerformat=%40(%y/%{&fenc}/%{&ff}%=%l,%c%V%5(%P%)%)
set number " włączenie numerowania linii
set incsearch " wyszukiwanie w czasie wpisywania
set ignorecase " ignoruj wielkość znaków podczas wyszukiwania
set smartcase " nie ignoruj wielkości znaków jeśli użyta została jakaś duza litera
set listchars=trail:_,tab:>- " zamieniaj białe znaki na końcu linii na _ a tabulacje na >-
set history=1000 " ile komand będzie zapisywane w historii
