function install {
  echo installing $1
  shift
  sudo apt-get -y install "$@" >/dev/null 2>&1
}
function gem_install {
	echo installing $1
  shift
  gem install "$@" >/dev/null 2>&1
}

echo updating package information
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential

install Ruby ruby2.3 ruby2.3-dev
update-alternatives --set ruby /usr/bin/ruby2.3 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.3 >/dev/null 2>&1

gem_install Bundler bundler
#gem_install Rails rails

install Redis redis-server
install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'ExecJS runtime' nodejs
install Curl libcurl4-openssl-dev

# Setup nginx with passenger
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
install 'apt-transport-https ca-certificates' apt-transport-https ca-certificates

sudo echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' > /etc/apt/sources.list.d/passenger.list
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list
apt-get -y update >/dev/null 2>&1

install nginx nginx-extras passenger

sudo sed -i "s|# passenger_root|passenger_root|g" /etc/nginx/nginx.conf
sudo sed -i "s|# include /etc/nginx/passenger.conf|include /etc/nginx/passenger.conf|g" /etc/nginx/nginx.conf

sudo service nginx start

# Setup database
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
sudo apt-key add -
sudo apt-get update >/dev/null 2>&1

install postgres libpq-dev postgresql-9.4 postgresql-contrib-9.4

# Enable remote access to postgresql
sudo sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" /etc/postgresql/9.4/main/postgresql.conf
sudo echo "host    all     all     0.0.0.0/0       md5" >> /etc/postgresql/9.4/main/pg_hba.conf

sudo service postgresql restart

#sudo -u postgres createuser --superuser vagrant
sudo -u postgres bash -c "psql -c \"CREATE USER vagrant CREATEDB;\""
sudo -u postgres bash -c "psql -c \"ALTER USER vagrant PASSWORD 'vagrant';\""
sudo -u postgres bash -c "psql -c \"ALTER USER vagrant WITH SUPERUSER;\""

cd /vagrant
sudo -u vagrant bash -c "bundle"
sudo -u vagrant bash -c "rails db:drop:all db:create:all db:migrate"
sudo -u vagrant bash -c "rails db:migrate"
sudo -u vagrant bash -c "rails db:seed"

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "cd /vagrant" >> /home/vagrant/.bashrc
