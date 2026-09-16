create table restaurent_tables(
table_number integer primary key,
capacity integer not null check(capacity>=2 and capacity<=8),
dining_section varchar not null
)
create table customers(
customer_id integer generated always as identity primary key,
full_name varchar(50) not null,
phone varchar(20) not null,
email varchar(30) default 'Unknown'

)
create table staff(

staff_id integer generated always as identity primary key,
full_name varchar(50) not null,
phone varchar(20) not null,
staff_role varchar(20) not null,
hire_date date


)
create table reservations(
reservation_id integer generated always as identity primary key,
customer_id  integer not null,
table_number integer not null,
staff_id  integer not null,
reservation_date date ,
start_time time,
end_time time,
party_size integer  check(party_size>0),
stage_state varchar(50)  default 'Pending' check(lower(stage_state) in ('pending','booked','confirmed','seated','completed','canceled')),

foreign key(customer_id) references customers(customer_id),
foreign key(table_number) references restaurent_tables(table_number),
foreign key(staff_id) references staff(staff_id)
)

create table orders(
order_id integer generated always as identity primary key,
status varchar(50) not null default 'Open'  CHECK (lower(status) IN ('open','closed','cancelled')),
reservation_id integer not null,
bill decimal(10,2) ,
foreign key(reservation_id) references reservations(reservation_id)

)
create table menu_item(
menu_item_id integer  generated always as identity primary key ,
category varchar(50),
price decimal(10,2) unique not null,
stock_quantity integer

)
create table order_menuitem(
quantity_recorded integer check(quantity_recorded>0),

menu_item_id integer  not null,
order_id integer not null,
PRIMARY KEY (order_id, menu_item_id),
foreign key (menu_item_id) references menu_item(menu_item_id),
foreign key (order_id) references orders(order_id)

)