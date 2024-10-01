-- 1) Вывести к каждому самолету класс обслуживания и количество мест этого класса
select model, s.fare_conditions, count(s.seat_no) as number_of_seats 
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code 
group by model, s.fare_conditions  
order by model 


-- 2) Найти 3 самых вместительных самолета (модель + кол-во мест)
select model, count(s.seat_no) as number_of_seats 
from aircrafts a
join seats s on a.aircraft_code = s.aircraft_code 
group by model  
order by number_of_seats desc
limit 3


-- 3) Найти все рейсы, которые задерживались более 2 часов
select * 
from flights f 
where DATE_PART('hour', f.actual_departure) - DATE_PART('hour', f.scheduled_departure) > 2


-- 4) Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
select t.passenger_name, t.contact_data 
from tickets t 
join ticket_flights tf on t.ticket_no = tf.ticket_no 
where tf.fare_conditions = 'Business'
order by t.ticket_no desc 
limit 10


-- 5) Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
select f
from flights f s
join ticket_flights tf on f.flight_id = tf.flight_id 
join tickets t on tf.ticket_no = t.ticket_no 
join bookings b on t.book_ref = b.book_ref 
where tf.fare_conditions != 'Business'


-- 6) Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой по вылету
select distinct airport_name , city
from airports a 
join flights f on a.airport_code  = f.departure_airport 
where DATE_PART('minute', f.actual_departure) - DATE_PART('minute', f.scheduled_departure) != 0


-- 7) Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
select airport_name , count(f.flight_id) as number_of_flight
from airports a 
join flights f on a.airport_code  = f.departure_airport 
group by airport_name 
order by number_of_flight desc


-- 8) Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
select f 
from flights f 
where DATE_PART('minute', f.actual_arrival) - DATE_PART('minute', f.scheduled_arrival) != 0


-- 9) Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
select a.aircraft_code, a.model, s.seat_no 
from aircrafts a 
join seats s on a.aircraft_code = s.aircraft_code 
where a.model = 'Аэробус A321-200' and s.fare_conditions != 'Economy'
order by s.seat_no 


-- 10) Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
select city
from airports a 
group by city 
having count(city) > 1 


-- 11) Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
select t.passenger_name, sum(b.total_amount) as total_price_of_booking
from tickets t 
join bookings b on b.book_ref = t.book_ref 
group by t.passenger_name 
having sum(b.total_amount) > (select avg(b2.total_amount) from bookings b2 ) 


-- 12) Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
select f.flight_no, f.scheduled_departure, f.departure_airport, f.arrival_airport
from flights f
join airports dep on f.departure_airport = dep.airport_code
join airports arr on f.arrival_airport = arr.airport_code
where dep.city = 'Екатеринбург'
  and arr.city = 'Москва'
  and f.scheduled_departure > bookings.now()
order by f.scheduled_departure
limit 1;


-- 13) Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(select ticket_no, amount
from ticket_flights
order by amount asc
limit 1)
union all
(select ticket_no, amount
from ticket_flights
order by amount desc
limit 1);


-- 14) Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)

create table customers (
	id serial primary key,
	firstname varchar(50) not null,
	lastname varchar(50) not null,
	email varchar(100) unique not null,
	phone varchar(20) not null
);


-- 15) Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints

create table orders (
	id serial primary key,
	customerid int references customers(id),
	quantity int not null,
	constraint chk_quantity check (quantity > 0)
);


-- 16) Написать 5 insert в эти таблицы

insert into customers (firstname, lastname, email, phone)
values 
('John', 'Doe', 'john.doe@example.com', '555-1234'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678'),
('Michael', 'Johnson', 'michael.johnson@example.com', '555-8765'),
('Emily', 'Davis', 'emily.davis@example.com', '555-4321'),
('David', 'Clark', 'david.clark@example.com', '555-9876');


insert into orders (customerid, quantity)
values 
(1, 3),
(2, 5),
(3, 2),
(4, 4),
(5, 1);


-- 17) Удалить таблицы
drop table if exists orders;
drop table if exists customers;
