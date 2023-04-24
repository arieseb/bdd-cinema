-- Connexion au serveur MySQL
mysql -u root

-- Visualisation de la liste des bases de données
SHOW databases;

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS movie_booking;

-- Création d'un administateur
CREATE USER IF NOT EXISTS admin IDENTIFIED BY PASSWORD '*96D1ABB192F9BE6847263C3C878B6BF71881C0F1';
GRANT ALL PRIVILEGES ON movie_booking TO admin WITH GRANT OPTION;

-- Création Limitation des droits de l'utilisateur lambda
CREATE USER IF NOT EXISTS lambda IDENTIFIED BY PASSWORD '*0CB2C5E0BAAE18D34F1F40B5D0A65E8C2946CF3F';
GRANT SELECT, SHOW VIEW ON movie_booking.* TO lambda;
FLUSH PRIVILEGES;

-- Sélection de la base de données
USE movie_booking;

-- Création des tables
CREATE TABLE Theatre
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  zipcode VARCHAR(5) NOT NULL,
  address VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE MovieRoom
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  seats INT(3) NOT NULL,
  theatre_id INT(10),
  FOREIGN KEY (theatre_id) REFERENCES Theatre (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE Genre
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  label VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE Movie
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  title VARCHAR(100) NOT NULL,
  release_date DATE NOT NULL,
  duration INT(3) NOT NULL,
  synopsis TEXT NOT NULL,
  rating VARCHAR(50) NOT NULL,
  genre_id INT(10),
  FOREIGN KEY (genre_id) REFERENCES Genre (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE MovieShow
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  date DATE NOT NULL,
  schedule TIME NOT NULL,
  movie_id INT(10),
  FOREIGN KEY (movie_id) REFERENCES Movie (id),
  movie_room_id INT(10),
  FOREIGN KEY (movie_room_id) REFERENCES MovieRoom (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE User
(
  id CHAR(36) PRIMARY KEY NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(60) NOT NULL,
  firstname VARCHAR(50) NOT NULL,
  lastname VARCHAR(50) NOT NULL,
  birthdate DATE NOT NULL,
  is_student BOOLEAN NOT NULL,
  phone_number VARCHAR(10) NOT NULL,
  role JSON NULL CHECK (JSON_VALID(role)),
  theatre_id INT NULL,
  FOREIGN KEY (theatre_id) REFERENCES Theatre (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE Price
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  amount DECIMAL(3,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE Booking
(
  id CHAR(36) PRIMARY KEY NOT NULL,
  user_id CHAR(36),
  FOREIGN KEY (user_id) REFERENCES User (id),
  movie_show_id INT(10),
  FOREIGN KEY (movie_show_id) REFERENCES MovieShow (id),
  price_id INT(10),
  FOREIGN KEY (price_id) REFERENCES Price (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE PaymentMethod
(
  id INT(10) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE Payment
(
  id CHAR(36) PRIMARY KEY NOT NULL,
  payment_method_id INT(10),
  FOREIGN KEY (payment_method_id) REFERENCES PaymentMethod (id),
  booking_id CHAR(36),
  FOREIGN KEY (booking_id) REFERENCES Booking (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Scripts d'alimentation de la base de données
INSERT INTO Theatre (name, city, zipcode, address) VALUES
  ('La Grande Toile', 'Montargis', '45200', '77, Boulevard Pompidou'),
  ('Le Séz''Art', 'Sézanne', '51120', 'Rue des Lys'),
  ('L''Eden', 'Romilly-sur-Seine', '10120', '64, rue Gambetta');

INSERT INTO MovieRoom (name, seats, theatre_id) VALUES
  ('Salle Spielberg', 50, 1),
  ('Salle Cameron', 45, 1),
  ('Salle Tarantino', 30, 1),
  ('Salle Kubrick', 55, 1),
  ('Salle Coppola', 45, 1),
  ('Salle Audiard', 40, 2),
  ('Salle Godard', 30, 2),
  ('Salle Truffaut', 40, 3),
  ('Salle Lelouch', 40, 3),
  ('Salle Renoir', 30, 3);

INSERT INTO Genre (label) VALUES 
  ('Action'), ('Animation'), ('Aventure'), ('Biographie'), ('Comédie'), ('Comédie Musicale'),
  ('Documentaire'), ('Drame'), ('Espionnage'), ('Fantastique'), ('Guerre'), ('Horreur'),
  ('Jeunesse'), ('Policier'), ('Romance'), ('Science-Fiction'), ('Thriller'), ('Western');

INSERT INTO Movie (title, release_date, duration, synopsis, rating, genre_id) VALUES
  ('Super Mario Bros', '2023-04-05', 92, 'Alors qu''ils tentent de réparer une canalisation souterraine, Mario et son frère Luigi, tous deux plombiers, se retrouvent plongés dans un nouvel univers féerique à travers un mystérieux conduit. Mais lorsque les deux frères sont séparés, Mario s''engage dans une aventure trépidante pour retrouver Luigi.', 'Tout public', 2),
  ('Les Trois Mousquetaires : D''Artagnan', '2023-04-05', 121, 'Du Louvre au Palais de Buckingham, des bas-fonds de Paris au siège de La Rochelle… dans un Royaume divisé par les guerres de religion et menacé d''invasion par l''Angleterre, une poignée d''hommes et de femmes vont croiser leurs épées et lier leur destin à celui de la France.', 'Tout public', 3),
  ('10 Jours Encore Sans Maman', '2023-04-12', 96, 'Après son licenciement, Antoine, ancien DRH d''une grande enseigne de bricolage, a choisi de rester à la maison pour s''occuper de ses 4 enfants. Un nouveau travail qu''il effectue la plupart du temps seul, car sa femme Isabelle est très occupée par sa nouvelle activité d''avocate. Depuis deux ans dans la famille Mercier, les rôles ont donc clairement été inversés et Antoine commence à de moins en moins tenir le coup face à l''énergie que lui demande sa petite famille. Voilà pourquoi 10 jours de vacances à la montagne s''annoncent comme une aubaine pour le père au foyer qu''il est devenu. Hélas, une affaire inespérée pour le cabinet d''Isabelle tombe du ciel. Elle n''a pas d''autres solutions que de laisser Antoine partir 10 jours au ski seul avec les 4 enfants, et surtout : sans maman !', 'Tout public', 5),
  ('Les Aventures de Ricky', '2023-04-19', 85, 'Ricky, un jeune moineau intrépide adopté par une famille de cigognes, est embarqué dans une aventure épique au cœur de l''Afrique. Accompagné de ses fidèles amis Olga la chouette pygmée et Kiki la perruche disco, il se lance à la poursuite d''un joyau légendaire…', 'Tout public', 13),
  ('Shazam! La Rage des Dieux', '2023-04-19', 130, 'Investis des pouvoirs des dieux, Billy Batson et ses copains apprennent encore à concilier leur vie d''ados avec leurs responsabilités de super-héros dès lors qu''ils se transforment en adultes. Mais quand les Filles de l''Atlas, trio d''anciennes déesses ivres de vengeance, débarquent sur Terre pour retrouver la magie qu''on leur a volée il y a longtemps, Billy, alias Shazam, et sa famille s''engagent dans une bataille destinée à conserver leurs superpouvoirs, à rester en vie et à sauver la planète. Mais une bande d''adolescents peut-elle vraiment empêcher la destruction du monde ? Et, surtout, Billy en a-t-il seulement envie ?', 'Tout public', 10);

INSERT INTO MovieShow (date, schedule, movie_id, movie_room_id) VALUES
  ('2023-04-23', '10:30:00', 1, 6),
  ('2023-04-23', '15:00:00', 1, 6),
  ('2023-04-24', '10:30:00', 1, 6),
  ('2023-04-24', '14:30:00', 1, 6),
  ('2023-04-25', '10:30:00', 1, 6),
  ('2023-04-25', '14:30:00', 1, 6),
  ('2023-04-23', '17:30:00', 2, 6),
  ('2023-04-23', '20:00:00', 2, 6),
  ('2023-04-24', '16:30:00', 2, 6),
  ('2023-04-24', '20:30:00', 2, 6),
  ('2023-04-25', '16:30:00', 2, 6),
  ('2023-04-23', '15:00:00', 3, 7),
  ('2023-04-23', '17:30:00', 3, 7),
  ('2023-04-24', '10:30:00', 3, 7),
  ('2023-04-24', '14:30:00', 3, 7),
  ('2023-04-25', '10:30:00', 3, 7),
  ('2023-04-25', '20:30:00', 3, 7),
  ('2023-04-24', '16:30:00', 4, 7),
  ('2023-04-25', '14:30:00', 4, 7),
  ('2023-04-23', '10:30:00', 5, 7),
  ('2023-04-23', '20:00:00', 5, 7),
  ('2023-04-24', '20:30:00', 5, 7),
  ('2023-04-25', '16:30:00', 5, 7),
  ('2023-04-25', '20:30:00', 5, 6),
  ('2023-04-23', '10:30:00', 1, 1),
  ('2023-04-23', '15:00:00', 1, 1),
  ('2023-04-24', '10:30:00', 1, 1),
  ('2023-04-24', '14:30:00', 1, 1),
  ('2023-04-25', '10:30:00', 1, 1),
  ('2023-04-25', '14:30:00', 1, 1),
  ('2023-04-23', '10:30:00', 1, 2),
  ('2023-04-23', '15:00:00', 1, 2),
  ('2023-04-24', '10:30:00', 1, 2),
  ('2023-04-24', '14:30:00', 1, 2),
  ('2023-04-25', '10:30:00', 1, 2),
  ('2023-04-25', '14:30:00', 1, 2),
  ('2023-04-23', '10:30:00', 5, 3),
  ('2023-04-23', '15:00:00', 5, 3),
  ('2023-04-24', '10:30:00', 5, 3),
  ('2023-04-24', '14:30:00', 5, 3),
  ('2023-04-25', '10:30:00', 5, 3),
  ('2023-04-25', '14:30:00', 5, 3),
  ('2023-04-23', '10:30:00', 5, 4),
  ('2023-04-23', '15:00:00', 5, 4),
  ('2023-04-24', '10:30:00', 5, 4),
  ('2023-04-24', '14:30:00', 5, 4),
  ('2023-04-25', '10:30:00', 5, 4),
  ('2023-04-25', '14:30:00', 5, 8),
  ('2023-04-24', '16:30:00', 4, 5),
  ('2023-04-25', '14:30:00', 4, 5);

INSERT INTO User (id, email, password, firstname, lastname, birthdate, is_student, phone_number, role) VALUES
  (UUID(), 'bad-dudelier@example.fr', '$2y$10$30O7detgQ07lg6GxO7Y/q.PXxmhXLqj2.l7ZUtp1/WsoURhTPqOhi', 'Florian', 'Badelier', '1983-12-31', 0, '0325211234', '["ROLE_ADMIN"]');
INSERT INTO User (id, email, password, firstname, lastname, birthdate, is_student, phone_number, role, theatre_id) VALUES
  (UUID(), 'alex.bugnot@example.fr', '$2y$10$YBIH5oH.gGUOQNmpYXsUNuQr9tR.QEO3N1EElpMiqLy3ezwTkaDhm', 'Alexandre', 'Bugnot', '1984-05-10', 0, '0325371235', '["ROLE_SUPERUSER"]', 1),
  (UUID(), 'rpulby@example.fr', '$2y$10$.usLu6qVYfFWhqz8Dnz4jej9NKp.QHPjcJTc7X/U5qvXBtK9.9bLu', 'Renaud', 'Pulby', '1984-11-19', 0, '0325215678', '["ROLE_SUPERUSER"]', 2),
  (UUID(), 'laclasse@example.fr', '$2y$10$8cCrX1QGeqW9/Q3RNDv./e.2.96AfUrfpFW88OtfOHyj9BoiGxJK.', 'Christophe', 'Laclasse', '1979-08-31', 0, '0325219012', '["ROLE_SUPERUSER"]', 3);
INSERT INTO User (id, email, password, firstname, lastname, birthdate, is_student, phone_number) VALUES
  (UUID(), 's.josselin@example.fr', '$2y$10$Hk/Fb5L8f9ft33RJ7VCLuOlrxsC6me79l7hG8aofHJshxXRMZyr2m', 'Sylvain', 'Josselin', '1985-02-02', 0, '0325212345'),
  (UUID(), 'sanaa-chan@example.fr', '$2y$10$fXwz5H7Yo8MmwKFSHN/Ws.EyNFT4KUPhrHo8wYTtooOk3nEAeUrkS', 'Leykhéna', 'Cuzin', '1993-04-10', 1, '0325801234'),
  (UUID(), 'cthomas@example.fr', '$2y$10$r2ZDwKoQWNpkoDSz3MtX4uqEMmz9E15.W0vJwHEE4/21PspY/4Fdy', 'Charlotte', 'Thomas', '2013-11-11', 0, '0325377890');

INSERT INTO Price (name, amount) VALUES
  ('Plein tarif', 9.20),
  ('Etudiant', 7.60),
  ('Moins de 14 ans', 5.90);

INSERT INTO Booking (id, user_id, movie_show_id, price_id) VALUES
  (UUID(), '59ae079c-e1dd-11ed-a4cc-6032b1b95ca3', 2, 1),
  (UUID(), '59ae16f1-e1dd-11ed-a4cc-6032b1b95ca3', 44, 2),
  (UUID(), '59ae079c-e1dd-11ed-a4cc-6032b1b95ca3', 38, 1),
  (UUID(), '59ae17bd-e1dd-11ed-a4cc-6032b1b95ca3', 33, 3),
  (UUID(), '59a7bb2b-e1dd-11ed-a4cc-6032b1b95ca3', 23, 1),
  (UUID(), '59ae16f1-e1dd-11ed-a4cc-6032b1b95ca3', 36, 2),
  (UUID(), '59a7ba7a-e1dd-11ed-a4cc-6032b1b95ca3', 14, 1),
  (UUID(), '59ae17bd-e1dd-11ed-a4cc-6032b1b95ca3', 47, 3),
  (UUID(), '59a7bb2b-e1dd-11ed-a4cc-6032b1b95ca3', 44, 1),
  (UUID(), '59a7ba7a-e1dd-11ed-a4cc-6032b1b95ca3', 23, 1),
  (UUID(), '59a7ab62-e1dd-11ed-a4cc-6032b1b95ca3', 23, 1);

INSERT INTO PaymentMethod (name) VALUES ('En ligne'), ('Sur place');

INSERT INTO Payment (id, payment_method_id, booking_id) VALUES
  (UUID(), 1, '273273f1-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 1, '27328814-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 1, '2732891a-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 2, '2732899e-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 2, '27328a13-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 1, '27328a80-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 2, '27328af2-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 2, '27328b55-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 1, '27328bd1-e1e1-11ed-a4cc-6032b1b95ca3'),
  (UUID(), 2, '27328c3a-e1e1-11ed-a4cc-6032b1b95ca3');

-- Requêtes permettant de prouver que l'on répond aux exigences du commanditaire

-- Possibilité de réserver dans plusieurs cinémas
SELECT booking.id AS 'Numéro de réservation', movie.title AS 'Titre du film', theatre.name AS 'Nom du cinéma'
FROM booking
JOIN movieshow ON booking.movie_show_id = movieshow.id
JOIN movie ON movieshow.movie_id = movie.id
JOIN movieroom ON movieshow.movie_room_id = movieroom.id
JOIN theatre ON movieroom.theatre_id = theatre.id
GROUP BY theatre.name;

-- Possibilité de réserver des places pour le même film au même horaire dans plusieurs salles d'un même cinéma
SELECT booking.id AS 'Numéro de réservation', movieshow.date AS 'Date', movieshow.schedule AS 'Horaire', movie.title AS 'Titre du film', movieroom.name AS 'Nom de la salle', theatre.name AS 'Nom du cinéma'
FROM booking
JOIN movieshow ON booking.movie_show_id = movieshow.id
JOIN movie ON movieshow.movie_id = movie.id
JOIN movieroom ON movieshow.movie_room_id = movieroom.id
JOIN theatre ON movieroom.theatre_id = theatre.id
WHERE movieshow.schedule = '15:00:00'
AND movie.id = 5;

-- Calculer le nombre de places restantes lors des projections à un horaire donné
SELECT movieroom.name AS 'Nom de la salle', movieroom.seats AS 'Nombre de places', COUNT(booking.movie_show_id) AS 'Nombre de réservations', movieroom.seats - COUNT(booking.movie_show_id) AS 'Places restantes'
FROM booking
JOIN movieshow ON booking.movie_show_id = movieshow.id
JOIN movieroom ON movieshow.movie_room_id = movieroom.id
WHERE movieshow.schedule = '15:00:00'
GROUP BY  movieroom.id;

-- Présence de différents tarifs
SELECT * FROM price;

-- Possibilité de régler la réservation selon les deux méthodes de paiement
SELECT booking.id AS 'Numéro de réservation', CONCAT(user.firstname, ' ', user.lastname) AS 'Identité du client', paymentmethod.name AS 'Méthode de paiement'
FROM booking
JOIN user ON booking.user_id = user.id
JOIN payment ON booking.id = payment.booking_id
JOIN paymentmethod ON payment.payment_method_id = paymentmethod.id;

-- Identité des administrateurs ayant tous les droits
SELECT CONCAT(user.firstname, ' ', user.lastname) AS 'Identité de l''utilisateur', user.role AS 'Rôle'
FROM user
WHERE user.role = '["ROLE_ADMIN"]';

-- Identité des superutilisateurs ayant les droits d'ajouter des séances dans leur structure
SELECT theatre.name AS 'Nom du cinéma', CONCAT(user.firstname, ' ', user.lastname) AS 'Identité de l''utilisateur', user.role AS 'Rôle'
FROM user
JOIN theatre ON user.theatre_id = theatre.id
WHERE user.role = '["ROLE_SUPERUSER"]';

-- Utilisation d'un utilitaire de sauvegarde
mysqldump -u root movie_booking > movie_booking.sql

-- Restauration de la base de données à partir de la sauvegarde
-- Creation de la base de données
mysql -u root
CREATE DATABASE IF NOT EXISTS movie_booking;

-- Restauration dans une nouvelle fenêtre du terminal
mysql -u root movie_booking < movie_booking.sql