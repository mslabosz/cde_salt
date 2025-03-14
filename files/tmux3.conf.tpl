set -g prefix C-a

setw -g mode-keys vi

unbind %
bind-key -T split-window -h
bind-key \ split-window -h
bind-key "'" split-window -v
bind-key C-a last-window
#bind-key " " next-window

#bind-key -T vi-edit Up history-up
#bind-key -T vi-edit Down history-down

#unbind [
#bind [ copy-mode
unbind p
bind P paste-buffer
bind-key -T vi-copy 'v' begin-selection
bind-key -T vi-copy 'v' begin-selection
bind-key -T vi-copy 'y' copy-selection
bind-key -T vi-copy 'C-v' rectangle-toggle

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind-key -r C-h select-window -t :-
bind-key -r C-l select-window -t :+

set-option -g status-utf8 on
#set-option -g status-justify centre
set-option -g status-justify left
set-option -g status-bg colour233
set-option -g status-fg white
set-option -g status-left-length 40

set-option -g pane-active-border-fg colour112
set-option -g pane-active-border-bg black
set-option -g pane-border-fg colour240
set-option -g pane-border-bg black

set-option -g message-fg black
set-option -g message-bg green

setw -g window-status-bg colour235
setw -g window-status-fg white
setw -g window-status-current-fg black
setw -g window-status-current-bg colour154
#setw -g window-status-alert-attr default
#setw -g window-status-alert-fg red
setw -g window-status-format ' #I #W '
setw -g window-status-current-format ' #I #W '

set -g status-left '#[fg=colour245]#[bg=colour233]#h#[fg=colour172]>#[fg=white]#[fg=green]#[default]'
#set -g status-right '#[fg=green]][#[fg=white] #T #[fg=green]][ #[fg=blue]%Y-%m-%d #[fg=white]%H:%M#[default]'
#set -g status-right '#[bg=colour255]#[fg=colour240] %Y-%m-%d #[fg=colour232]%H:%M #[default]'
set -g status-right '#[fg=colour240] %Y-%m-%d %H:%M #[default]'

bind-key A command-prompt "rename-window '%%'"
bind-key K confirm-before -p "kill-pane #W? (y/n)" kill-pane

set -g history-limit 32768

bind -r C-h resize-pane -L 4
bind -r C-l resize-pane -R 3
bind -r C-j resize-pane -D 3
bind -r C-k resize-pane -U 3

bind -r M-h resize-pane -L 300
bind -r M-l resize-pane -R 300
bind -r M-j resize-pane -D 300
bind -r M-k resize-pane -U 300

bind -r C-p previous-window
bind -r C-' ' next-window

bind-key < command-prompt -p "join pane from:"  "join-pane -s '%%'"
bind-key > command-prompt -p "send pane to:"  "join-pane -
