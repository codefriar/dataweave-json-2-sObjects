/**
 * @description Class provides a re-usable, dynamic and typesafe way to
 * translate an API's JSON response into a list of sObjects.
 */
public with sharing class DWJson {
  // incomingJson can be any json string
  private String incomingJson;
  // keyMap is a JSON formatted key:value map where the left side is the name of the
  // key in the incomingJson object, and the right side is the name of the key in
  // the returning json.
  private String keyMap;

  /**
   * @description        full constructor
   * @param incomingJson json string
   * @param keyMap       Map representing JSON key names in the input and output json strings
   */
  public DWJson(String incomingJson, String keyMap) {
    this.incomingJson = incomingJson;
    this.keyMap = keyMap;
  }
  public DWJson(String incomingJson) {
    this(incomingJson, '');
  }

  /**
   * @description       Given a valid string representation of an sObject
   * this method utilizes class variables of json and keyMap to translate
   * the input json's keys into those specified in the mapping object.
   * @param sObjectType This is the type of List<sObject> to return.
   * @return            `List<sObject>`
   */
  public String translate() {
    Map<String, Object> parameters = new Map<String, Object>();
    parameters.put('mapping', keyMap);
    parameters.put('incomingJson', incomingJson);
    Dataweave.Script script = Dataweave.Script.createScript('json2sObjects');
    DataWeave.Result result = script.execute(parameters);
    return result.getValueAsString();
  }

  /**
   * @description       Method extends the translate method by deserializing the resulting json
   * to a List<sObject>. This method relies on Apex's ability to seamlessly cast from a list of
   * concrete sObjects to a list of generic sObjects. This allows the calling code to cast the
   * resulting list to a List<sObject> to a list of concrete sObject records.
   * @param sObjectType String representation of the concrete sObject type to be returned.
   * @return            `List<sObject>`
   */
  public List<sObject> translateToSObjects(String sObjectType) {
    // construct a Type object reflecting a List of the concrete sObject type specified
    Type dynamicListType = Type.forName('List<' + sObjectType + '>');
    // Create a list of the dynamic type to hold our resulting records.
    List<sObject> sObjects = (List<sObject>) dynamicListType.newInstance();
    // This line is a doozy, and the bulk of the work happens here.
    // translate is called to get the json string, and then the resulting json is
    // deserialized into a List<sObject> because this list was created
    // with a concrete sObject type, and then cast to a generic sObject list
    // the type system is able to re-cast to a concrete sObject list at the
    // site of the calling code.
    return (List<sObject>) JSON.deserialize(translate(), dynamicListType);
  }
}
