{% if 'cde_username' in grains %}
    {% set login = grains['cde_username'] %}
{% else %}
    {% set login = 'notsetuname' %}
{% endif %}

dev-packages:
    pkg.installed:
        - pkgs:
            - zsh
            - colordiff

/home/{{ login }}/.dir_colors:
    file.managed:
        - source: salt://files/dir_colors
        - user: {{ login }}

/home/{{ login }}/.zshrc:
    file.managed:
        - source: salt://files/zshrc
        - user: {{ login }}

/home/{{ login }}/.profile.d:
    file.recurse:
        - source: salt://files/profile.d
        - include_empty: True
        - user: {{ login }}
        
powerline-status:
    cmd.run:
        - name: pip install -i http://pypi-mirror.c1r1.onet --user powerline-status
        - user: {{ login }}
        - unless: pip freeze | grep powerline-status

https://github.com/robbyrussell/oh-my-zsh.git:
    git.latest:
        - target: /home/{{ login }}/.oh-my-zsh