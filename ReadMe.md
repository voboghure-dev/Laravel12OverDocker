Here I will write step by step command need to build the container and install
laravel in container.
Fix how to issues for this project.

Installation process step by step:
1. make build (onetime only)
2. make up
3. make bash
4. laravel new myapp
5. shopt -s dotglob
6. mv myapp/* .
7. rm -rf myapp
8. Open .env file from pos-with-laravel and update database credentials as follows,
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=pos_with_laravel
DB_USERNAME=tapandb
DB_PASSWORD=Admin123!

Optional: To clean pos-with-laravel folder if wants to reinstall laravel

sudo rm -rf pos-with-laravel/*
sudo rm -rf pos-with-laravel/.[!.]* pos-with-laravel/..?*