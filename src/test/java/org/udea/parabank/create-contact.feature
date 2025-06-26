@create_contact
Feature: Historia de Usuario 2 - Crear Contactos
  Como usuario autenticado,
  quiero crear un nuevo contacto con su información básica,
  para tenerlo disponible en mi lista personal.

  Background:
    * url baseUrl
    * configure headers = { Accept: 'application/json', Content-Type: 'application/json' }
    
    # Obtener token de autenticación para todas las pruebas
    Given path 'users/login'
    And request 
    """
    {
      "email": "#(validEmail)",
      "password": "#(validPassword)"
    }
    """
    When method POST
    Then status 200
    * def authToken = response.token
    * print 'Token obtenido:', authToken
    * def authHeader = 'Bearer ' + authToken
    * configure headers = { Accept: 'application/json', 'Content-Type': 'application/json', Authorization: '#(authHeader)' }

  Scenario: Crear contacto exitosamente con datos válidos
    * def uniqueEmail = 'test_' + java.lang.System.currentTimeMillis() + '@karate.com'
    * def contactData = 
    """
    {
      "firstName": "Juan",
      "lastName": "Pérez",
      "birthdate": "1990-05-15",
      "email": "#(uniqueEmail)",
      "phone": "123456789",
      "street1": "123 Main St",
      "street2": "Apt 2B",
      "city": "Madrid",
      "stateProvince": "Madrid",
      "postalCode": "28001",
      "country": "España"
    }
    """
    
    Given path 'contacts'
    And request contactData
    When method POST
    Then status 201
    And match response contains { _id: '#string' }
    And match response.firstName == 'Juan'
    And match response.lastName == 'Pérez'
    And match response.email == uniqueEmail
    And match response.city == 'Madrid'
    * def contactId = response._id
    * print 'Contacto creado con ID:', contactId

  Scenario: Contacto creado aparece en la lista de contactos
    * def uniqueEmail = 'list_test_' + java.lang.System.currentTimeMillis() + '@karate.com'
    
    # Crear contacto
    Given path 'contacts'
    And request 
    """
    {
      "firstName": "María",
      "lastName": "García",
      "birthdate": "1985-08-20",
      "email": "#(uniqueEmail)",
      "phone": "987654321",
      "street1": "456 Oak Ave",
      "street2": "Suite 100",
      "city": "Barcelona",
      "stateProvince": "Cataluña",
      "postalCode": "08001",
      "country": "España"
    }
    """
    When method POST
    Then status 201
    * def contactId = response._id
    
    # Verificar que aparece en la lista
    Given path 'contacts'
    When method GET
    Then status 200
    And match response == '#array'
    And match response[*]._id contains contactId
    And match response[*].firstName contains 'María'

  Scenario: Error al crear contacto sin firstName (campo requerido)
    Given path 'contacts'
    And request 
    """
    {
      "lastName": "TestLastName",
      "birthdate": "1990-01-01",
      "email": "no_firstname@test.com",
      "phone": "123456789",
      "street1": "123 Test St",
      "street2": "Apt 1",
      "city": "TestCity",
      "stateProvince": "TestState",
      "postalCode": "12345",
      "country": "TestCountry"
    }
    """
    When method POST
    Then status 400

  Scenario: Error al crear contacto sin lastName (campo requerido)
    Given path 'contacts'
    And request 
    """
    {
      "firstName": "TestFirstName",
      "birthdate": "1990-01-01",
      "email": "no_lastname@test.com",
      "phone": "123456789",
      "street1": "123 Test St",
      "street2": "Apt 1",
      "city": "TestCity",
      "stateProvince": "TestState",
      "postalCode": "12345",
      "country": "TestCountry"
    }
    """
    When method POST
    Then status 400

  Scenario: Error al crear contacto con email duplicado
    * def duplicateEmail = 'duplicate_' + java.lang.System.currentTimeMillis() + '@test.com'
    
    # Crear primer contacto
    Given path 'contacts'
    And request 
    """
    {
      "firstName": "Primer",
      "lastName": "Contacto",
      "birthdate": "1990-01-01",
      "email": "#(duplicateEmail)",
      "phone": "123456789",
      "street1": "123 First St",
      "street2": "Apt 1",
      "city": "FirstCity",
      "stateProvince": "FirstState",
      "postalCode": "12345",
      "country": "FirstCountry"
    }
    """
    When method POST
    Then status 201


    Given path 'contacts'
    And request 
    """
    {
      "firstName": "Segundo",
      "lastName": "Contacto",
      "birthdate": "1991-02-02",
      "email": "#(duplicateEmail)",
      "phone": "987654321",
      "street1": "456 Second St",
      "street2": "Apt 2",
      "city": "SecondCity",
      "stateProvince": "SecondState",
      "postalCode": "54321",
      "country": "SecondCountry"
    }
    """
    When method POST
    # Nota: Es 403 por el tema de que ya existe
    Then status 403
    * print 'Segundo contacto también creado - la API permite emails duplicados'

  Scenario: Crear múltiples contactos con datos dinámicos usando Faker
    * def faker = new faker()
    * def randomFirstName = faker.name().firstName()
    * def randomLastName = faker.name().lastName()
    * def randomEmail = faker.internet().emailAddress()
    # Generar teléfono simple válido (solo números)
    * def randomPhoneNumber = java.lang.Math.floor(java.lang.Math.random() * 900000000) + 100000000
    * def randomPhone = randomPhoneNumber + ''
    * def randomCity = faker.address().city()
    
    Given path 'contacts'
    And request 
    """
    {
      "firstName": "#(randomFirstName)",
      "lastName": "#(randomLastName)",
      "birthdate": "1990-01-01",
      "email": "#(randomEmail)",
      "phone": "#(randomPhone)",
      "street1": "123 Faker St",
      "street2": "Apt 1",
      "city": "#(randomCity)",
      "stateProvince": "TestState",
      "postalCode": "12345",
      "country": "TestCountry"
    }
    """
    When method POST
    Then status 201
    And match response.firstName == randomFirstName
    And match response.lastName == randomLastName
    And match response.email == randomEmail
    And match response.city == randomCity

  Scenario: Recuperar contacto vía API inmediatamente después de crearlo
    * def uniqueEmail = 'retrieve_test_' + java.lang.System.currentTimeMillis() + '@karate.com'
    
    # Crear contacto
    Given path 'contacts'
    And request 
    """
    {
      "firstName": "Carlos",
      "lastName": "Ruiz",
      "birthdate": "1988-12-10",
      "email": "#(uniqueEmail)",
      "phone": "555123456",
      "street1": "789 Pine Rd",
      "street2": "Unit C",
      "city": "Valencia",
      "stateProvince": "Valencia",
      "postalCode": "46001",
      "country": "España"
    }
    """
    When method POST
    Then status 201
    * def contactId = response._id
    
    # Recuperar contacto específico
    Given path 'contacts', contactId
    When method GET
    Then status 200
    And match response._id == contactId
    And match response.firstName == 'Carlos'
    And match response.lastName == 'Ruiz'
    And match response.email == uniqueEmail 