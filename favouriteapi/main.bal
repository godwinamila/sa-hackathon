import ballerina/io;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;



type Catalog record {
        int item_id;
        string description;
        decimal unit_price;  
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

service / on new http:Listener(9090) {

    

    function init() returns error? {
        io:println("Init Favourite service!");
    }
resource function post catalog(@http:Payload Catalog catalog)
                                    returns Catalog|CatalogCodesError|error {
                        
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `INSERT INTO catalog(description, name)VALUES (${catalog.description}, ${catalog.unit_price})`;
        sql:ExecutionResult result = check dbClient->execute(query);
        
        return catalog;

    }

    resource function put catalog(@http:Payload Catalog catalog)
                                    returns Catalog|CatalogCodesError {
        return catalog;
    }
        
}


public type ErrorMsg record {|
   string errmsg;
|};
public type CatalogCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};