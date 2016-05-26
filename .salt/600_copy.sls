{% set cfg = opts.ms_project %}
{% set data = cfg.data %}


{{cfg.name}}-docroot:
  cmd.run:
    - name: |
            set -ex
            rsync \
              {{data.get('rsync_dist_opts', '-aA --delete')}} \
              "{{data.dist_root}}/" "{{data.doc_root}}/"
    - user: {{cfg.user}}
