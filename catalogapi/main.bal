import ballerina/io;
import ballerina/http;
// import ballerinax/mysql;
// import ballerina/sql;
import ballerinax/mysql.driver as _;



type Catalog record {
        int item_id;
        string description;
        decimal unit_price;
        string title;  
        string includes;  
        string intended;  
        string color;  
        string material;  
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;

int PORT = 3306;
string DATABASE = "godwin_db";

// final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE, connectionPool={maxOpenConnections: 3});


service / on new http:Listener(9000) {

    

    function init() returns error? {
        io:println("Init Catalog service!");
    
    }
    
    resource function delete test1() returns http:Ok {

        io:println("Invoke catalogs test1 resource");
        http:Ok response = {body: {status: "ok"}};
        return response;
    }

    // resource function delete catalogs(string catalogid) returns http:Ok|http:BadRequest|error {

    //     io:println("Invoke catalogs delete resource");        

    //     sql:ParameterizedQuery query = `DELETE FROM catalog WHERE item_id=${catalogid}`;
    //     sql:ExecutionResult result = check dbClient->execute(query);
        
    //     http:Ok response = {body: {status: "ok"}};
    //     return response;
    // }

    // resource function delete catalogs/[string catalogid]() returns http:Ok|http:BadRequest|error {

    //     io:println("Invoke catalogs delete resource");        

    //     sql:ParameterizedQuery query = `DELETE FROM catalog WHERE item_id=${catalogid}`;
    //     sql:ExecutionResult result = check dbClient->execute(query);
        
    //     http:Ok response = {body: {status: "ok"}};
    //     return response;
    // }

    // resource function post catalogs(@http:Payload Catalog catalog) returns http:Ok|http:BadRequest|error {
        
    //     io:println("Invoke catalogs create resource");        

    //     sql:ParameterizedQuery query = `INSERT INTO catalog(description, unit_price, title,includes,intended,color,material)VALUES (${catalog.description}, ${catalog.unit_price}, ${catalog.title}, ${catalog.includes}, ${catalog.intended}, ${catalog.color}, ${catalog.material})`;
    //     sql:ExecutionResult result = check dbClient->execute(query);
        
    //     http:Ok response = {body: {status: "ok"}};
    //     return response;
    // }


    // resource function put catalogs(@http:Payload Catalog catalog) returns http:Ok|http:BadRequest|error {
                
    //     sql:ParameterizedQuery query = `UPDATE catalog SET description=${catalog.description} , unit_price=${catalog.unit_price}, title=${catalog.title},includes=${catalog.includes},intended=${catalog.intended},color=${catalog.color},material=${catalog.material} WHERE item_id=${catalog.item_id}`;
    //     sql:ExecutionResult result = check dbClient->execute(query);
        
    //     http:Ok response = {body: {status: "ok"}};
    //     return response;        
    // }
        
}


// public type ErrorMsg record {|
//    string errmsg;
// |};
// public type CatalogCodesError record {|
//     *http:Conflict;
//     ErrorMsg body;
// |};