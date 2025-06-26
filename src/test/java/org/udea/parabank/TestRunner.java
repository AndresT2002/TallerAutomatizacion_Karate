package org.udea.parabank;

import com.intuit.karate.junit5.Karate;

class TestRunner {

    // @Karate.Test
    // Karate test01_ParabankLogin() {
    // return Karate.run("login")
    // .relativeTo(getClass())
    // .outputCucumberJson(true);
    // }

    @Karate.Test
    Karate test02_LoginAuthentication() {
        return Karate.run("login-authentication")
                .relativeTo(getClass())
                .outputCucumberJson(true);
    }

    @Karate.Test
    Karate test03_CreateContact() {
        return Karate.run("create-contact")
                .relativeTo(getClass())
                .outputCucumberJson(true);
    }

}
