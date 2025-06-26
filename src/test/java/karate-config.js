function fn() {
    karate.configure('connectTimeout', 5000);
    karate.configure('readTimeout', 5000);
    // karate.configure('abortSuiteOnFailure', true);

    var protocol = 'https';
    var server = 'thinking-tester-contact-list.herokuapp.com';
    
    // Configuración para diferentes entornos
    if (karate.env == 'local') {
        protocol = 'http';
        server = 'localhost:3000';
    }

    var config = {
        baseUrl: protocol + '://' + server,
        // Credenciales de prueba
        validEmail: 'andresprueba@hotmail.com',
        validPassword: '1234567',
        invalidEmail: 'testttt@testtt.com',
        invalidPassword: '1111',
        malformedEmail: 'andrespruebahotmail.com'
    };
    
    config.faker = Java.type('com.github.javafaker.Faker');

    return config;
}