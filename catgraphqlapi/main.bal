import ballerina/graphql;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/io;
import ballerinax/mysql.driver as _;

public type Catalog record {
        readonly int item_id;
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



public distinct service class CatalogData {
    private final readonly & Catalog entryRecord;    
    
    function init(Catalog entryRecord) {
        self.entryRecord = entryRecord.cloneReadOnly();
    }

    resource function get id() returns int {
        return self.entryRecord.item_id;
    }

    resource function get description() returns string {
        return self.entryRecord.description;
    }

    resource function get unitprice() returns decimal? {
        return self.entryRecord.unit_price;        
    }

    resource function get title() returns string {
        return self.entryRecord.title;
    }

    resource function get includes() returns string {
        return self.entryRecord.includes;
    }

    resource function get intended() returns string {
        return self.entryRecord.intended;
    }

    resource function get color() returns string {
        return self.entryRecord.color;
    }
    resource function get material() returns string {
        return self.entryRecord.material;
    }
}

service /catalogs on new graphql:Listener(9000) {
    resource function get all() returns Catalog[]|error {
        io:println("Execute get all catalog API.");
        Catalog[] catalogarr = [];
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `SELECT * FROM catalog`;
        // Catalog[] catalogs = check dbClient->query(query);


        // sql:ParameterizedQuery query = 'SELECT * FROM catalog';
        stream<Catalog, sql:Error?> resultStream = dbClient->query(query);

        Catalog[] catalogs = [];
        check from Catalog catalog in resultStream 
            do {
                // Can perform operations using the record 'student'.
                io:println("description: ", catalog.description);
                io:println("item price: ", catalog.unit_price);
                catalogs.push(catalog);
            };

        return catalogs;        
    }

    resource function get filter(int id) returns Catalog|error {
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `SELECT * FROM catalog WHERE item_id = ${id}`;
        Catalog|error catalog =  dbClient->queryRow(query);
        return catalog;
    }

}