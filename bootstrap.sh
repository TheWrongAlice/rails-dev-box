# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
  echo installing $1
  shift
  apt-get -y install "$@" >/dev/null 2>&1
}
function gem_install {
  echo installing $1
  shift
  gem install "$@" -N >/dev/null 2>&1
}

echo adding swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

echo updating package information
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential

install Ruby ruby2.4 ruby2.4-dev
update-alternatives --set ruby /usr/bin/ruby2.4 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.4 >/dev/null 2>&1

echo installing current RubyGems
gem update --system -N >/dev/null 2>&1

gem_install Bundler bundler

install Git git
install SQLite sqlite3 libsqlite3-dev
install Memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server

install PostgreSQL postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser --superuser vagrant
sudo -u postgres createdb -O vagrant activerecord_unittest
sudo -u postgres createdb -O vagrant activerecord_unittest2

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev
# Set the password in an environment variable to avoid the warning issued if set with `-p`.
MYSQL_PWD=root mysql -uroot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
SQL

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'Blade dependencies' libncurses5-dev
install 'ExecJS runtime' nodejs

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Set the default directory for terminal
echo "cd /vagrant" >> /home/ubuntu/.bashrc
cd /vagrant

echo "installing Rails"
sudo -u ubuntu bash -c "apt install -y ruby-railties"
sudo -u ubuntu bash -c "bundle"
sudo -u ubuntu bash -c "rails db:drop:all db:create:all"
sudo -u ubuntu bash -c "rails db:migrate"

echo 'setup finished, have fun!'
