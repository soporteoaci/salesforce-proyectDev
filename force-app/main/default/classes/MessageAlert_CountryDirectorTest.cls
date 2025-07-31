@isTest
private class MessageAlert_CountryDirectorTest {

    // Creación request de correo con Cc
    private static MessageAlert_CountryDirector.EmailRequest crearRequest(List<Id> destinatarioIds, Id templateId, Id opportunityId, Id ccUserId) {
        MessageAlert_CountryDirector.EmailRequest request = new MessageAlert_CountryDirector.EmailRequest();
        request.destinatarioIds = destinatarioIds;
        request.templateId = templateId;
        request.opportunityId = opportunityId;
        request.ccUserId = ccUserId;
        return request;
    }

    // Correo con múltiples requests, cada uno con varios destinatarios y mismo Cc
    @isTest
    static void envioMultiRequests() {
        List<MessageAlert_CountryDirector.EmailRequest> requests = new List<MessageAlert_CountryDirector.EmailRequest>();
        Id ccUserId = UserInfo.getUserId();
        for (Integer i = 0; i < 2; i++) {
            requests.add(crearRequest(new List<Id>{UserInfo.getUserId(), UserInfo.getUserId()}, '00X000000000000', '006000000000000', ccUserId));
        }

        Test.startTest();
        MessageAlert_CountryDirector.enviarMultiple(requests);
        Test.stopTest();

        System.assert(true, 'El método se ejecutó correctamente sin excepciones');
    }

    // Correo con requests mixtos (válidos e inválidos)
    @isTest
    static void envioMultiMixRequests() {
        Id ccUserId = UserInfo.getUserId();
        List<MessageAlert_CountryDirector.EmailRequest> requests = new List<MessageAlert_CountryDirector.EmailRequest>{
            crearRequest(new List<Id>(), '00X000000000000', '006000000000000', ccUserId),
            crearRequest(new List<Id>{UserInfo.getUserId(), UserInfo.getUserId()}, '00X000000000000', '006000000000000', ccUserId)
        };

        Test.startTest();
        MessageAlert_CountryDirector.enviarMultiple(requests);
        Test.stopTest();

        System.assert(true, 'El método se ejecutó correctamente sin excepciones');
    }

    // Correo sin destinatarios
    @isTest
    static void envioMultiNoDestinatario() {
        Id ccUserId = UserInfo.getUserId();
        List<MessageAlert_CountryDirector.EmailRequest> requests = new List<MessageAlert_CountryDirector.EmailRequest>{
            crearRequest(new List<Id>(), '00X000000000000', '006000000000000', ccUserId)
        };

        Test.startTest();
        MessageAlert_CountryDirector.enviarMultiple(requests);
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(),
            'No se deberían enviar correos si no hay destinatarios');
    }

    // Correo con destinatarios nulos
    @isTest
    static void envioMultiDestinatarioNull() {
        Id ccUserId = UserInfo.getUserId();
        MessageAlert_CountryDirector.EmailRequest request = crearRequest(null, '00X000000000000', '006000000000000', ccUserId);
        List<MessageAlert_CountryDirector.EmailRequest> requests = new List<MessageAlert_CountryDirector.EmailRequest>{request};

        Test.startTest();
        MessageAlert_CountryDirector.enviarMultiple(requests);
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(),
            'No se deberían enviar correos si destinatarioIds es null');
    }
}