CREATE DATABASE [Bank]
Go

USE [Bank]

CREATE TABLE [banks]
(
	[b_id] INT PRIMARY KEY IDENTITY(1,1),
	[b_name] NVARCHAR(150) NOT NULL
)
GO

CREATE TABLE [cities]
(
	[c_id] INT PRIMARY KEY IDENTITY(1,1),
	[c_name] NVARCHAR(150) NOT NULL
)
GO

CREATE TABLE [branches]
(
	[br_id] INT PRIMARY KEY IDENTITY(1,1),
	[br_name] NVARCHAR(150) NOT NULL,
	[br_bank] INT NOT NULL,
	[br_city] INT NOT NULL,
	FOREIGN KEY ([br_bank])  REFERENCES [banks] ([b_id]),
	FOREIGN KEY ([br_city])  REFERENCES [cities] ([c_id])
)
GO

CREATE TABLE [social_statuses]
(
	[s_id] INT PRIMARY KEY IDENTITY(1,1),
	[s_name] NVARCHAR(150) NOT NULL
)
GO

CREATE TABLE [clients]
(
	[cl_id] INT PRIMARY KEY IDENTITY(1,1),
	[cl_name] NVARCHAR(150) NOT NULL,
	[cl_status] INT NOT NULL,
	FOREIGN KEY ([cl_status])  REFERENCES [social_statuses] ([s_id])
)
GO

CREATE TABLE [accounts]
(
	[a_id] INT PRIMARY KEY IDENTITY(1,1),
	[a_balance] MONEY NOT NULL,
	[a_client] INT UNIQUE NOT NULL,
	[a_bank] INT NOT NULL,
	FOREIGN KEY ([a_bank]) REFERENCES [banks] ([b_id]),
	FOREIGN KEY ([a_client]) REFERENCES [clients] ([cl_id]) 
)
GO

CREATE TABLE [credit_cards]
(
	[cr_id] INT PRIMARY KEY IDENTITY(1,1),
	[cr_balance] MONEY NOT NULL,
	[cr_account] INT NOT NULL,
	FOREIGN KEY ([cr_account]) REFERENCES [accounts] ([a_id])
)
GO

SET IDENTITY_INSERT [banks] ON;
INSERT INTO [banks] ([b_id], [b_name])
VALUES
(1, N'ПриорБанк'),
(2, N'БелИнвестБанк'),
(3, N'БеларсБанк'),
(4, N'АльфаБанк'),
(5, N'ТехноБанк'),
(6, N'ВтбБанк');
SET IDENTITY_INSERT [banks] OFF;

SET IDENTITY_INSERT [cities] ON;
INSERT INTO [cities] ([c_id], [c_name])
VALUES
(1, N'Минск'),
(2, N'Москва'),
(3, N'Гомель'),
(4, N'Гродно'),
(5, N'Могилев'),
(6, N'Брест');
SET IDENTITY_INSERT [cities] OFF;

SET IDENTITY_INSERT [branches] ON;
INSERT INTO [branches] ([br_id], [br_name], [br_bank], [br_city])
VALUES
(1, N'ПриорБанк_23', 1, 1),
(2, N'БелИнвестБанк_12', 2, 3),
(3, N'БеларусБанк_18', 3, 4),
(4, N'АльфаБанк_13', 4, 2),
(5, N'ТехноБанк_21', 5, 6),
(6, N'ПриорБанк_25', 1, 2);
SET IDENTITY_INSERT [branches] OFF;

SET IDENTITY_INSERT [social_statuses] ON;
INSERT INTO [social_statuses] ([s_id], [s_name])
VALUES
(1, N'пенсионер'),
(2, N'инвалид'),
(3, N'ветеран'),
(4, N'многодетный'),
(5, N'без льгот')
SET IDENTITY_INSERT [social_statuses] OFF;

SET IDENTITY_INSERT [clients] ON;
INSERT INTO [clients] ([cl_id], [cl_name], [cl_status])
VALUES
(1, N'Иван', 1),
(2, N'Василий', 2),
(3, N'Николай', 3),
(4, N'Карина', 4),
(5, N'Карла', 5),
(6, N'Василиса', 5)
SET IDENTITY_INSERT [clients] OFF;

SET IDENTITY_INSERT [accounts] ON;
INSERT INTO [accounts] ([a_id], [a_balance], [a_bank], [a_client])
VALUES
(1, 0, 1, 1),
(2, 10, 2, 2),
(3, 1320, 3, 3),
(4, 190, 4, 5),
(5, 0, 5, 4),
(6, 20000, 1, 6)
SET IDENTITY_INSERT [accounts] OFF;

