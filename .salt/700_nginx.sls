{% import "makina-states/services/http/nginx/init.sls" as nginx %}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}

include:
  - makina-states.services.http.nginx

{{ nginx.virtualhost(domain=data.domain,
                     vhost_basename="corpus-"+cfg.name,
                     doc_root=data.doc_root,
                     force_reload=true,
                     server_aliases=data.server_aliases,
                     vh_top_source=data.nginx_top,
                     vh_content_source=data.nginx_vhost,
                     project=cfg.name)}}
