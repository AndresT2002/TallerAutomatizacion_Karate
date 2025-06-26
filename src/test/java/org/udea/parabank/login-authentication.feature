@login_authentication
Feature: Historia de Usuario 1 - Login y Autenticación
  Como usuario registrado,
  quiero iniciar sesión con mis credenciales,
  para acceder a mi lista de contactos protegida.

  Background:
    * url baseUrl
    * header Accept = 'application/json'
    * header Content-Type = 'application/json'

  Scenario: Login exitoso con credenciales válidas retorna token JWT
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
    And match response contains { token: '#string' }
    And match response contains { user: '#object' }
    And match response.user.email == validEmail
    * def authToken = response.token
    * print 'Token obtenido:', authToken

  Scenario: Token debe ser reutilizable para obtener contactos
    # Primero hacer login para obtener token
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
    
    # Usar token para acceder a contactos
    Given path 'contacts'
    And header Authorization = 'Bearer ' + authToken
    When method GET
    Then status 200
    And match response == '#array'

  Scenario: Login con email inválido retorna error
    Given path 'users/login'
    And request 
    """
    {
      "email": "#(invalidEmail)",
      "password": "#(validPassword)"
    }
    """
    When method POST
    Then status 401
    And match response.message == 'Incorrect email or password'

  Scenario: Login con password inválido retorna error
    Given path 'users/login'
    And request 
    """
    {
      "email": "#(validEmail)",
      "password": "#(invalidPassword)"
    }
    """
    When method POST
    Then status 401
    And match response.message == 'Incorrect email or password'

  Scenario: Login con email malformado retorna error de validación
    Given path 'users/login'
    And request 
    """
    {
      "email": "#(malformedEmail)",
      "password": "#(validPassword)"
    }
    """
    When method POST
    Then status 400
    And match response.message == '#string'

  Scenario: Login sin email es requerido
    Given path 'users/login'
    And request 
    """
    {
      "password": "#(validPassword)"
    }
    """
    When method POST
    Then status 400

  Scenario: Login sin password es requerido
    Given path 'users/login'
    And request 
    """
    {
      "email": "#(validEmail)"
    }
    """
    When method POST
    Then status 400

  Scenario: Validar formato de email correcto
    Given path 'users/login'
    And request 
    """
    {
      "email": "test@valid-email.com",
      "password": "#(validPassword)"
    }
    """
    When method POST
    Then status 401
    # Debe fallar por credenciales inválidas, no por formato de email
    And match response.message == 'Incorrect email or password' 