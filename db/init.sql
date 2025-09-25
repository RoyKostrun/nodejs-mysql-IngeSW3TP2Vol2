-- Archivo de inicialización para MySQL - TP Docker
-- Crea bases de datos y usuarios para QA y PROD

-- Crear bases de datos
CREATE DATABASE IF NOT EXISTS quotes_qa;
CREATE DATABASE IF NOT EXISTS quotes_prod;

-- Crear usuarios
CREATE USER IF NOT EXISTS 'qa_user'@'%' IDENTIFIED BY 'qa_password_123';
CREATE USER IF NOT EXISTS 'prod_user'@'%' IDENTIFIED BY 'prod_password_456';

-- Asignar permisos
GRANT ALL PRIVILEGES ON quotes_qa.* TO 'qa_user'@'%';
GRANT ALL PRIVILEGES ON quotes_prod.* TO 'prod_user'@'%';
FLUSH PRIVILEGES;

-- Configurar QA
USE quotes_qa;

CREATE TABLE `quote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quote` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_quote_unique` (`quote`),
  KEY `idx_author` (`author`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `quote` (`quote`, `author`) VALUES
('[QA] There are only two kinds of languages: the ones people complain about and the ones nobody uses.', 'Bjarne Stroustrup'),
('[QA] Any fool can write code that a computer can understand. Good programmers write code that humans can understand.', 'Martin Fowler'),
('[QA] First, solve the problem. Then, write the code.', 'John Johnson'),
('[QA] Testing leads to failure, and failure leads to understanding.', 'Burt Rutan'),
('[QA] The best error message is the one that never shows up.', 'Thomas Fuchs');

-- Configurar PROD  
USE quotes_prod;

CREATE TABLE `quote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quote` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_quote_unique` (`quote`),
  KEY `idx_author` (`author`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `quote` (`quote`, `author`) VALUES
('There are only two kinds of languages: the ones people complain about and the ones nobody uses.', 'Bjarne Stroustrup'),
('Any fool can write code that a computer can understand. Good programmers write code that humans can understand.', 'Martin Fowler'),
('First, solve the problem. Then, write the code.', 'John Johnson'),
('Java is to JavaScript what car is to Carpet.', 'Chris Heilmann'),
('Always code as if the guy who ends up maintaining your code will be a violent psychopath who knows where you live.', 'John Woods'),
('I\'m not a great programmer; I\'m just a good programmer with great habits.', 'Kent Beck'),
('Truth can only be found in one place: the code.', 'Robert C. Martin'),
('If you have to spend effort looking at a fragment of code and figuring out what it\'s doing, then you should extract it into a function and name the function after the \"what\".', 'Martin Fowler'),
('The real problem is that programmers have spent far too much time worrying about efficiency in the wrong places and at the wrong times; premature optimization is the root of all evil (or at least most of it) in programming.', 'Donald Knuth'),
('SQL, Lisp, and Haskell are the only programming languages that I\'ve seen where one spends more time thinking than typing.', 'Philip Greenspun'),
('Deleted code is debugged code.', 'Jeff Sickel'),
('There are two ways of constructing a software design: One way is to make it so simple that there are obviously no deficiencies and the other way is to make it so complicated that there are no obvious deficiencies.', 'C.A.R. Hoare'),
('Simplicity is prerequisite for reliability.', 'Edsger W. Dijkstra'),
('There are only two hard things in Computer Science: cache invalidation and naming things.', 'Phil Karlton'),
('Measuring programming progress by lines of code is like measuring aircraft building progress by weight.', 'Bill Gates');