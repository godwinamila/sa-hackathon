import ballerina/io;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;



type CartItem record {
        int cart_id;
        int item_id;
        int quantity;
        decimal unit_price;
        decimal total;
        string user_name;
};

type CartItemDetails record {
        int cart_id;
        int item_id;
        int quantity;
        decimal unit_price;
        decimal total;
};

type CardDetails record {
        int item_id;
        string name;
        string card_number;
        string expiration;
        string cvv;
        int cart_id;
        // int quantity;
        // decimal unit_price;
        // decimal total;
};


configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;

int PORT = 3306;
string DATABASE = "godwin_db";

service / on new http:Listener(9000) {

    function init() returns error? {
        io:println("Init Favourite service!");
    }    


    resource function get cartitem() returns CartItemDetails[]|error {
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE, connectionPool={maxOpenConnections: 3});

        io:println("Invoke cart item create resource");

        sql:ParameterizedQuery querySelectCart = `select cart_items.item_id, catalog.title, cart_items.quantity, cart_items.unit_price , cart_items.quantity * cart_items.unit_price as total  from cart,cart_items,catalog  where cart.user_name = 'godwin' and cart_items.item_id  =catalog.item_id  and cart.status ='P' and cart.cart_id =cart_items.cart_id`;
        stream<CartItemDetails, sql:Error?> resultStream = dbClient->query(querySelectCart);
        CartItemDetails[] cartItems = [];
        check from CartItemDetails item in resultStream 
            do {
                    cartItems.push(item);
            };
        return cartItems;        
    }

    resource function post cartitem(@http:Payload CartItem cartitem) returns http:Ok|http:BadRequest|error {
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE, connectionPool={maxOpenConnections: 3});

        io:println("Invoke cart item create resource");

        sql:ParameterizedQuery querySelectCart = `SELECT * FROM cart WHERE user_name=${cartitem.user_name} AND status='P'`;
        stream<CartItem, sql:Error?> resultStream = dbClient->query(querySelectCart);
        boolean update = false;
        int cart_id = 0;
        check from CartItem item in resultStream 
            do {
                    io:println("Cart exist " , item.cart_id);
                    cart_id = item.cart_id;
                    io:println("Cart exist cart_id " , cart_id);
                    update=true;
            };

        if(update == false){
            io:println("INSERT INTO cart");
            sql:ParameterizedQuery queryCartInsert = `INSERT INTO cart(user_name, status)VALUES (${cartitem.user_name}, 'P')`;
            sql:ExecutionResult result = check dbClient->execute(queryCartInsert);
            int|string? lastInsertId = result.lastInsertId;
            if lastInsertId is int {
                cart_id = lastInsertId;
            } else {
                return error("Unable to obtain last insert ID");
            }
        }

        
        if(cartitem.quantity == 0){
            io:println("DELETE FROM cart_items");
            sql:ParameterizedQuery query = `DELETE FROM cart_items where item_id=${cartitem.item_id} AND cart_id=${cart_id} `;
            sql:ExecutionResult result = check dbClient->execute(query); 
            http:Ok response = {body: {status: "ok"}};
            return response;
        }
        io:println("Checking cart_items cartitem.item_id : " ,cartitem.item_id);
        io:println("Checking cart_items cart_id : " ,cart_id);
        sql:ParameterizedQuery querySelectCartItems = `SELECT * FROM cart_items WHERE item_id=${cartitem.item_id} AND cart_id=${cart_id}`;
        stream<CartItem, sql:Error?> resultStream1 = dbClient->query(querySelectCartItems);
        boolean cartupdate = false;
        check from CartItem cartItem in resultStream1 
            do {
                    io:println("cart_items exist");
                    decimal total = cartitem.quantity * cartitem.unit_price;
                    sql:ParameterizedQuery query1 = `UPDATE cart_items SET quantity=quantity +${cartitem.quantity}, unit_price=${cartitem.unit_price},  total= ${total} WHERE item_id=${cartitem.item_id} AND cart_id=${cart_id}`;
                    sql:ExecutionResult result = check dbClient->execute(query1);        
                    cartupdate = true;
            };
                
        if(cartupdate){
            http:Ok response = {body: {status: "ok"}};
            return response;
        }
        io:println("INSERT INTO cart_items ");
        sql:ParameterizedQuery insertCartItems = `INSERT INTO cart_items(item_id, quantity, unit_price, total, user_name, cart_id)VALUES (${cartitem.item_id}, ${cartitem.quantity}, ${cartitem.unit_price}, ${cartitem.total}, ${cartitem.user_name},${cart_id})`;
        sql:ExecutionResult result = check dbClient->execute(insertCartItems);
        
        http:Ok response = {body: {status: "ok"}};
    
        return response;
    }


    resource function post checkout(@http:Payload CardDetails carddetails) returns http:Ok|http:BadRequest|error {
        io:println("Invoke checkout resource");
        final mysql:Client dbClient = check new(host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE, connectionPool={maxOpenConnections: 3});

        sql:ParameterizedQuery insertQueries = `INSERT INTO card_details(name, card_number, expiration, cvv, cart_id)VALUES (${carddetails.name}, ${carddetails.card_number}, ${carddetails.expiration}, ${carddetails.cvv}, ${carddetails.cart_id})`;
        sql:ExecutionResult result = check dbClient->execute(insertQueries);
        
        sql:ParameterizedQuery updateQuery = `UPDATE cart SET status='C' WHERE cart_id=${carddetails.cart_id}`;
        result = check dbClient->execute(updateQuery);

        http:Ok response = {body: {status: "ok"}};        

        return response;
        
    }

        
}

