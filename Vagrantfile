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
      # Install necessary softwares
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

      service apache2 start

      sudo git clone https://github.com/sebaignacioo/react-rickandmorty-example.git /var/www/html/app
      cd /var/www/html/app
      sudo npm i
      sudo npm run build
      #sudo yarn install
      #sudo yarn build
      cd /var/www/html
      sudo rm /var/www/html/index.html
      sudo cp -r /var/www/html/app/dist/* /var/www/html
    SHELL
  end

  config.vm.define "database" do |dataBaseMachine|
    # Configuración de la máquina virtual
    dataBaseMachine.vm.box = "ubuntu/bionic64"
    dataBaseMachine.vm.network "forwarded_port", guest: 80, host: 8081
    dataBaseMachine.vm.network "forwarded_port", guest: 3306, host: 3306
    dataBaseMachine.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    # Copiar el script SQL a la máquina virtual
    dataBaseMachine.vm.provision "file", source: "init.sql", destination: "/vagrant/init.sql"
    # Provisión de la máquina virtual
    dataBaseMachine.vm.provision "shell", inline: <<-SHELL
      # Actualizar repositorios e instalar paquetes necesarios
      sudo apt-get update
      sudo apt-get install -y apache2

      # Instalar MariaDB y configurar la contraseña del root
      sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo debconf-set-selections <<< 'mariadb-server-10.1 mysql-server/root_password_again password #{ENV['DATABASE_ROOT_PASSWORD']}'
      sudo apt-get install -y mariadb-server

      # Crear la base de datos 'alumnos'
      mysql -uroot -prootpass -e "CREATE DATABASE alumnos;"

      # Crear usuario 'usuarioadmin' con contraseña 'adminpass' y otorgarle permisos en la base de datos 'alumnos'
      mysql -uroot -prootpass -e "CREATE USER '#{ENV['DATABASE_MAIN_USERNAME']}'@'localhost' IDENTIFIED BY '#{ENV['DATABASE_MAINUSER_PASSWORD']}';"
      mysql -uroot -prootpass -e "GRANT ALL PRIVILEGES ON alumnos.* TO '#{ENV['DATABASE_MAIN_USERNAME']}'@'localhost';"
      mysql -uroot -prootpass -e "FLUSH PRIVILEGES;"
      # Ejecutar script SQL para inicializar la base de datos con datos de prueba
      mysql -uroot -prootpass alumnos < /vagrant/init.sql

      # Instalar PHP y extensiones necesarias
      sudo apt-get install -y php libapache2-mod-php php-mysql

      # Instalar phpMyAdmin y configurar para el servidor MariaDB
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password rootpass'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password rootpass'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password rootpass'
      sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
      sudo apt-get install -y phpmyadmin

      # Reiniciar Apache para aplicar cambios
      sudo service apache2 restart
    SHELL
  end
  
end
