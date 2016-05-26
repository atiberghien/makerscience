{% set cfg = opts['ms_project'] %}
{% set data = cfg.data %}
{% set name = cfg.name %}
{% set js_build =  data.get('do_npm', False) or data.get('do_gulp', False) or data.get('do_grunt', False) %}
{% if js_build %}
{% set path = ('{data[js_dir]}/node_modules/.bin:'
               '{data[node_root]}/bin:'
               '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:'
               '/sbin:/bin:/usr/games:/usr/local/games').format(**cfg) %}

{{cfg.name}}-env:
  file.managed:
    - name: "{{cfg.project_root}}/node_env.sh"
    - contents: |
              export PATH="{{path}}"
    - mode: 755

{% macro node_run(id, require=None) %}
{{id}}:
  cmd.run:
    - watch:
      - file: {{cfg.name}}-env
      {% if require %}
      {% for i in require %}
      - {{i}}
      {%endfor%}
      {%endif%}
    - cwd: "{{data.js_dir}}"
    - user: {{cfg.user}}
    - unless: test ! -e "{{data.get('js_dir', '/dev/nonexisting')}}"
    - use_vt: true
    - env:
        PATH: "{{path}}"
{% endmacro %}

{{node_run('{name}-npm'.format(**cfg))}}
    - name: |
            set -ex
            npm install
            {% for i in data.get('node_packages', []) %}
            npm install {{i}}
            {% endfor %}


{% if data.get('do_bower', False) %}
{{node_run('{name}-install-bower'.format(**cfg),
            require=['cmd: {name}-npm'.format(**cfg)])}}
    - onlyif: test ! -e node_modules/.bin/bower
    - name: npm install bower

{{node_run('{name}-bower'.format(**cfg),
           require=['cmd: {name}-install-bower'.format(**cfg)])}}
    - name: |
            set -ex
            bower install --config.analytics=false --config.interactive=false ||\
              bower install -f --config.analytics=false --config.interactive=false

{% set t = ['cmd: {name}-bower'.format(**cfg)] %}
{% else %}
{% set t = ['cmd: {name}-npm'.format(**cfg)] %}
{% endif %}


{% if data.get('do_gulp', False) %}
{{node_run('{name}-gulp'.format(**cfg),
           require=t)}}
    - name: |
            set -e
            {% for i in data.get('gulp_targets', ['clean-build']) %}
            gulp {{i}}
            {% endfor %}
{% endif %}

{% if data.get('do_grunt', False) %}
{{node_run('{name}-grunt'.format(**cfg),
           require=t)}}
    - name: |
            set -e
            {% for i in data.get('grunt_targets', ['']) %}
            grunt {{i}}
            {% endfor %}
{% endif %}

{% else %}
{{cfg.name}}-skip:
  mc_proxy.hook: []
{% endif %}
