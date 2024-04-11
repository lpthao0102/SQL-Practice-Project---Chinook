-----List all the artists with the word 'santana' in their name.
SELECT Name
FROM dbo.Artist
WHERE Name LIKE '%santana%'


-----Find the name and length (in seconds) of all tracks that have length between 40 and 60 seconds.
SELECT 
	Name, 
	Milliseconds/1000 as Seconds
FROM dbo.Track
WHERE Milliseconds/1000 BETWEEN 40 AND 60


-----Display the city with highest sum total invoice.
SELECT TOP 1 
	BillingCity, 
	SUM(Total) as GrandTotal
FROM dbo.Invoice
GROUP BY BillingCity
ORDER BY SUM(Total) DESC


-----Produce a table that lists each country and the number of customers in that country.
SELECT 
	Country, 
	COUNT(CustomerID) as NoofCustomers
FROM dbo.Customer
GROUP BY Country
ORDER BY COUNT(CustomerID) DESC


-----Identify the employees who on the sales team.
SELECT 
	CONCAT(FirstName, ' ', LastName) as Employee,
	Title
FROM dbo.Employee
WHERE Title LIKE '%sales%'


-----Find the top 5 customers whose total combined invoice amounts are the highest. Give their fullname, customerid and total invoice amount.
SELECT TOP 5
	C.CustomerId,
	CONCAT(C.FirstName, ' ', C.LastName) as FullName,
	SUM(Total) as TotalInvoice
FROM dbo.Customer as C
JOIN dbo.Invoice as I on C.CustomerId = I.CustomerId
GROUP BY C.CustomerId, CONCAT(FirstName, ' ', LastName)
ORDER BY SUM(Total) DESC


-----How many tracks per genre the music store has?
SELECT
	G.Name,
	COUNT(T.TrackId) as NoofTracks
FROM dbo.Genre as G
JOIN dbo.Track as T on G.GenreId = T.GenreId
GROUP BY G.Name
ORDER BY COUNT(T.TrackId) DESC


-----How many invoices were there in 2010 and 2012?
SELECT  
	BillingCountry,
	COUNT(InvoiceId) as TotalInvoice
FROM dbo.Invoice
WHERE YEAR(InvoiceDate) BETWEEN 2010 AND 2012
GROUP BY BillingCountry
ORDER BY COUNT(InvoiceId) DESC


-----Find out state wise count of customerid and list the names of states with count of customerid (not include where states is null value)
SELECT
	State,
	COUNT(CustomerId) as NoofCustomers
FROM dbo.Customer
WHERE State IS NOT NULL
GROUP BY State
ORDER BY COUNT(CustomerId) DESC


-----Identify all the albums that have more than 23 tracks under them.
SELECT
	AL.Title as AlbumName,
	COUNT(T.TrackId) as NoofTracks 
FROM dbo.Track as T
JOIN dbo.Album as AL on T.AlbumID = AL.AlbumID
GROUP BY AL.Title
HAVING COUNT(T.TrackId) > 23
ORDER BY COUNT(T.TrackId) DESC


-----Find the artist who has contributed the most albums.
SELECT TOP 1
	A.Name,
	COUNT(AL.AlbumId) as NoofAlbums
FROM dbo.Artist as A
JOIN dbo.Album as AL on A.ArtistId = AL.ArtistId
GROUP BY A.Name
ORDER BY COUNT(AL.AlbumId) DESC


-----Return the email, phone, fullname, and genre of all pop music listeners. Return your list ordered alphabetically by email address starting with 'a'.
SELECT 
	CONCAT(C.Firstname, ' ', C.LastName) as FullName,
	C.Email,
	C.Phone,
	G.Name
FROM dbo.Customer as C
JOIN dbo.Invoice as I on C.CustomerId = I.CustomerId
JOIN dbo.InvoiceLine as IL on I.InvoiceId = IL.InvoiceId
JOIN dbo.Track as T on IL.TrackId = T.TrackId
JOIN dbo.Genre as G on T.GenreId = G.GenreId
WHERE G.Name = 'Pop'
ORDER BY CONCAT(C.Firstname, ' ', C.LastName) ASC


