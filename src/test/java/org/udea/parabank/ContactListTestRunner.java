package org.udea.parabank;

import com.intuit.karate.junit5.Karate;

/**
 * TestRunner para las pruebas del Contact List API
 * Ejecuta las historias de usuario definidas para el sistema de gestión de
 * contactos
 */
class ContactListTestRunner {

    @Karate.Test
    Karate testLoginAuthentication() {
        return Karate.run("login-authentication")
                .relativeTo(getClass())
                .outputCucumberJson(true)
                .reportDir("target/karate-reports");
    }

    @Karate.Test
    Karate testCreateContact() {
        return Karate.run("create-contact")
                .relativeTo(getClass())
                .outputCucumberJson(true)
                .reportDir("target/karate-reports");
    }

    @Karate.Test
    Karate testAllContactListFeatures() {
        return Karate.run("login-authentication", "create-contact")
                .relativeTo(getClass())
                .outputCucumberJson(true)
                .reportDir("target/karate-reports");
    }

}