# SmartStock

## Introdction
This poroject was part of the ImpactHack hacathon 2023. This aim of this project is to help small SMEs to manage their stock with the help of IA
### Methodology & Technologies used
This system have been develoed using the aglie methodogly and using rubby on rails as the development framework

## System Features 


### HomeScreen
![HomeScreen](https://github.com/GaafarDev/SmartStock/assets/115364146/65acb68e-0257-472e-ba01-d2b5d2590f58)


### Restock
![RestockFeature](https://github.com/GaafarDev/SmartStock/assets/115364146/57da309e-b3b0-4c8a-8d63-d0c677ed63d5)


### Sell Product 
![SellProductFeature](https://github.com/GaafarDev/SmartStock/assets/115364146/1af8acd4-26a7-4628-8021-e92b11abf2f1)

## Ruby version

This project uses Ruby 3.2.2.

## System dependencies

This project uses several gems, including:

- `devise` for authentication
- `font-awesome-rails` for icons
- `activerecord-import` for bulk data import
- `rails` for the web framework
- `sqlite3` for the database
- `puma` for the web server
- `importmap-rails` for JavaScript with ESM import maps
- `turbo-rails` for Hotwire's SPA-like page accelerator
- `stimulus-rails` for Hotwire's modest JavaScript framework

## Configuration

To configure the application, follow the instructions in the `config` directory.

## Database creation

Database is managed by Rails Active Record. Migrations are located in the `db/migrate` directory.

## Database initialization

To initialize the database, run the following command:

```sh
rails db:migrate
