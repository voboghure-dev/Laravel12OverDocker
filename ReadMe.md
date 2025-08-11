Here I will write step by step command need to build the container and install
laravel in container.
Fix how to issues for this project.

Installation process step by step:
1. make up
2. make bash
3. composer create-project laravel/laravel .
4. php artisan key:generate
5. chown -R www-data:www-data storage bootstrap/cache
6. chmod -R 775 storage bootstrap/cache
7. Exit from bash and run the following in host OS,
sudo chown -R $(id -u):$(id -g) ./pos-with-laravel

8. Open .env file from pos-with-laravel and update database credentials as follows,
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=pos_with_laravel
DB_USERNAME=tapandb
DB_PASSWORD=Admin123!