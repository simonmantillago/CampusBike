# CampusBike By Jorge and Simon

[![image](https://cdn.discordapp.com/attachments/1203034242418745344/1267262322917904427/591c034a-acb7-426b-a696-08a1554b67ec.png?ex=66a82582&is=66a6d402&hm=da98b369f2294aef6a5edc2fc053913f0701e15fbba50636a2a9137e3b5a12f9&)](https://private-user-images.githubusercontent.com/150193274/346207118-686e2118-f9d1-46e2-8b5b-d01548034294.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MjE3NTQzNjksIm5iZiI6MTcyMTc1NDA2OSwicGF0aCI6Ii8xNTAxOTMyNzQvMzQ2MjA3MTE4LTY4NmUyMTE4LWY5ZDEtNDZlMi04YjViLWQwMTU0ODAzNDI5NC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwNzIzJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDcyM1QxNzAxMDlaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1lZjUwYjI4ZmMzZjEwNGNiNzczMTM5OTUwOTE5ZTA4NGQ5MDRhOGZlOWE4ODM2MjA1M2U4NGIxNzhlMDgzYWZjJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZhY3Rvcl9pZD0wJmtleV9pZD0wJnJlcG9faWQ9MCJ9.REa0_Jv7ucUVk0TacjkMslNF8gpL1-h4GEZIcdMMhcg)



## Casos de Uso para la Base de Datos

### Caso de Uso 1: Gestion de Inventario de Bicicletas

**Descripción:** Este caso de uso describe cómo el sistema gestiona el inventario de bicicletas,
permitiendo agregar nuevas bicicletas, actualizar la información existente y eliminar bicicletas que
ya no están disponibles.

```mysql
DELIMITER //

CREATE PROCEDURE addBicycle(
    IN p_ModelID INT,
    IN p_Price DECIMAL(10, 2),
    IN p_Stock INT
)
BEGIN
    INSERT INTO Bicycle (ModelID, Price, Stock)
    VALUES (p_ModelID, p_Price, p_Stock);
END //

CREATE PROCEDURE updateBicycle(
    IN p_ID INT,
    IN p_Price DECIMAL(10, 2),
    IN p_Stock INT
)
BEGIN
    UPDATE Bicycle 
    SET Price = p_Price, stock = p_Stock
    WHERE id = p_ID;
END //

CREATE PROCEDURE deleteBicycle(
    IN p_ID INT
)
BEGIN
    
    DELETE FROM SaleDetail
    WHERE BicycleID = p_ID;
    
    DELETE FROM Bicycle
    WHERE ID = p_ID;
END //

DELIMITER ;

CALL addBicycle(1,1000.00,2);
+----+---------+---------+-------+
| ID | ModelID | Price   | Stock |
+----+---------+---------+-------+
|  1 |       1 |  500.00 |    10 |
|  2 |       2 |  750.00 |     5 |
|  3 |       3 | 1000.00 |     3 |
|  4 |       1 | 1000.00 |     2 |
+----+---------+---------+-------+

CALL updateBicycle(4,1200.00,10);
+----+---------+---------+-------+
| ID | ModelID | Price   | Stock |
+----+---------+---------+-------+
|  1 |       1 |  500.00 |    10 |
|  2 |       2 |  750.00 |     5 |
|  3 |       3 | 1000.00 |     3 |
|  4 |       1 | 1200.00 |    10 |
+----+---------+---------+-------+

CALL deleteBicycle(4);
+----+---------+---------+-------+
| ID | ModelID | Price   | Stock |
+----+---------+---------+-------+
|  1 |       1 |  500.00 |    10 |
|  2 |       2 |  750.00 |     5 |
|  3 |       3 | 1000.00 |     3 |
+----+---------+---------+-------+
```



### Caso de Uso 2:  Registro de Ventas

Este caso de uso describe el proceso de registro de una venta de bicicletas, incluyendo la creación de una nueva venta, la selección de las bicicletas vendidas y el cálculo del total de la venta.

 ```sql
DELIMITER $$

DROP PROCEDURE IF EXISTS sale_register;
CREATE PROCEDURE sale_register( IN CustomerID Varchar(20))
BEGIN
    INSERT INTO sale (Date,CustomerID,Total) VALUES (CURDATE(),CustomerID,0);
    SELECT s.ID AS Sale_ID, s.Date, c.Name AS Customer
    FROM sale s
    JOIN customer c ON c.ID = s.CustomerID
    WHERE s.ID = LAST_INSERT_ID();
END $$

/*------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS choose_bike;
CREATE PROCEDURE choose_bike(
    IN SaleID int,
    IN BicycleID int,
    IN Quantity int,
    IN price DECIMAL(10,2)
)
BEGIN
	DECLARE totalsale DECIMAL(10, 2);
    DECLARE totalBike DECIMAL(10, 2);
  
    SELECT Total INTO totalsale
    FROM sale
    WHERE ID=SaleID;
    
    INSERT INTO saledetail (SaleID,BicycleID,Quantity,UnitPrice) VALUES (SaleID,BicycleID,Quantity,price);
    SET totalBike = totalsale + (Quantity*price);
    
    UPDATE sale
    SET Total = totalBike
    WHERE ID = SaleID;
    
    SELECT s.ID AS Sale_ID, s.Date, c.Name AS Customer, Total
    FROM sale s
    JOIN customer c ON c.ID = s.CustomerID
    WHERE s.ID = SaleID;
    
    SELECT 'Do you want to continue with the purchase?' AS Confirmation;
END $$

/*--------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS confirmation_sale;
CREATE PROCEDURE confirmation_sale(
    IN answer CHAR(1),
    IN saleselected INT
)
BEGIN
    IF answer = 'Y' THEN
        UPDATE bicycle b
        INNER JOIN (
            SELECT sd.BicycleID, SUM(sd.Quantity) AS cantidad_vendida
            FROM saledetail sd
            WHERE sd.SaleID = saleselected
            GROUP BY sd.BicycleID
        ) sb ON b.ID = sb.BicycleID
        SET b.Stock = b.Stock - sb.cantidad_vendida;
        SELECT 'Purchase completed' AS Advice;
    END IF;
    
    IF answer = 'N' THEN
        DELETE FROM saledetail WHERE SaleID = saleselected;
        DELETE FROM sale WHERE ID = saleselected;
        SELECT 'Purchase canceled' AS Advice;
    END IF;
END$$
DELIMITER ;

---------------------------------------------------------------------------------------------------------
CALL sale_register('C001');
CALL choose_bike (3,2,2,2000);
CALL choose_bike (3,3,2,2000);
CALL confirmation_sale('Y',3);
+---------+------------+------------+
| Sale_ID | Date       | Customer   |
+---------+------------+------------+
|       3 | 2024-07-24 | Jane Smith |
+---------+------------+------------+

+---------+------------+------------+---------+
| Sale_ID | Date       | Customer   | Total   |
+---------+------------+------------+---------+
|       3 | 2024-07-24 | Jane Smith | 8000.00 |
+---------+------------+------------+---------+

+--------------------------------------------+
| Confirmation                               |
+--------------------------------------------+
| Do you want to continue with the purchase? |
+--------------------------------------------+

+--------------------+
| Advice             |
+--------------------+
| Purchase completed |
+--------------------+

 ```

### 

### Caso de Uso 3: Gestión de Proveedores y Repuestos

**Descripción:** Este caso de uso describe cómo el sistema gestiona la información de proveedores y
repuestos, permitiendo agregar nuevos proveedores y repuestos, actualizar la información
existente y eliminar proveedores y repuestos que ya no están activos.

```mysql
DELIMITER //

CREATE PROCEDURE AddSupplier(
    IN ID INT,
    IN SupplierName VARCHAR(100),
    IN Contact VARCHAR(100),
    IN Phone VARCHAR(20),
    IN Email VARCHAR(100),
    IN CityID INT
)
BEGIN
    INSERT INTO Supplier (ID, SupplierName, Contact, Phone, Email, CityID)
    VALUES (ID, SupplierName, Contact, Phone, Email, CityID);
END //


CREATE PROCEDURE AddPart(
    IN PartName VARCHAR(100),
    IN Description TEXT,
    IN Price DECIMAL(10, 2),
    IN Stock INT,
    IN SupplierID INT
)
BEGIN
    INSERT INTO Part (PartName, Description, Price, Stock, SupplierID)
    VALUES (PartName, Description, Price, Stock, SupplierID);
END //
DROP PROCEDURE IF EXISTS UpdateSupplier;
CREATE PROCEDURE UpdateSupplier(
    IN update_ID INT,
    IN update_SupplierName VARCHAR(100),
    IN update_Contact VARCHAR(100),
    IN update_Phone VARCHAR(20),
    IN update_Email VARCHAR(100),
    IN update_CityID INT
)
BEGIN
    UPDATE Supplier
    SET SupplierName = update_SupplierName,
        Contact = update_Contact,
        Phone = update_Phone,
        Email = update_Email,
        CityID = update_CityID
    WHERE ID = update_ID;
END //

DROP PROCEDURE IF EXISTS UpdatePart ;
CREATE PROCEDURE UpdatePart(
    IN update_ID INT,
    IN update_PartName VARCHAR(100),
    IN update_Description TEXT,
    IN update_Price DECIMAL(10, 2),
    IN update_Stock INT,
    IN update_SupplierID INT
)
BEGIN
    UPDATE Part
    SET PartName = update_PartName,
        Description = update_Description,
        Price = update_Price,
        Stock = update_Stock,
        SupplierID = update_SupplierID
    WHERE ID = update_ID;
END //


CREATE PROCEDURE DeleteSupplier(
    IN deleted_ID INT
)
BEGIN
    
	DELETE FROM Supplier WHERE ID = deleted_ID;
END //


CREATE PROCEDURE DeletePart(
    IN deleted_ID INT
)
BEGIN
    DELETE FROM Part WHERE ID = deleted_ID;
END //

DELIMITER ;


CALL AddSupplier(1, 'Bmx distribution ', 'Juan Roberto', '123-456-7890', 'juan@supplier.com', 1);	
+-------+-------------------+--------------+--------------+-----------------------+--------+
| ID    | SupplierName      | Contact      | Phone        | Email                 | CityID |
+-------+-------------------+--------------+--------------+-----------------------+--------+
|     1 | Bmx distribution  | Juan Roberto | 123-456-7890 | juan@supplier.com     |      1 |
| 10001 | Supplier1         | Contact1     | 1122334455   | supplier1@example.com |      1 |
| 10002 | Supplier2         | Contact2     | 2233445566   | supplier2@example.com |      3 |
+-------+-------------------+--------------+--------------+-----------------------+--------+

CALL AddPart('Chain', 'High quality bike chain', 30.00, 50, 1);
+----+----------+-------------------------+--------+-------+------------+
| ID | PartName | Description             | Price  | Stock | SupplierID |
+----+----------+-------------------------+--------+-------+------------+
|  1 | Brake    | High quality brake      |  50.00 |    20 |      10001 |
|  2 | Wheel    | Durable wheel           | 100.00 |    15 |      10002 |
|  5 | Chain    | High quality bike chain |  30.00 |    50 |      10001 |
+----+----------+-------------------------+--------+-------+------------+

CALL UpdateSupplier(1, 'MountainBiking Js', 'Robert Green', '1122334466', 'supplierMountain@example.com',1);
+-------+-------------------+----------------+-------------+------------------------------+--------+
| ID    | SupplierName      | Contact        | Phone       | Email                        | CityID |
+-------+-------------------+----------------+-------------+------------------------------+--------+
|     1 | MountainBiking Js | Robert Green   | 12342334466 | supplierMountain@example.com |      2 |
| 10001 | Bikecycles online | Charles Manson | 2345678987  | supplierVikes@example.com    |      1 |
| 10002 | Bici Parts        | Rick owens     | 2345678987  | supplierParts@example.com    |      1 |
+-------+-------------------+----------------+-------------+------------------------------+--------+	

CALL UpdatePart(1, 'Brake System', 'High quality brake system', 60.00, 25, 10001);
+----+--------------+---------------------------+--------+-------+------------+
| ID | PartName     | Description               | Price  | Stock | SupplierID |
+----+--------------+---------------------------+--------+-------+------------+
|  1 | Wheel        | Dirt Wheels               |  20.00 |    10 |          1 |
|  2 | Chain        | Chain for Bikes           | 160.00 |    34 |          1 |
|  5 | Brake System | High quality brake system |  60.00 |    25 |      10001 |
+----+--------------+---------------------------+--------+-------+------------+

CALL AddSupplier(10004, 'Roads distribution ', 'Esteban Duenas', '123-456-7890', 'esteban@supplier.com', 2);
CALL DeleteSupplier(10004);
+-------+-------------------+----------------+-------------+------------------------------+--------+
| ID    | SupplierName      | Contact        | Phone       | Email                        | CityID |
+-------+-------------------+----------------+-------------+------------------------------+--------+
|     1 | MountainBiking Js | Robert Green   | 12342334466 | supplierMountain@example.com |      2 |
| 10001 | Bikecycles online | Charles Manson | 2345678987  | supplierVikes@example.com    |      1 |
| 10002 | Bici Parts        | Rick owens     | 2345678987  | supplierParts@example.com    |      1 |
+-------+-------------------+----------------+-------------+------------------------------+--------+

CALL DeletePart(2);
+----+----------+-----------------+--------+-------+------------+
| ID | PartName | Description     | Price  | Stock | SupplierID |
+----+----------+-----------------+--------+-------+------------+
|  1 | Wheel    | Dirt Wheels     |  20.00 |    10 |          1 |
|  2 | Chain    | Chain for Bikes | 160.00 |    34 |          1 |
+----+----------+-----------------+--------+-------+------------+
```



### Caso de Uso 4:  Consulta de Historial de Ventas por Cliente

Este caso de uso describe cómo el sistema permite a un usuario consultar el historial de ventas de un cliente específico,  mostrando todas las compras realizadas por el cliente y los detalles de cada venta.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS sale_history_customer;
CREATE PROCEDURE sale_history_customer(IN CustomerID VARCHAR(20))
BEGIN
    SELECT s.ID AS Sale_ID, s.Date, s.Total, c.Name
    FROM sale s
    JOIN customer c ON c.ID = s.CustomerID
    WHERE s.CustomerID = CustomerID;
END $$

DROP PROCEDURE IF EXISTS details_history_customer;
CREATE PROCEDURE details_history_customer(IN SaleID int)
BEGIN
    SELECT m.ModelName AS Bicycle , br.BrandName as Brand, s.Quantity, s.UnitPrice, (s.UnitPrice*s.Quantity) AS Total
    FROM saledetail s
    JOIN bicycle b ON b.ID = s.BicycleID
    JOIN model m ON m.ID = b.ModelID
    JOIN brand br ON br.ID = m.BrandID
    WHERE s.SaleID = SaleID;
    
END $$


DELIMITER ;

CALL sale_history_customer('C001');
CALL details_history_customer(2);

+---------+------------+-------+-------------+
| Sale_ID | Date       | Total | Name        |
+---------+------------+-------+-------------+
|       7 | 2024-07-28 |  0.00 | Alice Smith |
+---------+------------+-------+-------------+

+-------------+-------+----------+-----------+---------+
| Bicycle     | Brand | Quantity | UnitPrice | Total   |
+-------------+-------+----------+-----------+---------+
| Domane SL 6 | Trek  |        1 |   3500.00 | 3500.00 |
+-------------+-------+----------+-----------+---------+
```



### Caso de Uso 5: Gestión de Compras de Repuestos

**Descripción:** Este caso de uso describe cómo el sistema gestiona las compras de repuestos a
proveedores, permitiendo registrar una nueva compra, especificar los repuestos comprados y
actualizar el stock de repuestos.

```mysql
DELIMITER //

CREATE PROCEDURE RegisterPurchase(
    IN p_Date DATE,
    IN p_SupplierID INT,
    IN p_Total DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Purchase (Date, SupplierID, Total)
    VALUES (p_Date, p_SupplierID, p_Total);
    
END //

CREATE PROCEDURE UpdatePurchaseDetails(
    IN p_PurchaseID INT,
    IN p_PartID INT,
    IN p_Quantity INT,
    IN p_UnitPrice DECIMAL(10, 2)
)
BEGIN
    
    INSERT INTO PurchaseDetail (PurchaseID, PartID, Quantity, UnitPrice)
    VALUES (p_PurchaseID, p_PartID, p_Quantity, p_UnitPrice);
    
    UPDATE Part
    SET Stock = Stock + p_Quantity
    WHERE ID = p_PartID;
    

    SELECT 
        p.PartName,
        pd.Quantity AS QuantityPurchased,
        p.Stock AS NewStock,
        'Repuesto añadido y stock actualizado' AS Message
    FROM Part p
    JOIN PurchaseDetail pd ON p.ID = pd.PartID
    WHERE p.ID = p_PartID AND pd.PurchaseID = p_PurchaseID;
END //

DELIMITER ;

CALL RegisterPurchase('2024-07-26', 101, 1000.00);
+----+------------+------------+---------+
| ID | Date       | SupplierID | Total   |
+----+------------+------------+---------+
|  1 | 2024-07-01 |      10001 | 1000.00 |
|  2 | 2024-07-02 |      10002 | 1500.00 |
|  3 | 2024-07-26 |      101   | 1000.00 |
+----+------------+------------+---------+

CALL UpdatePurchaseDetails(3,1,50,20.00);
+----------+-------------------+----------+--------------------------------------+
| PartName | QuantityPurchased | NewStock | Message                              |
+----------+-------------------+----------+--------------------------------------+
| Wheel    |                50 |       60 | Repuesto añadido y stock actualizado |
+----------+-------------------+----------+--------------------------------------+
```



## Casos de Uso con Subconsultas

### Caso de Uso 6:  Consulta de Bicicletas Más Vendidas por Marca

Este caso de uso describe cómo el sistema permite a un usuario consultar las bicicletas más vendidas por cada marca.

```mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS most_famous_bicycle_by_brand;
CREATE PROCEDURE most_famous_bicycle_by_brand()
BEGIN
    SELECT b.BrandName, m.ModelName, SUM(s.Quantity) AS Quantity
    FROM brand b
    JOIN model m ON m.BrandID = b.ID
    JOIN bicycle bi ON bi.ModelID = m.ID
    JOIN saledetail s ON s.BicycleID = bi.ID
    GROUP BY b.BrandName, m.ModelName
    HAVING SUM(s.Quantity) = (
        SELECT MAX(total_quantity)
        FROM (
            SELECT b.BrandName, m.ModelName, SUM(s.Quantity) AS total_quantity
            FROM brand b
            JOIN model m ON m.BrandID = b.ID
            JOIN bicycle bi ON bi.ModelID = m.ID
            JOIN saledetail s ON s.BicycleID = bi.ID
            GROUP BY b.BrandName, m.ModelName
        ) AS maxb
        WHERE maxb.BrandName = b.BrandName
);
    
END $$
DELIMITER ;
CALL most_famous_bicycle_by_brand();

+-----------+-----------------+----------+
| BrandName | ModelName       | Quantity |
+-----------+-----------------+----------+
| BrandA    | Mountain Bike 1 |        1 |
| BrandB    | Mountain Bike 2 |       26 |
| BrandC    | Mountain Bike 3 |       20 |
+-----------+-----------------+----------+
```

### 

### Caso de Uso 7: Clientes con Mayor Gasto en un Año Específico

**Descripción:** Este caso de uso describe cómo el sistema permite consultar los clientes que han
gastado más en un año específico.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS GetTopSpendingCustomers;
CREATE PROCEDURE GetTopSpendingCustomers(
    IN p_Year INT   
)
BEGIN
    SELECT 
        c.ID AS CustomerID,
        c.Name AS CustomerName,
        COALESCE((SELECT SUM(Total)
         FROM Sale s
         WHERE s.CustomerID = c.ID AND YEAR(s.Date) = p_Year), 0) AS TotalSpent
    FROM Customer c
    ORDER BY TotalSpent DESC;
END //

DELIMITER ;

CALL GetTopSpendingCustomers(2024);
+------------+--------------+------------+
| CustomerID | CustomerName | TotalSpent |
+------------+--------------+------------+
| 1098387298 | John Doe     |    3000.00 |
| 1767365849 | Jane Smith   |    1500.00 |
| 1200890832 | Carlos Perez |       0.00 |
+------------+--------------+------------+

```



### Caso de Uso 8:  Proveedores con Más Compras en el Último Mes

Este caso de uso describe cómo el sistema permite consultar los proveedores que
han recibido más compras en el último mes.

```mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS suplier_with_most_purchases;
CREATE PROCEDURE suplier_with_most_purchases()
BEGIN
    SELECT s.ID, s.SupplierName,
        (   SELECT COUNT(p.ID)
            FROM purchase p
            WHERE p.SupplierID = s.ID && p.Date >= (DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        ) AS Purchases
    FROM supplier s
    ORDER BY Purchases DESC;
END $$
DELIMITER ;
CALL suplier_with_most_purchases();

+-------+--------------+-----------+
| ID    | SupplierName | Purchases |
+-------+--------------+-----------+
| 10001 | Supplier1    |         2 |
| 10002 | Supplier2    |         1 |
| 10003 | Supplier3    |         0 |
| 10004 | Supplier4    |         0 |
+-------+--------------+-----------+
```



### Caso de Uso 9: Repuestos con Menor Rotación en el Inventario

**Descripción:** Este caso de uso describe cómo el sistema permite consultar los repuestos que han
tenido menor rotación en el inventario, es decir, los menos vendidos.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS ListPartPurchases;
CREATE PROCEDURE ListPartPurchases()
BEGIN
    SELECT ID, Name, TotalPurchase
    FROM (
        SELECT 
        	p.id as id, p.PartName as name, 
        	SUM(pd.Quantity) as TotalPurchase
        FROM 
        	part p
        JOIN 
        	PurchaseDetail pd ON p.id = pd.PartID	
        GROUP BY p.id, p.PartName
    ) as PartSales
    ORDER BY TotalPurchase ASC;
END //

DELIMITER ;

CALL ListPartPurchases(); 

+----+-------+---------------+
| ID | Name  | TotalPurchase |
+----+-------+---------------+
|  2 | Chain |            15 |
|  1 | Wheel |            60 |
+----+-------+---------------+
```



### Caso de Uso 10:  Ciudades con Más Ventas Realizadas

Este caso de uso describe cómo el sistema permite consultar las ciudades donde se
han realizado más ventas de bicicletas.

```mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS cities_with_more_purchases;
CREATE PROCEDURE cities_with_more_purchases()
BEGIN
    SELECT c.CityName, co.CountryName, COUNT(p.ID) AS Purchases
    FROM city c
    JOIN country co ON co.ID = c.CountryID
    JOIN supplier s ON s.CityID = c.ID
    JOIN purchase p ON p.SupplierID = s.ID
    GROUP BY c.CityName, co.CountryName
    HAVING COUNT(p.ID) = (
        SELECT MAX(Purchases)
        FROM (
            SELECT c.CityName, co.CountryName, COUNT(p.ID) AS Purchases
    		FROM city c
    		JOIN country co ON co.ID = c.CountryID
    		JOIN supplier s ON s.CityID = c.ID
    		JOIN purchase p ON p.SupplierID = s.ID
    		GROUP BY c.CityName, co.CountryName
        ) AS maxP
        WHERE maxp.CityName = c.CityName && maxp.CountryName=co.CountryName
	)
	ORDER BY Purchases DESC;
END $$
DELIMITER ;
CALL cities_with_more_purchases();

+----------+-------------+-----------+
| CityName | CountryName | Purchases |
+----------+-------------+-----------+
| Bogotá   | Colombia    |         2 |
| New York | USA         |         1 |
+----------+-------------+-----------+
```



## Casos de Uso con Joins

### Caso de Uso 11: Consulta de Ventas por Ciudad

**Descripción:** Este caso de uso describe cómo el sistema permite consultar el total de ventas
realizadas en cada ciudad.

```mysql
DELIMITER //
DROP PROCEDURE IF EXISTS ListTotalSalesPerCity;
CREATE PROCEDURE ListTotalSalesPerCity()
BEGIN 
	SELECT 
		ci.CityName, COUNT(s.ID) AS TotalSales, 
		COALESCE(SUM(s.Total), 0) AS TotalAmount
	FROM 
		city ci
	JOIN 
		customer cu ON ci.ID = cu.CityID
	JOIN 
		sale s ON cu.ID =  s.CustomerID
	GROUP BY 
		ci.CityName
	ORDER BY TotalAmount DESC;
	
END //

DELIMITER ;
CALL ListTotalSalesPerCity();
```



### Caso de Uso 12:  Consulta de Proveedores por País

Este caso de uso describe cómo el sistema permite consultar los proveedores
agrupados por país.

```mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS suplier_per_countries;
CREATE PROCEDURE suplier_per_countries()
BEGIN
SELECT s.ID, s.SupplierName, ct.CityName,c.CountryName
FROM country c
JOIN city ct ON ct.CountryID = c.ID
JOIN supplier s ON s.CityID = ct.ID
ORDER BY c.CountryName, ct.CityName;	
END $$

/*ESCCOGI DOS FORMAS PARA HACERLO, UNA CON TODOS LOS PAISES Y OTRO EN DONDE ME MUESTRA LAS CIUDADES DEPENDIENDO DEL PAIS*/

DROP PROCEDURE IF EXISTS suplier_per_country;
CREATE PROCEDURE suplier_per_country( IN country Varchar(20))
BEGIN
SELECT s.ID, s.SupplierName, ct.CityName
FROM country c
JOIN city ct ON ct.CountryID = c.ID
JOIN supplier s ON s.CityID = ct.ID
WHERE c.CountryName = country
ORDER BY ct.CityName;
END $$

DELIMITER ;

CALL suplier_per_countries();
CALL suplier_per_country('Colombia');

+-------+--------------+----------+-------------+
| ID    | SupplierName | CityName | CountryName |
+-------+--------------+----------+-------------+
| 10001 | Supplier1    | Bogotá   | Colombia    |
| 10003 | Supplier3    | Bogotá   | Colombia    |
| 10002 | Supplier2    | New York | USA         |
| 10004 | Supplier4    | New York | USA         |
+-------+--------------+----------+-------------+

+-------+--------------+----------+
| ID    | SupplierName | CityName |
+-------+--------------+----------+
| 10001 | Supplier1    | Bogotá   |
| 10003 | Supplier3    | Bogotá   |
+-------+--------------+----------+
```



### Caso de Uso 13: Compras de Repuestos por Proveedor

**Descripción:** Este caso de uso describe cómo el sistema permite consultar el total de repuestos
comprados a cada proveedor.

```mysql
DELIMITER //
DROP PROCEDURE IF EXISTS PartPurchasePerSupplier;
CREATE PROCEDURE PartPurchasePerSupplier()
BEGIN 
	SELECT su.SupplierName, COUNT(su.ID) AS TotalPurchases, COALESCE(SUM(p.Total), 0) AS TotalAmount
	FROM supplier su
	JOIN purchase p ON p.SupplierID = su.ID
	GROUP BY su.SupplierName 
	ORDER BY TotalPurchases DESC;
	
END //

DELIMITER ;

CALL PartPurchasePerSupplier();
+-----------------------+----------------+-------------+
| SupplierName          | TotalPurchases | TotalAmount |
+-----------------------+----------------+-------------+
| Bike Parts Co.        |              2 |     3500.00 |
| Cycling Supplies Ltd. |              1 |     3000.00 |
| Pedal Power Inc.      |              1 |     3500.00 |
| Wheel World           |              1 |     2000.00 |
+-----------------------+----------------+-------------+
```



### Caso de Uso 14:  Clientes con Ventas en un Rango de Fechas

Este caso de uso describe cómo el sistema permite consultar los clientes que han realizado compras dentro de un rango de fechas específico.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS sales_per_date;
CREATE PROCEDURE sales_per_date( 
	IN startDate DATE,
    IN endDate DATE
)
BEGIN
    SELECT c.ID AS 'Customer ID', c.Name, s.ID AS 'sale ID'
    FROM sale s
    JOIN Customer c ON c.ID = s.CustomerID
    WHERE s.Date BETWEEN startDate AND endDate;
    
END $$

DELIMITER ;

CALL sales_per_date('2020-01-01', '2024-07-05');
+-------------+----------------+---------+
| Customer ID | Name           | sale ID |
+-------------+----------------+---------+
| C002        | Bob Johnson    |       2 |
| C003        | Carlos Mendoza |       3 |
| C004        | Diana Costa    |       4 |
+-------------+----------------+---------+
```



## Casos de Uso para Implementar Procedimientos Almacenados 

### Caso de Uso 1: Actualización de Inventario de Bicicletas

Este caso de uso describe cómo el sistema actualiza el inventario de bicicletas
cuando se realiza una venta.

```mysql
DELIMITER $$
DROP PROCEDURE IF EXISTS bike_stock_update;
CREATE PROCEDURE bike_stock_update(
    IN saleselected INT
)
BEGIN
        UPDATE bicycle b
        INNER JOIN (
            SELECT sd.BicycleID, SUM(sd.Quantity) AS cantidad_vendida,'Purchase completed' AS Mensaje
            FROM saledetail sd
            WHERE sd.SaleID = saleselected
            GROUP BY sd.BicycleID
        ) sb ON b.ID = sb.BicycleID
        SET b.Stock = b.Stock - sb.cantidad_vendida;
        
        SELECT "Bike Stock Update" AS Mensaje;
 END $$

DELIMITER ;
CALL bike_stock_update(3);

+-------------------+
| Mensaje           |
+-------------------+
| Bike Stock Update |
+-------------------+
        
```



### Caso de Uso 2: Registro de Nueva Venta

Este caso de uso describe cómo el sistema registra una nueva venta, incluyendo la
creación de la venta y la inserción de los detalles de la venta.



```mysql
/*Teniendo en cuenta el Caso de Uso 2: Registro de Ventas haremos call de el proceso sale_register para crear una nueva sale, sin embargo en este caso no se necesita confirmacion del cliente y se modifica */

DELIMITER $$

DROP PROCEDURE IF EXISTS choose_bike_and_buy;
CREATE PROCEDURE choose_bike_and_buy(
    IN SaleID int,
    IN BicycleID int,
    IN Quantity int,
    IN price DECIMAL(10,2)
)
BEGIN
	DECLARE totalsale DECIMAL(10, 2);
    DECLARE totalBike DECIMAL(10, 2);
  
    SELECT Total INTO totalsale
    FROM sale
    WHERE ID=SaleID;
    
    INSERT INTO saledetail (SaleID,BicycleID,Quantity,UnitPrice) VALUES (SaleID,BicycleID,Quantity,price);
    SET totalBike = totalsale + (Quantity*price);
    
    UPDATE sale
    SET Total = totalBike
    WHERE ID = SaleID;
    
    SELECT s.ID AS Sale_ID, s.Date, c.Name AS Customer, Total
    FROM sale s
    JOIN customer c ON c.ID = s.CustomerID
    WHERE s.ID = SaleID;
    
   UPDATE bicycle b
        INNER JOIN (
            SELECT sd.BicycleID, SUM(sd.Quantity) AS cantidad_vendida
            FROM saledetail sd
            WHERE sd.SaleID = SaleID
            GROUP BY sd.BicycleID
        ) sb ON b.ID = sb.BicycleID
        SET b.Stock = b.Stock - sb.cantidad_vendida;
        SELECT 'Purchase completed' AS Advice;
END $$

DELIMITER ;

CALL sale_register ('C001');
CALL choose_bike_and_buy (7,5,35,2000);

+---------+------------+------------+
| Sale_ID | Date       | Customer   |
+---------+------------+------------+
|       7 | 2024-07-25 | Jane Smith |
+---------+------------+------------+

+---------+------------+------------+----------+
| Sale_ID | Date       | Customer   | Total    |
+---------+------------+------------+----------+
|       7 | 2024-07-25 | Jane Smith | 70000.00 |
+---------+------------+------------+----------+

+--------------------+
| Advice             |
+--------------------+
| Purchase completed |
+--------------------+
```

### Caso de Uso 3: Generación de Reporte de Ventas por Cliente

Este caso de uso describe cómo el sistema genera un reporte de ventas para un cliente específico, mostrando todas las ventas realizadas por el cliente y los detalles de cada venta.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS sale_history_customer_details;
CREATE PROCEDURE sale_history_customer_details(IN CustomerID VARCHAR(20))
BEGIN
   SELECT
    s.ID AS "Sale ID", s.Total,
    GROUP_CONCAT(CONCAT('(',m.ModelName,'/',br.BrandName , '/', sd.Quantity, '/', sd.UnitPrice, ')') SEPARATOR ' - ') AS 'Details: (Bicycle/Brand/Quantity/UnitPrice)'
	FROM sale s
	JOIN saledetail sd ON s.ID = sd.SaleID
	JOIN customer c ON s.CustomerID = c.ID
	JOIN bicycle b ON sd.BicycleID = b.ID
	JOIN model m ON b.ModelID = m.ID
	JOIN brand br ON m.BrandID = br.ID 
	WHERE s.CustomerID = CustomerID
	GROUP BY s.ID;
END $$

DELIMITER ;

CALL sale_history_customer_details('C001');
+---------+----------+---------------------------------------------+
| Sale ID | Total    | Details: (Bicycle/Brand/Quantity/UnitPrice) |
+---------+----------+---------------------------------------------+
|       7 | 70000.00 | (Anthem Advanced Pro/Giant/35/2000.00)      |
+---------+----------+---------------------------------------------+
```

### 

### Caso de Uso 4: Registro de Compra de Repuestos

**Descripción:** Este caso de uso describe cómo el sistema registra una nueva compra de repuestos
a un proveedor.

```mysql
DELIMITER //

CREATE PROCEDURE RegisterPurchase(
    IN p_Date DATE,
    IN p_SupplierID INT,
    IN p_Total DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Purchase (Date, SupplierID, Total)
    VALUES (p_Date, p_SupplierID, p_Total);
    
END //

CREATE PROCEDURE UpdatePurchaseDetails(
    IN p_PurchaseID INT,
    IN p_PartID INT,
    IN p_Quantity INT,
    IN p_UnitPrice DECIMAL(10, 2)
)
BEGIN
    
    INSERT INTO PurchaseDetail (PurchaseID, PartID, Quantity, UnitPrice)
    VALUES (p_PurchaseID, p_PartID, p_Quantity, p_UnitPrice);
    
    UPDATE Part
    SET Stock = Stock + p_Quantity
    WHERE ID = p_PartID;
    

    SELECT 
        p.PartName,
        pd.Quantity AS QuantityPurchased,
        p.Stock AS NewStock,
        'Repuesto añadido y stock actualizado' AS Message
    FROM Part p
    JOIN PurchaseDetail pd ON p.ID = pd.PartID
    WHERE p.ID = p_PartID AND pd.PurchaseID = p_PurchaseID;
END //

DELIMITER ;

CALL RegisterPurchase('2024-07-26', 1, 1000.00);
+----+------------+------------+---------+
| ID | Date       | SupplierID | Total   |
+----+------------+------------+---------+
|  1 | 2024-07-01 |      10001 | 1000.00 |
|  2 | 2024-07-02 |      10002 | 1500.00 |
|  3 | 2024-07-26 |      1     | 1000.00 |
+----+------------+------------+---------+

CALL UpdatePurchaseDetails(3,1,50,20.00);
+----------+-------------------+----------+--------------------------------------+
| PartName | QuantityPurchased | NewStock | Message                              |
+----------+-------------------+----------+--------------------------------------+
| Wheel    |                50 |       60 | Repuesto añadido y stock actualizado |
+----------+-------------------+----------+--------------------------------------+
```



### Caso de Uso 5: Generación de Reporte de Inventario

**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de inventario de
bicicletas y repuestos.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS InventoryReport;

CREATE PROCEDURE InventoryReport()
BEGIN
    SELECT 
        'Bicycle' AS ItemType,  
        b.ID AS ItemID,         
        m.ModelName AS ItemName, 
        b.Price AS ItemPrice,   
        b.Stock AS ItemStock    
    FROM 
        Bicycle b
    JOIN 
        Model m ON b.ModelID = m.ID
    UNION ALL
    SELECT 
        'Part' AS ItemType,     
        p.ID AS ItemID,         
        p.PartName AS ItemName,  
        p.Price AS ItemPrice,   
        p.Stock AS ItemStock    
    FROM 
        Part p;
END //

DELIMITER ;

CALL InventoryReport();
+----------+--------+-----------------+-----------+-----------+
| ItemType | ItemID | ItemName        | ItemPrice | ItemStock |
+----------+--------+-----------------+-----------+-----------+
| Bicycle  |      1 | Mountain Bike 1 |    500.00 |        10 |
| Bicycle  |      2 | Road Bike 2     |    750.00 |         5 |
| Bicycle  |      3 | Electric Bike 3 |   1000.00 |         3 |
| Part     |      1 | Wheel           |     20.00 |        60 |
| Part     |      2 | Chain           |    160.00 |        34 |
+----------+--------+-----------------+-----------+-----------+
```



### Caso de Uso 6: Actualización Masiva de Precios

Este caso de uso describe cómo el sistema permite actualizar masivamente los
precios de todas las bicicletas de una marca específica.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS update_price_brand;
CREATE PROCEDURE update_price_brand(
	IN brandselected varchar(20),
    IN newPricePercent decimal (10,2)
)
BEGIN
     UPDATE bicycle b
     JOIN model m ON m.ID = b.ModelID
     JOIN brand br ON br.ID = m.BrandID
     SET b.Price = b.Price+b.Price*newPricePercent
     WHERE br.BrandName = brandselected;

END $$

DELIMITER ;

CALL update_price_brand('BrandA', 0.50);

/*PRECIOS ANTES*/
+-----------------+-----------+---------+
| ModelName       | BrandName | Price   |
+-----------------+-----------+---------+
| Mountain Bike 1 | BrandA    |  750.00 |
| Road Bike 1     | BrandA    | 1500.00 |
+-----------------+-----------+---------+

/*PRECIOS DESPUES*/
+-----------------+-----------+---------+
| ModelName       | BrandName | Price   |
+-----------------+-----------+---------+
| Mountain Bike 1 | BrandA    | 1125.00 |
| Road Bike 1     | BrandA    | 2250.00 |
+-----------------+-----------+---------+
```

### 

### Caso de Uso 7: Generación de Reporte de Clientes por Ciudad

**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de clientes agrupados
por ciudad.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CustomersPerCity;

CREATE PROCEDURE CustomersPerCity()
BEGIN 
	SELECT ci.CityName AS City, cu.ID, cu.Name, cu.Email, cu.Phone
	
	FROM city ci
	JOIN customer cu ON cu.CityID = ci.ID;
	
END //

DELIMITER ;

CALL CustomersPerCity();
+----------+------------+--------------+--------------------+-----------+
| City     | ID         | Name         | Email              | Phone     |
+----------+------------+--------------+--------------------+-----------+
| Bogotá   | 1098387298 | John Doe     | john@example.com   | 123456789 |
| Bogotá   | 110293023  | Simon Dios   | simon@example.com  | 123456789 |
| Medellín | 1767365849 | Jane Smith   | jane@example.com   | 987654321 |
| New York | 1200890832 | Carlos Perez | carlos@example.com | 456789123 |
+----------+------------+--------------+--------------------+-----------+
```



### Caso de Uso 8: Verificación de Stock antes de Venta

Este caso de uso describe cómo el sistema verifica el stock de una bicicleta antes de
permitir la venta.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS verify_Stock $$
CREATE PROCEDURE verify_Stock( 
    IN bicycleID INT,
    IN quantity INT
)
BEGIN
    DECLARE actualStock INT;
    SELECT b.Stock INTO actualStock
    FROM bicycle b
    JOIN model m ON m.ID = b.ModelID
    JOIN brand br ON br.ID = m.BrandID
    WHERE b.ID = bicycleID;
    IF actualStock > quantity THEN 
        SELECT m.modelName, br.BrandName,'Disponible para la venta' AS Mensaje
         FROM bicycle b
    	JOIN model m ON m.ID = b.ModelID
    	JOIN brand br ON br.ID = m.BrandID
   	 	WHERE b.ID = bicycleID;
    ELSE 
        SELECT m.modelName, br.BrandName,'NO hay stock suficiente' AS Mensaje
         FROM bicycle b
    	JOIN model m ON m.ID = b.ModelID
    	JOIN brand br ON br.ID = m.BrandID
   	 	WHERE b.ID = bicycleID;
    END IF; 
END $$

DELIMITER ;
CALL verify_Stock(3, 100);
```

### 

### Caso de Uso 9: Registro de Devoluciones

**Descripción:** Este caso de uso describe cómo el sistema registra la devolución de una bicicleta por
un cliente.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS ApplyReturn //

CREATE PROCEDURE ApplyReturn(
    IN saleId INT
)
BEGIN
    DECLARE returnedQuantity INT;
    DECLARE returnedBicycleID INT;

    SELECT
        sd.BicycleID,
        sd.Quantity
    INTO
        returnedBicycleID,
        returnedQuantity
    FROM
        saleDetail sd
    WHERE sd.SaleID = saleId;


    UPDATE sale s
        SET s.Total = 0
    WHERE s.ID = saleId;


    UPDATE Bicycle b
        SET b.Stock = b.Stock + returnedQuantity
    WHERE b.ID = returnedBicycleID;

    SELECT CONCAT('The bicycles with the ID: ', returnedBicycleID, ' ,have been returned') AS Message, returnedQuantity AS StockReturned;
END //

DELIMITER ;

CALL ApplyReturn(2);
+-------------------------------------------------+---------------+
| Message                                         | StockReturned |
+-------------------------------------------------+---------------+
| The bicycles with the ID: 2 ,have been returned |             1 |
+-------------------------------------------------+---------------+
```



### Caso de Uso 10: Generación de Reporte de Compras por Proveedor

Este caso de uso describe cómo el sistema genera un reporte de compras realizadas
a un proveedor específico, mostrando todos los detalles de las compras.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS generate_supplier_report $$
CREATE PROCEDURE generate_supplier_report(IN supplierID INT)
BEGIN
    SELECT 
        p.ID AS PurchaseID,
        p.Date AS PurchaseDate,
        p.Total AS PurchaseTotal,
        pd.ID AS PurchaseDetailID,
        pa.PartName AS PartName,
        pd.Quantity AS Quantity,
        pd.UnitPrice AS UnitPrice
    FROM 
        Purchase p
    JOIN 
        PurchaseDetail pd ON p.ID = pd.PurchaseID
    JOIN 
        Part pa ON pd.PartID = pa.ID
    WHERE 
        p.SupplierID = supplierID
    ORDER BY 
        p.Date;
END $$

DELIMITER ;

CALL generate_supplier_report(101);
+------------+--------------+---------------+------------------+--------------+----------+-----------+
| PurchaseID | PurchaseDate | PurchaseTotal | PurchaseDetailID | PartName     | Quantity | UnitPrice |
+------------+--------------+---------------+------------------+--------------+----------+-----------+
|          1 | 2023-02-15   |       2500.00 |                1 | Brake System |      100 |     25.00 |
+------------+--------------+---------------+------------------+--------------+----------+-----------+
```



### Caso de Uso 11: Calculadora de Descuentos en Ventas

**Descripción:** Este caso de uso describe cómo el sistema aplica un descuento a una venta antes de registrar los detalles de la venta.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS ApplyDiscountToSale;

CREATE PROCEDURE ApplyDiscountToSale(
    IN saleId INT,
    IN discount DECIMAL(5, 2) 
)
BEGIN
    DECLARE originalTotal DECIMAL(10, 2);
    DECLARE discountedTotal DECIMAL(10, 2);


    SELECT 
    	Total INTO originalTotal
    FROM 
    	Sale
    WHERE ID = saleId;


    SET discountedTotal = originalTotal - (originalTotal * (discount / 100));


    UPDATE 
    	Sale
    SET 
    	Total = discountedTotal
    WHERE ID = saleId;
    
    SELECT CONCAT('The discount of 0', discount, '% has been applied to the sale ', saleId, '. Total amount: ', discountedTotal) AS Message;
    
END //

DELIMITER ;

CALL ApplyDiscountToSale(3,10);
+-------------------------------------------------------------------------------+
| Message                                                                       |
+-------------------------------------------------------------------------------+
| The discount of 10.00% has been applied to the sale 3. Total amount: 1800.00 |
+-------------------------------------------------------------------------------+

```



## Casos de Uso para Funciones de Resumen

### Caso de Uso 1: Calcular el Total de Ventas Mensuales

**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas en un
mes específico.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CalculateMonthlySales;

CREATE PROCEDURE CalculateMonthlySales(
    IN month INT,  
    IN year INT    
)
BEGIN
    DECLARE totalSales DECIMAL(10, 2);

    SELECT 
    	COALESCE(SUM(Total), 0) INTO totalSales
    FROM 
    	Sale
    WHERE 
    	MONTH(Date) = month AND YEAR(Date) = year;
    	
    SELECT CONCAT(month,'/',year) AS Date, totalSales AS MonthlyTotal;
    
END //

DELIMITER ;

CALL CalculateMonthlySales(7,2024);
+--------+--------------+
| Date   | MonthlyTotal |
+--------+--------------+
| 7/2024 |      3800.00 |
+--------+--------------+
```



### Caso de Uso 2: Calcular el Promedio de Ventas por Cliente

Este caso de uso describe cómo el sistema calcula el promedio de ventas realizadas
por un cliente específico.



```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS sales_average_customer ;
CREATE PROCEDURE sales_average_customer(
	IN Customer varchar(20)
)
BEGIN
	SELECT AVG(Total) AS "Sale Average"
	FROM sale
	WHERE CustomerID = Customer;
	
END $$

DELIMITER ;

CALL sales_average_customer(1767365849);
+--------------+
| Sale Average |
+--------------+
| 56300.000000 |
+--------------+
```

### 

### Caso de Uso 3: Contar el Número de Ventas Realizadas en un Rango de Fechas

**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de ventas realizadas
dentro de un rango de fechas específico.	

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS sales_between_date;

CREATE PROCEDURE sales_between_date( 
    IN startDate DATE,
    IN endDate DATE
)
BEGIN
    SELECT 
    	CONCAT(startDate,' / ',endDate) AS Dates,
    	COUNT(s.ID) AS 'Number of sales'
    FROM 
    	sale s
    WHERE 
    	s.Date BETWEEN startDate AND endDate;

END //

DELIMITER ;

CALL sales_between_date('2024-01-01', '2024-07-05');
+-------------------------+-----------------+
| Dates                   | Number of sales |
+-------------------------+-----------------+
| 2024-01-01 / 2024-07-05 |               3 |
+-------------------------+-----------------+
```

### Caso de Uso 4: Calcular el Total de Repuestos Comprados por Proveedor

Este caso de uso describe cómo el sistema calcula el total de repuestos comprados a
un proveedor específico.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS count_parts_per_supplier;
CREATE PROCEDURE count_parts_per_supplier( 
    IN supplierID int
)
BEGIN
SELECT COUNT(pd.Quantity) AS "Parts Quantity"
FROM purchasedetail pd
JOIN purchase p ON p.ID = pd.PurchaseID
WHERE p.SupplierID = supplierID;
END $$

DELIMITER ;

CALL count_parts_per_supplier(101);
+----------------+
| Parts Quantity |
+----------------+
|              2 |
+----------------+
```

### 

### Caso de Uso 5: Calcular el Ingreso Total por Año

**Descripción:** Este caso de uso describe cómo el sistema calcula el ingreso total generado en un
año específico.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS TotalIncomePerYear;

CREATE PROCEDURE TotalIncomePerYear(
    IN p_Year INT   
)
BEGIN

    SELECT 
    	p_Year AS Year,
        SUM(s.Total) AS TotalIncome
    FROM 
    	sale s
    WHERE YEAR(s.DATE) = p_Year;

END //

DELIMITER ;

CALL TotalIncomePerYear(2024);
+------+-------------+
| Year | TotalIncome |
+------+-------------+
| 2024 |     3300.00 |
+------+-------------+
```



### Caso de Uso 6: Calcular el Número de Clientes Activos en un Mes

Este caso de uso describe cómo el sistema cuenta el número de clientes que han
realizado al menos una compra en un mes específico.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS active_Customers  ;
CREATE PROCEDURE active_Customers (
	IN month int,
    IN year int
)
BEGIN
SELECT COUNT(DISTINCT CustomerID) AS "Active Customers"
FROM sale
WHERE MONTH(Date) = month && YEAR(Date) = year;
END $$

DELIMITER ;

CALL active_Customers (7,2024);
+------------------+
| Active Customers |
+------------------+
|                2 |
+------------------+
```

### 

### Caso de Uso 7: Calcular el Promedio de Compras por Proveedor

**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de compras
realizadas a un proveedor específico.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CalculateAveragePurchaseBySupplier;

CREATE PROCEDURE CalculateAveragePurchaseBySupplier(
    IN p_supplierId INT
)
BEGIN
    
    
    SELECT 
    	p.SupplierID AS Supplier, 
    	AVG(p.Total) AS avgPurchase
    FROM 
    	Purchase p
    WHERE p.SupplierID = p_supplierId
    GROUP BY p.SupplierID;
    
END //

DELIMITER ;

CALL CalculateAveragePurchaseBySupplier(101);
+----------+-------------+
| Supplier | avgPurchase |
+----------+-------------+
|      101 | 1750.000000 |
+----------+-------------+
```



### Caso de Uso 8: Calcular el Total de Ventas por Marca

Este caso de uso describe cómo el sistema calcula el total de ventas agrupadas por
la marca de las bicicletas vendidas.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS sale_per_brand;
CREATE PROCEDURE sale_per_brand(
)
BEGIN
    SELECT  br.BrandName, SUM(sd.Quantity*sd.UnitPrice) AS Total
    FROM brand br
    JOIN model m ON m.BrandID = br.ID
    JOIN bicycle b ON b.ModelID = m.ID
    JOIN saledetail sd ON sd.BicycleID = b.ID
    JOIN sale s ON sd.SaleID = s.ID
    WHERE s.Total > 0
    GROUP BY br.BrandName;
END $$

DELIMITER ;

CALL sale_per_brand();
+-----------+-----------+
| BrandName | Total     |
+-----------+-----------+
| BrandA    | 110500.00 |
| BrandB    |  57500.00 |
| BrandC    | 114000.00 |
+-----------+-----------+
```

### 

### Caso de Uso 9: Calcular el Promedio de Precios de Bicicletas por Marca	

**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de precios de las
bicicletas agrupadas por marca.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CalculateAveragePriceByBrand //

CREATE PROCEDURE CalculateAveragePriceByBrand()
BEGIN
    SELECT 
        b.BrandName AS Brand, 
        AVG(bc.Price) AS AvgPrice
    FROM 
        Bicycle bc
    JOIN 
        Model m ON bc.ModelID = m.ID
    JOIN 
        Brand b ON m.BrandID = b.ID
    GROUP BY 
        b.BrandName;
END //

DELIMITER ;

CALL CalculateAveragePriceByBrand();
+--------+-------------+
| Brand  | AvgPrice    |
+--------+-------------+
| BrandA |  500.000000 |
| BrandB |  750.000000 |
| BrandC | 1000.000000 |
+--------+-------------+
```



### Caso de Uso 10: Contar el Número de Repuestos por Proveedor

Este caso de uso describe cómo el sistema cuenta el número de repuestos
suministrados por cada proveedor.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS parts_per_supplier;
CREATE PROCEDURE parts_per_supplier( )
BEGIN
    SELECT p.SupplierID, s.SupplierName, COUNT(p.ID) AS "Parts"
    FROM part p 
    JOIN supplier s ON s.ID = p.SupplierID
    GROUP BY SupplierID;
END $$

DELIMITER ;
CALL parts_per_supplier();

+------------+--------------+-------+
| SupplierID | SupplierName | Parts |
+------------+--------------+-------+
|      10001 | Supplier1    |     2 |
|      10002 | Supplier2    |     1 |
+------------+--------------+-------+
```

### 

### Caso de Uso 11: Calcular el Total de Ingresos por Cliente

**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ingresos generados por
cada cliente.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CalculateTotalIncomeByCustomer //

CREATE PROCEDURE CalculateTotalIncomeByCustomer()
BEGIN
    SELECT 
        c.ID AS CustomerID,
        c.Name AS CustomerName,
        SUM(s.Total) AS TotalIncome
    FROM 
        Customer c
    JOIN 
        Sale s ON c.ID = s.CustomerID
    GROUP BY 
        c.ID;
END //

DELIMITER ;

CALL CalculateTotalIncomeByCustomer();
+------------+--------------+-------------+
| CustomerID | CustomerName | TotalIncome |
+------------+--------------+-------------+
| 1098387298 | John Doe     |     1800.00 |
| 1767365849 | Jane Smith   |     1500.00 |
+------------+--------------+-------------+
```



### Caso de Uso 12: Calcular el Promedio de Compras Mensuales

Este caso de uso describe cómo el sistema calcula el promedio de compras
realizadas mensualmente por todos los clientes.

```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS monthly_average;
CREATE PROCEDURE monthly_average( 
	IN month int
)
BEGIN
	SELECT month AS Month, AVG(Total) AS "sales Average"
    FROM sale
    WHERE MONTH(Date)=month;
END $$

DELIMITER ;

CALL monthly_average(7);
+-------+---------------+
| Month | sales Average |
+-------+---------------+
|     7 |  47000.000000 |
+-------+---------------+
```

### 

### Caso de Uso 13: Calcular el Total de Ventas por Día de la Semana

**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas en
cada día de la semana.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CalculateSalesByDay;

CREATE PROCEDURE CalculateSalesByDay(
    IN requiredDate DATE
)
BEGIN
    SELECT 
        s.Date AS Date,
        SUM(s.Total) AS TotalSales
    FROM 
        sale s
    WHERE 
        s.Date = requiredDate
    GROUP BY 
        s.Date;
END //

DELIMITER ;

 CALL CalculateSalesByDay('2024-07-28');
+------------+------------+
| Date       | TotalSales |
+------------+------------+
| 2024-07-28 |   70000.00 |
+------------+------------+
```



### Caso de Uso 14: Contar el Número de Ventas por Categoría de Bicicleta

Este caso de uso describe cómo el sistema cuenta el número de ventas realizadas
para cada categoría de bicicleta (por ejemplo, montaña, carretera, híbrida).



```mysql
DELIMITER $$

DROP PROCEDURE IF EXISTS sales_per_category ;
CREATE PROCEDURE sales_per_category( )
BEGIN
    SELECT  c.CategoryName AS Category, COUNT(s.ID) AS Total
    FROM category c
    JOIN model m ON m.categoryID = c.ID
    JOIN bicycle b ON b.ModelID = m.ID
    JOIN saledetail sd ON sd.BicycleID = b.ID
    JOIN sale s ON sd.SaleID = s.ID
    WHERE s.Total > 0
    GROUP BY c.CategoryName;
END $$

DELIMITER ;

CALL sales_per_category( );
+----------+-------+
| Category | Total |
+----------+-------+
| mountain |     1 |
| race     |     1 |
+----------+-------+
```



### Caso de Uso 15: Calcular el Total de Ventas por Año y Mes

**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas cada mes, agrupadas por año.

```mysql
DELIMITER //

DROP PROCEDURE IF EXISTS CalculateTotalSalesByYearAndMonth //

CREATE PROCEDURE CalculateTotalSalesByYearAndMonth()
BEGIN
    SELECT 
        YEAR(s.Date) AS Year,
        MONTH(s.Date) AS Month,
        SUM(s.Total) AS TotalSales
    FROM 
        Sale s
    GROUP BY 
        YEAR(s.Date), 
        MONTH(s.Date);
END //

DELIMITER ;

CALL CalculateTotalSalesByYearAndMonth();
+------+-------+------------+
| Year | Month | TotalSales |
+------+-------+------------+
| 2022 |     6 |       0.00 |
| 2021 |     9 |    6300.00 |
| 2020 |    12 |    3000.00 |
| 2024 |     7 |   70000.00 |
+------+-------+------------+
```

