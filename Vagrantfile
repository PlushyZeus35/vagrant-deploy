# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.env.enable
  # Web Server machine
  config.vm.define "webServer" do |webServer|
    webServer.vm.box = "ubuntu/noble64"
    webServer.vm.network "forwarded_port", guest: 80, host: 8080
    webServer.vm.network "private_network", ip: "192.168.2.111"
    webServer.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    webServer.vm.provision "shell", inline: <<-SHELL
      # Install necessary softwares (apache2, php, yarn, nodejs and npm)
      apt-get update
      apt-get upgrade -y
      apt-get install -y apache2
      apt-get install -y php libapache2-mod-php php-mysql
      apt-get install -y curl

      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      apt-get update
      apt-get install -y yarn
      sudo apt-get install -y nodejs
      sudo apt-get install -y npm

      # Start apache service
      service apache2 start

      # Deploy react app
      sudo git clone https://github.com/sebaignacioo/react-rickandmorty-example.git /var/www/html/app
      cd /var/www/html/app
      sudo npm i
      sudo npm run build
      cd /var/www/html
      sudo rm /var/www/html/index.html
      sudo cp -r /var/www/html/app/dist/* /var/www/html
    SHELL
  end

  config.vm.define "database" do |dataBaseMachine|
    # Machine configuration
    dataBaseMachine.vm.box = "ubuntu/bionic64"
    dataBaseMachine.vm.network "forwarded_port", guest: 80, host: 8081
    dataBaseMachine.vm.network "forwarded_port", guest: 3306, host: 3306
    dataBaseMachine.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    # Send sql file to machine
    dataBaseMachine.vm.provision "file", source: "init.sql", destination: "/vagrant/init.sql"
    
    dataBaseMachine.vm.provision "shell", inline: <<-SHELL
      # Software update
      sudo apt-get update
      sudo apt-get install -y apache2

      # Install MariaDB and configure root user
      sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password_again password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo apt-get install -y mariadb-server

      # Create init database
      mysql -uroot -prootpass -e "CREATE DATABASE alumnos;"

      # Create database user
      mysql -uroot -prootpass -e "CREATE USER '#{ENV['DATABASE_MAIN_USERNAME']}'@'localhost' IDENTIFIED BY '#{ENV['DATABASE_MAINUSER_PASSWORD']}';"
      mysql -uroot -prootpass -e "GRANT ALL PRIVILEGES ON alumnos.* TO '#{ENV['DATABASE_MAIN_USERNAME']}'@'localhost';"
      mysql -uroot -prootpass -e "FLUSH PRIVILEGES;"

      # Execute sql script to create test data
      mysql -uroot -prootpass alumnos < /vagrant/init.sql

      # Install php
      sudo apt-get install -y php libapache2-mod-php php-mysql

      # Install phpmyadmin and configure root user
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
      sudo apt-get install -y phpmyadmin

      # Restart apache service
      sudo service apache2 restart
    SHELL
  end
  
end
