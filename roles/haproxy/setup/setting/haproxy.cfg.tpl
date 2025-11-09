    global
        daemon
        maxconn 256
        log stderr format iso local7

    defaults
        mode tcp
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms
        log global
        option tcplog

    frontend endpoint
        bind *:6443
        default_backend control_plane_servers

    backend control_plane_servers
        balance roundrobin
      {% for item in kube_control_plane %}
        server {{ kube_control_plane[item].host_name }} {{ kube_control_plane[item].internal_address }}:6443 maxconn 32 check
      {% endfor %}
