Map<String, String> mapping = new Map<String, String>();
//https://my.api.mockaroo.com/contacts.json?key=ea962e00

Http h = new Http();
// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
HttpRequest req = new HttpRequest();
req.setEndpoint('https://my.api.mockaroo.com/contacts.json?key=ea962e00');
req.setMethod('GET');

// Send the request, and return a response
HttpResponse res = h.send(req);
String incomingJson = res.getBody();

// mapping.put('id','upsertId__c');
mapping.put('first_name', 'firstName');
mapping.put('last_name', 'lastName');
mapping.put('email', 'email');
// mapping.put('ip_address','last_known_ip_address__c');
// mapping.put('source', 'app_source__c');
mapping.put('country', 'mailingCountry');
mapping.put('StreetAddress', 'mailingStreet');
mapping.put('city', 'mailingCity');
mapping.put('state', 'mailingState');
mapping.put('postalCode', 'mailingPostalCode');

DWJson jsonUtils = new DWJson(incomingJson, JSON.serialize(mapping));
List<Contact> contacts = (List<Contact>) jsonUtils.translateToSObjects(
  'Contact'
);
insert contacts;