-----Identify all the artists who have written the blues genre.
SELECT 
	A.Name,
	COUNT(T.TrackId) as NoofTracks
FROM dbo.Artist as A
JOIN dbo.Album as AL on A.ArtistId = AL.ArtistId
JOIN dbo.Track as T on AL.AlbumId = T.AlbumId
JOIN dbo.Genre as G on T.GenreId = G.GenreId
WHERE G.Name = 'Blues'
GROUP BY A.Name
ORDER BY COUNT(T.TrackId) DESC


-----Which artist has earned the most according to the invoicelines?
SELECT TOP 1
	A.Name,
	SUM(IL.UnitPrice * IL.Quantity) as TotalEarnings
FROM dbo.Artist as A
JOIN dbo.Album as AL on A.ArtistId = AL.ArtistId
JOIN dbo.Track as T on AL.AlbumId = T.AlbumId
JOIN dbo.InvoiceLine as IL on T.TrackId = IL.TrackId
GROUP BY A.Name
ORDER BY SUM(IL.UnitPrice * IL.Quantity) DESC


-----How monthly income varied in 2013 for the latin genre?
SELECT
	MONTH(I.InvoiceDate) as MONTH,
	G.Name,
	SUM(IL.UnitPrice * IL.Quantity) as Income
FROM dbo.Invoice as I
JOIN dbo.InvoiceLine as IL on I.InvoiceId = IL.InvoiceId
JOIN dbo.Track as T on IL.TrackId = T.TrackId
JOIN dbo.Genre as G on T.GenreId = G.GenreId
WHERE YEAR(I.InvoiceDate) = 2013 AND G.Name = 'Latin'
GROUP BY MONTH(I.InvoiceDate), G.Name
ORDER BY MONTH(I.InvoiceDate) ASC


-----Display the track, album for all tracks which are not purchased.
SELECT 
	T.Name as TrackName,
	AL.Title as AlbumName
FROM dbo.Track as T
JOIN dbo.Album as AL on T.AlbumId = AL.AlbumId
WHERE NOT EXISTS(	
	SELECT T.Name
	FROM dbo.InvoiceLine as IL 
	WHERE T.TrackId = IL.TrackId
)


--- Find the top 3 employees who have supported the most no of customers. Display their employeeid, last name, parent employee and designation. 
WITH 
	temp as (
	SELECT
		E.EmployeeID,
		E.LastName as Employee,
		PE.LastName as ParentEmployee,
		E.Title as TitleEmployee,
		COUNT(C.CustomerId) as NoofCustomers
	FROM dbo.Employee as E
	JOIN dbo.Employee as PE on E.ReportsTo = PE.EmployeeId
	JOIN dbo.Customer as C on E.EmployeeId = C.SupportRepId
	GROUP BY E.EmployeeID, E.LastName, PE.LastName, E.Title
	)
SELECT TOP 3 *
FROM temp
ORDER BY NoofCustomers DESC


-----Find artist who have performed in multiple genres. Display the artist name and the genre
WITH
	temp as (
	SELECT 
		DISTINCT A.Name as ArtistName,
		G.Name as GenreName
	FROM dbo.Artist as A
	JOIN dbo.Album as AL on A.ArtistId = AL.ArtistId
	JOIN dbo.Track as T on AL.AlbumId = T.AlbumId
	JOIN dbo.Genre as G on T.GenreId = G.GenreId
	),
	multigenre as
	(SELECT ArtistName
	FROM temp
	GROUP BY ArtistName
	HAVING COUNT(ArtistName) > 1
	)
SELECT t.ArtistName, t.GenreName
FROM temp as t
JOIN multigenre as mg on t.ArtistName = mg.ArtistName
