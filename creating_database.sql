drop database if exists online_store;
create database online_store;

use online_store;

create table users (
	id BIGINT unsigned not null auto_increment primary key,
	firstname VARCHAR(50),
	lastname VARCHAR(50),
	email VARCHAR(100) unique,
	password_hash VARCHAR (100),
	phone VARCHAR(100) default NULL unique,
	
	index users_firstname_lastname_idx(firstname, lastname)
);

create table categories (
	id SERIAL,
	name VARCHAR(50)
);

create table products (
	id SERIAL,
	name VARCHAR(50),
	description TEXT,
	price DECIMAL(10, 2) default null,
	category_id BIGINT unsigned not null,
	created_at DATETIME default now(),
	updated_at DATETIME on update CURRENT_TIMESTAMP,
	
	foreign key (category_id) references categories(id)
);

create table orders (
	id SERIAL,
	user_id BIGINT unsigned not null,
	created_at DATETIME default now(),
	updated_at DATETIME on update CURRENT_TIMESTAMP,
	`status` ENUM('completed', 'canceled'),
	
	foreign key (user_id) references users(id)
);

create table products_ordered (
	id SERIAL,
	order_id BIGINT unsigned not null,
	product_id BIGINT unsigned not null,
	product_count BIGINT default 1,
	created_at DATETIME default now(),
	updated_at DATETIME on update CURRENT_TIMESTAMP,
	
	foreign key (order_id) references orders(id),
	foreign key (product_id) references products(id)
);

create table `returns` (
	id SERIAL,
	order_id BIGINT unsigned not null,
	product_id BIGINT unsigned not null,
	product_count BIGINT default 1,
	created_at DATETIME default now(),
	updated_at DATETIME on update CURRENT_TIMESTAMP,
	`status` ENUM('completed', 'canceled', 'refunded'),
	
	foreign key (order_id) references orders(id),
	foreign key (product_id) references products(id)
);

create table discounts (
	id SERIAL,
	product_id BIGINT unsigned not null,
	discount BIGINT default null,
	started_at DATETIME default null,
	finished_at DATETIME default null,
	created_at DATETIME default now(),
	updated_at DATETIME on update CURRENT_TIMESTAMP,
	
	foreign key (product_id) references products(id)
);

create table assemblies (
	id SERIAL,
	user_id BIGINT unsigned not null,
	-- id комплектующих
	videocard_id BIGINT unsigned not null,
	proc_id BIGINT unsigned not null,
	ozu_id BIGINT unsigned not null,
	motherboard_id BIGINT unsigned not null,
	ps_id BIGINT unsigned not null,
	drive_id BIGINT unsigned not null,
	cooling_id BIGINT unsigned not null,
	case_id BIGINT unsigned not null,
	
	foreign key (user_id) references users(id),
	-- привязка комплектующих к товарам
	foreign key (videocard_id) references products(id),
	foreign key (proc_id) references products(id),
	foreign key (ozu_id) references products(id),
	foreign key (motherboard_id) references products(id),
	foreign key (ps_id) references products(id),
	foreign key (drive_id) references products(id),
	foreign key (cooling_id) references products(id),
	foreign key (case_id) references products(id)
);

create table reviews (
	id SERIAL,
	user_id BIGINT unsigned not null,
	product_id BIGINT unsigned not null,
	body TEXT,
	created_at DATETIME default now(),
	updated_at DATETIME on update CURRENT_TIMESTAMP,

	foreign key (user_id) references users(id),
	foreign key (product_id) references products(id)
);

create table basket (
	id SERIAL,
	user_id BIGINT unsigned not null,
	product_id BIGINT unsigned not null,
	`count` BIGINT default 1,
	
	foreign key (user_id) references users(id),
	foreign key (product_id) references products(id)
);

	






























