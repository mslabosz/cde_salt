{% if 'cde_username' in grains %}
    {% set login = grains['cde_username'] %}
{% else %}
    {% set login = 'notsetuname' %}
{% endif %}

mc:
  pkg.installed

tmux:
  pkg.installed

nano:
  pkg.installed

tig:
  pkg.installed

dos2unix:
  pkg.installed

atttt:
  pkg.installed:
    - name: at
  service.running:
    - name: atd
    - enable: True

awsrequired:
  pkg.installed:
    - pkgs:
      - awscli
      - gconf-service
      - libxext6
      - libxfixes3
      - libxi6
      - libxrandr2
      - libxrender1
      - libcairo2
      - libcups2
      - libdbus-1-3
      - libexpat1
      - libfontconfig1
      - libgcc1
      - libgconf-2-4
      - libgdk-pixbuf2.0-0
      - libglib2.0-0
      - libgtk-3-0
      - libnspr4
      - libpango-1.0-0
      - libpangocairo-1.0-0
      - libstdc++6
      - libx11-6
      - libx11-xcb1
      - libxcb1
      - libxcomposite1
      - libxcursor1
      - libxdamage1
      - libxss1
      - libxtst6
      - libappindicator1
      - libnss3
      - libasound2
      - libatk1.0-0
      - libc6
      - ca-certificates
      - fonts-liberation
      - lsb-release
      - xdg-utils
      - wget

azzurelogin:
  cmd.run:
    - name: 'export PATH="/opt/sdk/node_v14/bin/:$PATH"; npm install -g aws-azure-login --unsafe-perm'

{% if login != 'notsetuname' %}

/home/{{ login }}/.tmux.conf:
  file.managed:
    - source: salt://files/tmux.conf.tpl
    - user: {{ login }}
    - group: "users"
    - require:
      - pkg: tmux

/home/{{ login }}/.gitignore_global:
  file.managed:
    - source: salt://files/gitignore_global
    - user: {{ login }}
    - group: "users"

/home/{{ login }}/.aws:
  file:
    - recurse
    - source: salt://files/.aws
    - user: {{ login }}
    - group: "users"
    - makedirs: True
    - dir_mode: 775
    - file_mode: 775

/home/{{ login }}/.ssh:
  file.directory:
    - user: {{ login }}
    - group: "users"
    - dir_mode: 700
    - makedirs: True

{% endif %}
