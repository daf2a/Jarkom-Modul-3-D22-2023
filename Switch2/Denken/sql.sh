mysql -u root -p
Enter password: 

CREATE USER 'kelompokd22'@'%' IDENTIFIED BY 'passwordd22';
CREATE USER 'kelompokd22'@'localhost' IDENTIFIED BY 'passwordd22';
CREATE DATABASE dbkelompokd22;
GRANT ALL PRIVILEGES ON *.* TO 'kelompokd22'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'kelompokd22'@'localhost';
FLUSH PRIVILEGES;