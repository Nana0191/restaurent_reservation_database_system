create or replace view  today_schedule As
select t.table_number,t.dining_section,c.full_name  "customer name",c.phone,r.start_time,r.end_time,r.stage_state,r.party_size,s.full_name  "staff name"
from restaurent_tables t
inner join  reservations  r
on r.table_number=t.table_number
inner join customers c
on c.customer_id=r.customer_id
inner join staff s
on s.staff_id = r.staff_id
where r.reservation_date=current_date
ORDER BY r.start_time;


create or replace view customer_history As
select c.customer_id,c.full_name,c.phone,r.table_number,r.reservation_date,r.start_time,
r.end_time,r.stage_state
from customers c inner join 
reservations r 
on r.customer_id=c.customer_id;






create or replace  view flagged_customers As
select c.customer_id,c.full_name,c.phone,count(*) as  cancelled_reservations
from customers c
inner join reservations r on
c.customer_id =r.customer_id
where r.stage_state='canceled'
GROUP BY c.customer_id,c.full_name,c.phone   --every column in select must appear in the group by 
having count(*)>=2
ORDER BY cancelled_reservations DESC;


create or replace view revenue As
select r.reservation_date,sum(o.bill) as total_revenue
from orders o inner join reservations r
on o.reservation_id = r.reservation_id
where o.status='closed'
group by r.reservation_date
order by r.reservation_date;



create or replace view most_ordered_items As
select m.category ,sum(mo.quantity_recorded) as total_quantity
from orders o inner join order_menuitem mo
on o.order_id=mo.order_id
inner join menu_item m
on m.menu_item_id=mo.menu_item_id
WHERE o.status = 'closed'
group by m.category
order by total_quantity desc;




create or replace function check_part_size_table_size()
returns trigger as $$
declare
table_capacity integer;
begin
select  capacity into table_capacity
from restaurent_tables r
where r.table_number=new.table_number;
if new.party_size>table_capacity then
raise exception 'the party size (%) for table number % exceeds the table size (%)',
new.party_size,new.table_number,table_capacity;
end if;
return new;
end;
$$ language plpgsql;



create trigger part_check_trigger
before insert or update on reservations
for each row
execute function  check_part_size_table_size();







create or replace function overrlap_reservation()
returns trigger as $$
declare
conflict_count integer;
begin
 select count(*) into conflict_count
 from reservations
 where stage_state <>'canceled'
 and reservation_date=new.reservation_date
 and
 table_number=new.table_number
 AND reservation_id != NEW.reservation_id
 and 
 new.start_time< end_time and  new.end_time>start_time;
 if conflict_count >0 then
 raise exception 'this table is already reserved during this time ';
 end if;
 return new;
end;
$$ language plpgsql;



create trigger overllap_trigger
before insert or update on reservations
for each row

execute function overrlap_reservation();



create or replace function outofstock()
returns trigger as $$
declare
quantity integer;
begin 
select   stock_quantity into  quantity
from menu_item
where menu_item_id =new.menu_item_id;



if quantity < new.quantity_recorded then
raise exception 'not enough stock the current stock (%)  while the required (%)',
quantity, new.quantity_recorded;
end if;

update  menu_item 
set stock_quantity=stock_quantity-new.quantity_recorded
where menu_item_id=new.menu_item_id;


return new;
end;
$$ language plpgsql;

create trigger outofstock_trigger
before insert on order_menuitem
for each row
execute function  outofstock();



create or replace function calcbill()
returns trigger as $$
declare 
v_total numeric(10,2);
begin
if new.status ='closed' then 
select sum(m.price* om.quantity_recorded) into v_total
from order_menuitem om inner join 
menu_item m on m.menu_item_id=om.menu_item_id
where om.order_id=new.order_id;

new.bill:=v_total;
end if;
return new;
end;
$$ language plpgsql;


create trigger billcalc_trigger
before update on  orders
for each row 
execute function calcbill();


