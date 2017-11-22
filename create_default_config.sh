sudo cat > /etc/nginx/sites-enabled/default << EOM
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	listen 443 ssl http2 default_server;
	listen [::]:443 ssl http2 default_server;

	server_name localhost;
	include snippets/self-signed.conf;
	include snippets/ssl-params.conf;

	root /vagrant/public;

	location /somedir {
		autoindex on;
	}

	# serve static content directly
	location ~* \.(ico|jpg|gif|png|css|js|swf|html)$ {
		if (-f \$request_filename) {
			expires max;
			break;
		}
	}

	passenger_enabled on;
	rails_env development;

	location ~ /\.ht {
		deny  all;
	}
}
EOM

sudo service nginx restart