SET IDENTITY_INSERT [credit_cards] ON;
INSERT INTO [credit_cards] ([cr_id], [cr_balance], [cr_account])
VALUES
(1, 0, 1),
(2, 10, 2),
(3, 1320, 3),
(4, 190, 5),
(5, 0, 5),
(6, 20000, 4)
SET IDENTITY_INSERT [credit_cards] OFF;

/*1. Покажи мне список банков у которых есть филиалы в городе X (выбери один из городов*/
SELECT [b_name]
FROM [banks]
	JOIN [branches] ON [b_id] = [br_bank]
		JOIN [cities] ON [br_city] = [c_id]
WHERE [c_name] = N'Москва'

/*2. Получить список карточек с указанием имени владельца, баланса и названия банка*/
SELECT [cr_id], [cr_balance], [cl_name], [b_name]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
		JOIN [clients] ON [a_client] = [cl_id]
			JOIN [banks] ON [a_bank] = [b_id]

/*3. Показать список банковских аккаунтов у которых баланс не совпадает с суммой баланса по карточкам.
В отдельной колонке вывести разницу*/
WITH [cards_balance] AS
(
SELECT [a_id], [a_balance], SUM([cr_balance]) AS [card_sum_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
GROUP BY [a_id], [a_balance]
)
SELECT [a_id], [a_balance], [card_sum_balance], ABS([a_balance] - [card_sum_balance]) AS [balance_difference]
FROM [cards_balance]
WHERE [a_balance] != [card_sum_balance]

/*4. Вывести кол-во банковских карточек для каждого соц статуса (2 реализации, GROUP BY и подзапросом)*/
SELECT [s_name], COUNT([cr_id]) AS [cards_number]
FROM [accounts]
	JOIN [credit_cards] ON [a_id] = [cr_account]
		JOIN [clients] ON [a_client] = [cl_id]
			JOIN [social_statuses] ON [cl_status] = [s_id]
GROUP BY [s_name]


SELECT [s_id], [s_name], (SELECT COUNT([cr_id])
				FROM [credit_cards]
					JOIN [accounts] ON [cr_account] = [a_id]
						JOIN [clients] ON [a_client] = [cl_id]
				WHERE [cl_status] = [s_id]) AS [cards_number]
FROM [social_statuses]

GO

/*6. Получить список доступных средств для каждого клиента. То есть если у клиента на банковском аккаунте 60 рублей,
и у него 2 карточки по 15 рублей на каждой, то у него доступно 30 рублей для перевода на любую из карт*/
WITH [cards_balance] AS
(
SELECT [a_id], [a_client], [a_balance], SUM([cr_balance]) AS [card_sum_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
GROUP BY [a_id], [a_balance], [a_client]
)
SELECT [cl_id], [a_balance], [card_sum_balance], [a_balance] - [card_sum_balance] AS [available_money]
FROM [cards_balance]
	JOIN [clients] ON [a_client] = [cl_id]
GO

/*5. Написать stored procedure которая будет добавлять по 10$ на каждый банковский аккаунт для определенного соц статуса 
(У каждого клиента бывают разные соц. статусы. Например, пенсионер, инвалид и прочее). 
Входной параметр процедуры - Id социального статуса. Обработать исключительные ситуации
(например, был введен неверные номер соц. статуса. Либо когда у этого статуса нет привязанных аккаунтов).
*/
CREATE VIEW [account_status] AS
SELECT [a_id], [s_id], [a_balance]
FROM [accounts]
	JOIN [clients] ON [a_client] = [cl_id]
		JOIN [social_statuses] ON [cl_status] = [s_id]
GO

CREATE PROCEDURE [add_sum_by_status]
	@id INT
AS
BEGIN
	IF EXISTS (SELECT [s_id] 
			   FROM [social_statuses]
			   WHERE [s_id] = @id)
		IF EXISTS (SELECT [a_id] 
				   FROM [account_status]
			       WHERE [s_id] = @id)
		BEGIN
		  UPDATE [accounts]
		  SET [a_balance] = [a_balance] + 10
		  WHERE [a_id] IN (SELECT [a_id]
						   FROM [account_status]
						   WHERE [s_id] = @id)
		END
END

GO 

SELECT [a_id], [a_balance], [s_id]
FROM [account_status]
WHERE [s_id] = 5

GO 

--DISABLE TRIGGER [account_update] ON [accounts];

EXEC [add_sum_by_status] 5

SELECT [a_id], [a_balance], [s_id]
FROM [account_status]
WHERE [s_id] = 5

GO

/*7. Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта. 
При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится. 
Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой.
Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей,
а на картах будут суммы 300 и 500 рублей соответственно. После этого я уже не смогу перевести 400 рублей с аккаунта ни на одну из карт,
так как останется всего 200 свободных рублей (1000-300-500). Переводить БЕЗОПАСНО. То есть использовать транзакцию
*/
CREATE VIEW [available_money] AS
WITH [cards_balance] AS
(
SELECT [a_id], [a_balance], SUM([cr_balance]) AS [card_sum_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
GROUP BY [a_id], [a_balance]
)
SELECT [a_id], [a_balance], [card_sum_balance], [a_balance] - [card_sum_balance] AS [balance_difference]
FROM [cards_balance]
WHERE [a_balance] != [card_sum_balance]

GO
CREATE PROCEDURE [TransferMoneyFromAccToCard]
	@sum MONEY,
	@acc_id INT,
	@card_id INT
AS
BEGIN TRY
	BEGIN TRANSACTION
	IF EXISTS (SELECT [a_id]
			   FROM [accounts]
			   WHERE [a_id] = @acc_id)
		IF EXISTS (SELECT [cr_id]
				   FROM [credit_cards]
				   WHERE [cr_id] = @card_id)
			IF @card_id IN (SELECT [cr_id]
							FROM [credit_cards]
								JOIN [accounts] ON [cr_account] = [a_id]
							WHERE [a_id] = @acc_id)
				IF @sum < (SELECT [balance_difference]
						   FROM [available_money]
						   WHERE [a_id] = @acc_id)
				BEGIN
					UPDATE [credit_cards]
					SET [cr_balance] = [cr_balance] + @sum
					WHERE [cr_id] = @card_id
					COMMIT
				END
				ELSE 
				BEGIN;
					THROW 50005, N'Not enough money on account balance', 1
				END
			ElSE
			BEGIN;
				THROW 50006, N'This card is not belongs to this account', 1
			END
		ELSE
		BEGIN;
			THROW 50007, N'Wrong card ID', 1
		END
	ElSE
	BEGIN;
		THROW 50008, N'Wrong account ID', 1
	END
END TRY
BEGIN CATCH
	ROLLBACK;
	THROW
END CATCH

GO

SELECT [a_id], [a_balance], [cr_id], [cr_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
WHERE [a_id] = 2 and [cr_id] = 2

EXEC TransferMoneyFromAccToCard 2, 2, 2


SELECT [a_id], [a_balance], [cr_id], [cr_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
WHERE [a_id] = 2 and [cr_id] = 2

GO

/*8. Написать триггер на таблицы Account/Cards чтобы нельзя была занести значения в поле баланс
если это противоречит условиям  (то есть нельзя изменить значение в Account на меньшее, чем сумма балансов по всем карточкам.
И соответственно нельзя изменить баланс карты если в итоге сумма на картах будет больше чем баланс аккаунта)
*/
CREATE TRIGGER [account_update]
ON [accounts]
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT [card_sum_balance]
		FROM [available_money]
			JOIN [inserted] ON [available_money].[a_id] = [inserted].[a_id]
		WHERE [card_sum_balance] > [inserted].[a_balance])
		
	BEGIN
		ROLLBACK;
		THROW 51000, N'This sum is too small', 1
	END;
END;


--check data
SELECT [a_id], [a_client], [a_balance], SUM([cr_balance]) AS [card_sum_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
GROUP BY [a_id], [a_balance], [a_client];


--ENABLE TRIGGER [account_update] ON [accounts]

BEGIN TRY
BEGIN TRANSACTION
	UPDATE [accounts]
	SET [a_balance] = 50
	WHERE [a_id] = 2
COMMIT
END TRY
BEGIN CATCH;
	THROW
END CATCH

GO

CREATE TRIGGER [card_balance_update]
ON [credit_cards]
FOR UPDATE
AS
BEGIN
	IF EXISTS (SELECT [a_balance], [card_sum_balance]
			   FROM [available_money]
			      JOIN [inserted] ON [available_money].[a_id] = [inserted].[cr_account]
			   WHERE [a_balance] < [card_sum_balance])
	BEGIN
		ROLLBACK;
		THROW 51000, N'This sum is more than account balance', 1
	END;
END;

--check data
SELECT [a_id], [a_client], [a_balance], SUM([cr_balance]) AS [card_sum_balance]
FROM [credit_cards]
	JOIN [accounts] ON [cr_account] = [a_id]
GROUP BY [a_id], [a_balance], [a_client];

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE [credit_cards]
		SET [cr_balance] = 40
		WHERE [cr_id] = 2
	COMMIT
END TRY
BEGIN CATCH;
	THROW
END CATCH