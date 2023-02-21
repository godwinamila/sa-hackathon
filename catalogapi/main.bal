import ballerina/io;
import ballerina/http;


type Catalog record {
        int item_id;
        string description;
        decimal unit_price;  
};


service / on new http:Listener(9090) {

    function init() returns error? {
        io:println("Init Catalog service!");
    }

    resource function get catalog() returns Catalog[]|error {
        io:println("Execute get all catalog API.");
        Catalog[] catalogarr = [];
        catalogarr.push({"item_id" : 1, "description" : "Test1", "unit_price" : 120});
        return catalogarr;
    }

    resource function get catalog/[string catalogid]() returns Catalog|error {
        io:println("Execute get catalog API for ", catalogid);
        return {"item_id" : 1, "description" : "Test1", "unit_price" : 120};
    }

    resource function post countries(@http:Payload Catalog catalog)
                                    returns Catalog|CatalogCodesError {
        return catalog;
    }

    resource function put countries(@http:Payload Catalog catalog)
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