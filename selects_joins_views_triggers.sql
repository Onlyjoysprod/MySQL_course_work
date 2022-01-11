-- Найти всех пользователей, которые не делали заказы
select * from users u
	where u.id not in
		(select user_id from orders o);
		
	
-- Поиск товаров с активными скидками с добавлением информации о товаре из таблицы products, цене без скидки/со скидкой и наименованием категории из categories
select d.id, d.product_id, d.discount , d.finished_at, p.id, p.name, p.price, p.price - ((p.price * d.discount) / 100) as price_with_discount, c.name
from discounts d
	join products p on p.id = d.product_id 
	join categories c on p.category_id = c.id
where finished_at >= current_date();


-- Процедура поиска отзывов о конкретном товаре с добавлением информации о товаре
drop procedure find_review;

delimiter //

create procedure find_review(in for_product_id BIGINT)
	begin
		select r.user_id, r.product_id, r.body, r.created_at, p.name, p.price, c.name 
		from reviews r 
			join products p on p.id = r.product_id 
			join categories c on p.category_id = c.id 
		where r.product_id = for_product_id;
			
	end //

delimiter ;

call find_review(2);


-- Процедура поиска сборок конкретного пользователя с добавлением информации о каждом элементе сборки, его цене и итоговой стоимости сборки
drop procedure find_assemble;

delimiter //

create procedure find_assemble(in for_user_id BIGINT)
	begin
		select a.id, 
			p.name as videaocard, p.price as video_price, 
			p2.name as processor, p2.price as proc_price,
			p3.name as ram, p3.price as ram_price,
			p4.name as motherboard, p4.price as mb_price,
			p5.name as power_suply, p5.price as ps_price,
			p6.name as drive, p6.price as drive_price,
			p7.name as colling_system, p7.price as cs_price,
			p8.name as `case`, p8.price as case_price,
			(p.price + p2.price + p3.price + p4.price + p5.price + p6.price + p7.price + p8.price) as total_price
		from assemblies a
			join products p on p.id = a.videocard_id
			join products p2 on p2.id = a.proc_id
			join products p3 on p3.id = a.ozu_id
			join products p4 on p4.id = a.motherboard_id
			join products p5 on p5.id = a.ps_id
			join products p6 on p6.id = a.drive_id 
			join products p7 on p7.id = a.cooling_id 
			join products p8 on p8.id = a.case_id
		where a.user_id = for_user_id;
			
	end //

delimiter ;

call find_assemble(1);

 
-- Триггер для проверки категории товара, который выбирается при формировании сборки (Чтобы на позицию видеокарты нельзя было выбрать процессор и т.п.)
delimiter //

create trigger check_product_category before insert on assemblies 
for each row 
begin 
	if new.videocard_id not in (select id from products p where category_id = 1)
		then signal sqlstate '45001' set message_text = 'Choosed wrong videocard';
	elseif new.proc_id not in (select id from products p where category_id = 2)
		then signal sqlstate '45001' set message_text = 'Choosed wrong processor';
	elseif new.ozu_id not in (select id from products p where category_id = 3)
		then signal sqlstate '45001' set message_text = 'Choosed wrong RAM';
	elseif new.motherboard_id not in (select id from products p where category_id = 4)
		then signal sqlstate '45001' set message_text = 'Choosed wrong motherboard';
	elseif new.ps_id not in (select id from products p where category_id = 5)
		then signal sqlstate '45001' set message_text = 'Choosed wrong power suply';
	elseif new.drive_id not in (select id from products p where category_id = 6)
		then signal sqlstate '45001' set message_text = 'Choosed wrong drive';
	elseif new.cooling_id not in (select id from products p where category_id = 7)
		then signal sqlstate '45001' set message_text = 'Choosed wrong cooling system';
	elseif new.case_id not in (select id from products p where category_id = 8)
		then signal sqlstate '45001' set message_text = 'Choosed wrong case';
	end if;
	
end//
delimiter ;

-- Проверка триггера (Все id соответствуют категориям, сборка добавляется без ошибки)
insert into assemblies 
	(user_id , videocard_id , proc_id , ozu_id , motherboard_id , ps_id, drive_id, cooling_id, case_id)
	values
	(1, 3, 12, 25, 33, 46, 55, 64, 69);
-- Теперь указываем в качестве видеокарты товар, относящийся к категории "корпуса" либо меняем местами любые другие товары. 
-- При введении неверного товара для каждой категории выводится отдельное сообщение
insert into assemblies 
	(user_id , videocard_id , proc_id , ozu_id , motherboard_id , ps_id, drive_id, cooling_id, case_id)
	values
	(1, 69, 12, 25, 33, 46, 55, 64, 69);


-- Представление всех утвержденных возвратов с подчетом сумм по каждому товару
create or replace view vw_refunds
as
	select r.id, r.order_id,r.product_id, r.product_count, r.product_count * p.price as total_refund from `returns` r 
		join orders o on r.order_id = o.id
		join products_ordered po on o.id = po.order_id
		join products p on r.product_id = p.id 
	where r.status = 'completed'
	group by r.id;

select * from vw_refunds;

-- Подсчет суммы всех возвратов, обращаясь к представлению vw_refunds
select SUM(total_refund) from vw_refunds;


-- Представление всех проданных товаров с подсчетом выручки
create or replace view vw_revenue
as
	select po.order_id, p.id, p.name, po.product_count, p.price, p.price * po.product_count as total_cost
		from products_ordered po 
			join products p on po.product_id  = p.id 
			join orders o on po.order_id = o.id
	where o.status = 'completed'
	order by total_cost;

select * from vw_revenue;

-- Подсчет общей выручки, обращаясь к представлению vw_revenue
select SUM(total_cost) from vw_revenue;


-- Представление таблицы пользовательских сборок с добавлением информации о товарах и итоговой стоимости сборки
create or replace view vw_assemlies
as
	select a.user_id, p.name as videaocard, p.price as video_price, 
					p2.name as processor, p2.price as proc_price,
					p3.name as ram, p3.price as ram_price,
					p4.name as motherboard, p4.price as mb_price,
					p5.name as power_suply, p5.price as ps_price,
					p6.name as drive, p6.price as drive_price,
					p7.name as colling_system, p7.price as cs_price,
					p8.name as `case`, p8.price as case_price,
					(p.price + p2.price + p3.price + p4.price + p5.price + p6.price + p7.price + p8.price) as total_price
	from assemblies a
		join products p on p.id = a.videocard_id
		join products p2 on p2.id = a.proc_id
		join products p3 on p3.id = a.ozu_id
		join products p4 on p4.id = a.motherboard_id
		join products p5 on p5.id = a.ps_id
		join products p6 on p6.id = a.drive_id 
		join products p7 on p7.id = a.cooling_id 
		join products p8 on p8.id = a.case_id
	order by total_price;

select * from vw_assemlies




		










