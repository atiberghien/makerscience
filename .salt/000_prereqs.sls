{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set js_build =  data.get('do_npm', False) or data.get('do_gulp', False) or data.get('do_grunt', False) %}
{% if js_build %}
include:
  - makina-states.localsettings.nodejs
  - makina-states.localsettings.npm
{% endif %}

{% if js_build %}
prepreqs-{{cfg.name}}:
  pkg.installed:
    - pkgs:
      - ruby-compass
{% endif %}

{{cfg.name}}-dirs:
  file.directory:
    - makedirs: true
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - names:
      - {{cfg.data.doc_root}}
