select * from album
select * from artist
select * from customer
select * from employee
select * from genre
select * from invoice
select * from invoice_line
select * from media_type
select * from playlist
select * from playlist_track
select * from track

--Q.1 Who is the senior most employee based on job title
select title,first_name,last_name 
from employee 
order by levels desc limit 1

--Q.2 which countries has the most invoices
select count(*) as m,billing_country
from invoice 
group by billing_country 
order by m desc

--Q.3 what are top 3 value of total invoices
select * from invoice 
order by total desc limit 3

/* Q.4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals  */

select billing_city City,sum(total) Total 
from invoice
group by City 
order by Total Desc limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select C.customer_id,first_name,last_name,sum(total) Total_spent 
from customer C 
join invoice I on C.customer_id=I.customer_id
group by c.customer_id order by Total_spent desc limit 1

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct email,first_name,last_name,genre.name
from customer 
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id,artist.name,count(artist.artist_id) as Number_of_songs
from track 
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.album_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by Number_of_songs desc limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds from track
where milliseconds > 
(select avg(milliseconds) as Avg_track_length from track)
order by milliseconds desc

--Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */
with best_selling_artist as(
    select artist.artist_id artist_ids,artist.name artist_name,sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
    from invoice_line
    join track on track.track_id=invoice_line.track_id
    join album on album.album_id=track.album_id
    join artist on artist.artist_id=album.artist_id
    group by 1
    order by 3 desc
    limit 1 
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album a on a.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_ids=a.artist_id
group by 1,2,3,4
order by 5 desc

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */
with custoner_with_country as (
    select customer.customer_id,first_name,last_name,billing_country,sum(total) total_spending,
    Row_Number() over(partition by billing_country order by sum(total) desc  ) as rowno
    from invoice
    join customer on customer.customer_id=invoice.customer_id
    group by 1,2,3,4
    order by 4 ASC ,5 desc
)
select * from custoner_with_country where rowno <= 1
