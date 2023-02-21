import ballerina/graphql;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/io;
import ballerinax/mysql.driver as _;

public type Catalog record {
        readonly int item_id;
        string description;
        decimal unit_price;  
};


configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
int PORT = 3306;
string DATABASE = "godwin_db";

table<Catalog> key(item_id) catalogTable = table [
    {item_id: 1, description: "test1", unit_price: 159303},
    {item_id: 2, description: "test2", unit_price: 159303},
    {item_id: 3, description: "test3", unit_price: 159303}
];

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
}

service /covid19 on new graphql:Listener(9000) {
    resource function get all() returns Catalog[]|error {
        io:println("Execute get all catalog API.");
        Catalog[] catalogarr = [];
        catalogarr.push({"item_id" : 1, "description" : "Test1", "unit_price" : 120});

        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `SELECT * FROM catalog`;
        Catalog[] catalogs = check dbClient->queryRow(query);
        return catalogs;
        // Catalog[] catalogEntries = catalogTable.toArray().cloneReadOnly();
        // return catalogEntries.map(entry => new Catalog(entry));
    }

    resource function get filter(int id) returns Catalog|error {
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database="godwin_db");
        sql:ParameterizedQuery query = `SELECT * FROM catalog WHERE item_id = ${id}`;
        Catalog catalog = check dbClient->queryRow(query);
        return catalog;
    }

}