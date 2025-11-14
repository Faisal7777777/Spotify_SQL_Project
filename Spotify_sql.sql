--Easy--

--1) Who is the senior most employee based on job titlr?

select * from employee
order by levels
Desc limit 1;

--2) Which countries have the most invoices?

Select count(*) as Most_invoices_country, billing_country
from invoice
group by billing_country
order by Most_invoices_country
desc limit 10;

--3) What are the top 3 values of total invoice?

select total 
from invoice
order by total
desc limit 3;


--Moderate--

--4) which city has the best cutomers?
-- We would like to throw a promotional music festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals.

select sum(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total
desc;

--5) who is the best customer?
-- The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has the spent the most money.


select customer.customer_id,customer.first_name,customer.last_name,Sum(invoice.total) as total
From customer
Join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total
desc limit 1;


---Medium---

--1) Write a query to return email,first name, last name & genre of all rock music listeners.
-- Return your list ordered alphabetically by email starting with A.

select Distinct email,first_name,last_name
from customer 
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
)
order by email;

--2) let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of thr top 10 rock bands.


select artist.artist_id,artist.name,count(artist.artist_id) as Number_of_songs
from track
Join Album on track.album_id = album.album_id
Join artist on album.artist_id = artist.artist_id
Join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by Number_of_songs
desc limit 10;


--3) Return all the track name that have a song lenght longer than the average song lenght.
-- Return the name and Milliseconds for each track.
-- Order by the song lenght with the longest song listed first.

select name,milliseconds
from track
where milliseconds > (
select avg(milliseconds) as Avg_track_lenght
from track
)
order by milliseconds
desc;


--Advance--

--1) Find how much amount spent by each customer on artists?
-- Write a query to return customer name,artist name and total spent.


With best_selling_artist as (
select artist.artist_id as artist_id,artist.name as artist_name,
Sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line
Join track on invoice_line.track_id = track.track_id
Join album on track.album_id = album.album_id
Join artist on album.artist_id = artist.artist_id
group by 1
order by 3
Desc limit 1
)

select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity) as Amount_spent
from invoice i
Join customer c on c.customer_id = i.customer_id
Join invoice_line il on i.invoice_id = il.invoice_id
Join track t on il.track_id = t.track_id
Join album alb on t.album_id = alb.album_id
Join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by  1,2,3,4
order by 5 desc ;


--2) We want to find out the most popular music genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genres.

with popular_genre as (
select count(inl.quantity) as purchases, c.country, g.name, g.genre_id,
row_number() over(partition by c.country order by count(inl.quantity)Desc) as Row_no
from invoice_line as inl
Join invoice as i on i.invoice_id = inl.invoice_id
Join customer as c on c.customer_id = i.customer_id
Join track as t on t.track_id = inl.track_id
Join genre as g on t.genre_id = g.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre 
where Row_No <=1

--3) Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

With customer_with_country as (
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(i.total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as Row_no
from invoice as i
join customer as c on c.customer_id = i.customer_id
group by 1,2,3,4
order by 4 asc , 5 desc)
select * from customer_with_country 
where Row_no <=1


