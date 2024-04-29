--Question Set 1 - Easy
--1. Who is the senior most employee based on job title?
select * from employee
order by "levels" desc
limit 1

--2. Which countries have the most Invoices?
select count("invoice_id"),"billing_country" from invoice
group by "billing_country"
order by count("invoice_id") desc

--3. What are top 3 values of total invoice?
select * from invoice
order by "total" desc
limit 3

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city 
-- we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals
select sum("total"),"billing_city" from invoice
group by "billing_city"
order by sum("total") desc
limit 1



-- 5. Who is the best customer? The customer who has spent the most money will be declared the best 
-- customer. Write a query that returns the person who has spent the most money
select customer."customer_id",customer."first_name",customer."last_name",sum(invoice.total) from customer
join invoice on invoice.customer_id=customer.customer_id
group by 1,2,3
order by 4 desc
limit 1

--Question Set 2 – Moderate


-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A 
select customer."email",customer."first_name",customer."last_name" from customer
join invoice on invoice.customer_id=customer.customer_id
join invoiceline on invoiceline.invoice_id=invoice.invoice_id
where track_id in (
select track_id from track
join genre on genre."genre_id"=track."genre_id"
where genre.name like 'Rock'
)
group by 1,2,3


-- 2. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select artist."artist_id",artist."name" as "artist_name",genre."name" as "Gnere_name",
count(genre.name) from track
join album on album."album_id"=track."album_id"
join artist on artist."artist_id"=album."artist_id"
join genre on genre."genre_id"=track."genre_id"
where genre.name like 'Rock'
group by 1,2,3
order by 4 desc
limit 10

-- 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs 
-- listed first
select "name","milliseconds" from track
where "milliseconds">(select avg("milliseconds") from track)
order by "milliseconds" desc



                     -- Question Set 3 – Advance
							 
-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, 
-- artist name and total spent
with best_selling as (
select artist."artist_id" as "artist_id",artist."name" as "artist_name",
sum(invoiceline."unit_price"*invoiceline."quantity")
from invoiceline
join track on track."track_id"=invoiceline."track_id"
join album on album."album_id"=track."album_id"
join artist on artist."artist_id"=album."artist_id"
group by 1,2
order by 3 desc
limit 1
)
select customer."customer_id",customer."first_name",customer."last_name",bs."artist_id",
bs."artist_name",sum(invoiceline."unit_price"*invoiceline."quantity") from customer
join invoice on invoice.customer_id=customer.customer_id
join invoiceline on invoiceline.invoice_id=invoice.invoice_id
join track on track."track_id"=invoiceline."track_id"
join album on album."album_id"=track."album_id"
join best_selling as bs on bs."artist_id"=album."artist_id"
group by 1,2,3,4,5
order by 6 desc


-- 2. We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres
with popular_genre as (select count(genre."name"),invoice."billing_country",genre."genre_id",genre."name",
row_number() over (partition by invoice."billing_country" order by count(genre."name")desc)
from invoice
join invoiceline on invoiceline.invoice_id=invoice.invoice_id
join track on track."track_id"=invoiceline."track_id"
join genre on genre."genre_id"=track."genre_id"
group by 2,3,4
order by 2 asc,1 desc)
select * from popular_genre where "row_number"=1

-- 3. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount
with customer_with_country as(select customer."customer_id",customer."first_name",
customer."last_name",customer."country",sum(invoice."total") as "Total_Amount_Spent",
row_number()over (partition by customer."country" order by sum(invoice."total")desc)from customer
join invoice on invoice."customer_id"=customer."customer_id"
group by 1,2,3,4
)
select * from customer_with_country where "row_number"=1
