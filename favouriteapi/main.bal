import ballerina/io;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;



type Favourite record {
        int favourite_id;
        int item_id;
        string user_name;  
};

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;

int PORT = 3306;
string DATABASE = "godwin_db";
final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE, connectionPool={maxOpenConnections: 3});
        

service / on new http:Listener(9000) {

    //create database connection


    function init() returns error? {
        io:println("Init Favourite service!");
    }    

    resource function post favourites(@http:Payload Favourite favourite) returns http:Ok|http:BadRequest|error {
        
        io:println("Invoke favourites create resource");        

        sql:ParameterizedQuery query = `INSERT INTO favourites(item_id, user_name)VALUES (${favourite.item_id}, ${favourite.user_name})`;
        sql:ExecutionResult result = check dbClient->execute(query);
        
        http:Ok response = {body: {status: "ok"}};
        return response;
    }


    resource function delete favourites(int item_id, string user_name) returns http:Ok|http:BadRequest|error {
        
        io:println("Invoke favourites delete resource");        

        sql:ParameterizedQuery query = `DELETE FROM favourites where item_id=${item_id} AND user_name=${user_name}`;
        sql:ExecutionResult result = check dbClient->execute(query);
        
        http:Ok response = {body: {status: "ok"}};
        return response;
    }
        
}


public type ErrorMsg record {|
   string errmsg;
|};
public type CatalogCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};