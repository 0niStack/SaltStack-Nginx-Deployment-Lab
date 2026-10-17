{% set cfg = pillar.get('nginx', {}) %}
{% set web_root = cfg.get('web_root', '/var/www/mysite') %}
{% set site = cfg.get('site_name', 'mysite') %}

nginx_pkg:
  pkg.installed:
    - name: nginx

nginx_web_root:
  file.directory:
    - name: {{ web_root }}
    - user: www-data
    - group: www-data
    - mode: '0755'
    - makedirs: True
    - require:
      - pkg: nginx_pkg

nginx_index:
  file.managed:
    - name: {{ web_root }}/index.html
    - source: salt://nginx/files/index.html.jinja
    - template: jinja
    - user: www-data
    - group: www-data
    - mode: '0644'
    - require:
      - file: nginx_web_root

nginx_site_conf:
  file.managed:
    - name: /etc/nginx/sites-available/{{ site }}
    - source: salt://nginx/files/site.conf.jinja
    - template: jinja
    - mode: '0644'
    - require:
      - pkg: nginx_pkg

nginx_site_enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ site }}
    - target: /etc/nginx/sites-available/{{ site }}
    - require:
      - file: nginx_site_conf

nginx_default_disabled:
  file.absent:
    - name: /etc/nginx/sites-enabled/default
    - require:
      - pkg: nginx_pkg

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - file: nginx_index
    - watch:
      - file: nginx_site_conf
      - file: nginx_site_enabled
      - file: nginx_default_disabled
