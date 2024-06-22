--- Q1: Who is the senior most employee based on job title?---

SELECT top 1*
FROM employee
ORDER BY levels DESC

---Q2: Which countries have the most Invoices?--
select  count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select top 1 billing_city,sum(total) as total_invoice
from invoice 
group by billing_city
order by total_invoice desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 cst.customer_id, cst.first_name,cst.last_name, sum(inv.total) as inv_total
from customer as cst
join invoice as inv
on  cst.customer_id= inv.customer_id
group by cst.customer_id,cst.first_name,cst.last_name
order by inv_total desc

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email,first_name,last_name
from customer
join invoice on customer.customer_id= invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id= track.track_id
join genre on track.genre_id= genre.genre_id
where genre.name like 'rock'
order by email

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 artist.name,artist.artist_id, COUNT(artist.artist_id) as total_songs
from track
join  album on track.album_id= album.album_id
join artist on album.artist_id= artist.artist_id
join genre on  genre.genre_id=track.genre_id
where genre.name like 'rock'
group by artist.artist_id, artist.name
order by total_songs desc

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select milliseconds ,name
from track
where milliseconds >(
select avg(milliseconds) as time
from track)
order by milliseconds desc


/*Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT c.customer_id, c.first_name, c.last_name, bsa.name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id,c.first_name, c.last_name, bsa.name
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		
		)
SELECT * FROM Customter_with_country WHERE RowNo <= 1




