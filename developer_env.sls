{% if 'cde_username' in grains %}
    {% set login = grains['cde_username'] %}
{% else %}
    {% set login = 'notsetuname' %}
    {% set gitsignature = '' %}
    {% set gitemail = '' %}
{% endif %}

{%- from "files/developer_files/developer_cfg.jinja" import gitcfg with context %}


{% if login != 'notsetuname' %}

{% if gitcfg.gitsignature != '' or gitcfg.gitemail != '' %}

/home/{{ login }}/.gitconfig:
  file.managed:
    - source: salt://files/gitconfig_global.tpl
    - user: {{ login }}
    - group: "users"
    - template: jinja
    - defaults:
        user_signature: {{ gitcfg.gitsignature }}
        user_email: {{ gitcfg.gitemail }}
        
{% endif %}

/home/{{ login }}/.bash_aliases:
  file.managed:
    - source: salt://files/developer_files/bash_aliases.tpl
    - user: {{ login }}   


/home/{{ login }}/.profile:
  file.append:
    - text: |
        if [ `last $USER | wc -l` -lt 2 ]
        then
          setsamba
        fi

{% endif %}
