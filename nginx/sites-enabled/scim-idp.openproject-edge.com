server {
        listen 80;
        listen [::]:80;

        server_name scim-idp.openproject-edge.com;

        location /.well-known/acme-challenge {
                root /var/www/letsencrypt/scim-idp.openproject-edge.com;
        }

        location / {
                return 301 https://$host$request_uri;
        }
}

server {
        listen 443 ssl;
        listen [::]:443 ssl;

        ssl_certificate /etc/letsencrypt/live/scim-idp.openproject-edge.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/scim-idp.openproject-edge.com/privkey.pem;

        add_header Strict-Transport-Security max-age=31536000;

        server_name scim-idp.openproject-edge.com;

        location / {
                proxy_pass http://keycloak:3000;
        }
}
