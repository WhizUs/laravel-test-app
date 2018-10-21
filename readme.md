# Simple Laravel App

## Prerequisites
laravel 5.7
php 7.2
composer
docker

## Usage
Create .env file from .env.example
`docker build -t IMAGE_NAME .`
`docker run -d -p 12345:80 -p 8100:8000 --name CONTAINER_NAME IMAGE_NAME`
 Go to http://localhost:12345/hello/NAME
 
## Dev
Routing is configured in app/Http/routes.php
Controller is located in app/Htpp/Controllers/Hello.php
View Template is located in resources/views/*.php