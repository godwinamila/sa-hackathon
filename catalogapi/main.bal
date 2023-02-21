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
        io:println("Init Catalog service!");
    }

    resource function get catalog() returns Catalog[]|error {
        io:println("Execute get all catalog API.");
        Catalog[] catalogarr = [];
        catalogarr.push({"item_id" : 1, "description" : "Test1", "unit_price" : 120});

        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `SELECT * FROM catalog`;
        Catalog[] catalogs = check dbClient->queryRow(query);
        return catalogs;
    }

    resource function get catalog/[string catalogid]() returns Catalog|error {
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `SELECT * FROM catalog WHERE item_id = ${catalogid}`;
        Catalog catalog = check dbClient->queryRow(query);
        return catalog;
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