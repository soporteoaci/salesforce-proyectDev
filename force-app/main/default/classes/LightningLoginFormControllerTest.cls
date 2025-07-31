@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {
    
    @IsTest
    static void testLoginWithInvalidCredentials() {
        //System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
        LightningLoginFormController.setExperienceId('12345');
    }
    
    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    @isTest static void testLoginReturnsNullWhenLoginFails() {
        // Datos inválidos que harán que Site.login devuelva null
        String username = 'fakeuser@example.com';
        String password = 'badpass';
        String startUrl = '/home';
        
        // Ejecutar el método
        String result = LightningLoginFormController.login(username, password, startUrl);
        
        // No se lanza excepción, solo se devuelve null (lo que cubre el método)
        System.assertEquals(null, result, 'Debe devolver null si no hubo excepción');
        
    }
}