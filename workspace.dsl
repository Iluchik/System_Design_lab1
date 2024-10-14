workspace {
    name "Сервис доставки SDEK"
    description "Лабораторная работа №1"

    model {
		p1 = person "Пользователь"
		p2 = person "Курьер"
		
		s1 = softwareSystem "Приложение SDEK" {
			userService = container "User Service" "Сервис для работы с пользователями" "Java, Spring Boot"
			packageService = container "Package Service" "Сервис для работы с посылками" "Java, Spring Boot"
			deliveryService = container "Delivery Service" "Сервис для организации доставки" "Java, Spring Boot"
			ROS = container "Route optimization service" "Сервис оптимизации доставки" "Java, Spring Boot"

			userDB = container "User database" "База данных пользователей" "PostgreSQL"
			packageDB = container "Package database" "База данных посылок" "PostgreSQL"
			deliveryDB = container "delivry database" "База данных доставки" "PostgreSQL"
			RODB = container "Route optimization database" "База данных карт" "PostgreSQL"
		}

		s2 = softwareSystem "Курьерская служба"

		p1 -> s1 "Заказывает/отправляет посылку"
		s1 -> s2 "Отправляет запрос на доставку посылки"
		s2 -> p2 "Передаёт посылку курьеру"
		p2 -> p1 "Доставляет посылку"

		p1 -> userService "Управляет аккаунтом" "HTTPS"
		p1 -> packageService "Управляет посылками" "HTTPS"
		p1 -> deliveryService "Управляет доставкой" "HTTPS"

		p2 -> userService "Управляет аккаунтом" "HTTPS"
		p2 -> deliveryService "Получает информацию о доставках/изменяет статусы доставок" "HTTPS"
		p2 -> ROS "Получает кратчайший маршрут" "HTTPS"
		ROS -> RODB "Взаимодействует с данными карт" "JDBS"

		userService -> userDB "Взаимодействует с данными о пользователях" "JDBS"
		packageService -> packageDB "Взаимодействует с данными о посылках" "JDBS"
		deliveryService -> deliveryDB "Взаимодействует с данными о доставках" "JDBS"
		packageService -> deliveryService "Отправляет данные о посылке" "REST API"
		deliveryService -> s2 "Отправляет запрос на доставку посылки"
    }

    views {
		themes default
		systemContext s1 {
			include *
			include p2
			autoLayout lr
		}

		themes default
		container s1 {
			include *
			include p2
			autoLayout lr
		}

		themes default
		dynamic s1 {
			autoLayout lr

			p2 -> userService "POST /users"
			userService -> userDB "Авторизация"
			userService -> p2 "Подтверждение авторизации"

			p2 -> deliveryService "GET /deliveries?recipientId={recipientId}"
			deliveryService -> deliveryDB "Получение информации о доставках"
			deliveryService -> p2 "Предоставление списка доставок со всеми дополнительными инструкциями по доставке"
			deliveryService -> s2 "Отправляет запрос на доставку посылки с данными о курьере"
			s2 -> p2 "Передает посылку курьеру"

			p2 -> ROS "Запрос на получение кратчайшего маршрута"
			ROS -> RODB "Получает данные карт"
			ROS -> p2 "Отправляет построенный кратчайший маршрут"

			p2 -> deliveryService "Обновляет статус доставки (начало доставки)"
			p2 -> p1 "Доставляет посылку"
			p2 -> deliveryService "Обновляет статус доставки (конец доставки)"
		}
    }

}