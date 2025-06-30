events {
  worker_connections 1024;
}

http {
  upstream subgraph {
    server {{ .Release.Name }}-subgraph:8080;
  }

  server {
    listen 80;
    server_name {{ .Values.proxy.ingress.host }};

    location ^~ /{{ .Values.indexerName }}/ {
      proxy_pass         http://subgraph;
      proxy_set_header   Host              $host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto $scheme;

      # WebSocket
      proxy_http_version 1.1;
      proxy_set_header   Upgrade           $http_upgrade;
      proxy_set_header   Connection        "upgrade";
    }

    {{- if not .Values.indexerName }}
    location / {
      proxy_pass         http://subgraph;
      proxy_set_header   Host              $host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto $scheme;
      proxy_http_version 1.1;
      proxy_set_header   Upgrade           $http_upgrade;
      proxy_set_header   Connection        "upgrade";
    }
    {{- end }}
  }
}