pragma solidity >=0.4.24 <0.6.0;

// Import the library 'Roles'

import "../coffeeaccesscontrol/FarmerRole.sol";
import "../coffeeaccesscontrol/DistributorRole.sol";
import "../coffeeaccesscontrol/RetailerRole.sol";
import "../coffeeaccesscontrol/ConsumerRole.sol";
import "../coffeecore/Ownable.sol";


    /**
    * @title SupplyChain
    * @dev Contract for managing fair trade coffee supply chain.
    */
contract SupplyChain is FarmerRole, DistributorRole, RetailerRole, ConsumerRole {

    address private _owner;

    // variable : 'upc' for Universal Product Code (UPC)
    uint  upc;

    // variable :  'sku' for Stock Keeping Unit (SKU)
    uint  sku;

    // variable public mapping : 'items' that maps the UPC to an Item.
    mapping (uint => Item) items;

    // variable public mapping :  'itemsHistory' that maps the UPC to 
    // an array of TxHash, 
    // that track its journey through the supply chain -- to be sent from DApp.
    mapping (uint => string[]) itemsHistory;
    
    //  enum  : 'State' with the following values:
    enum State 
    { 
        Harvested,  // 0
        Processed,  // 1
        Packed,     // 2
        ForSale,    // 3
        Sold,       // 4
        Shipped,    // 5
        Received,   // 6
        Purchased   // 7
    }
            
    State constant defaultState = State.Harvested;

    // Struct : 'Item' with the following fields:
    struct Item {
        uint    sku;  // Stock Keeping Unit (SKU)
        uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
        address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
        address originFarmerID; // Metamask-Ethereum address of the Farmer
        string  originFarmName; // Farmer Name
        string  originFarmInformation;  // Farmer Information
        string  originFarmLatitude; // Farm Latitude
        string  originFarmLongitude;  // Farm Longitude
        uint    productID;  // Product ID potentially a combination of upc + sku
        string  productNotes; // Product Notes
        uint    productPrice; // Product Price
        State   itemState;  // Product State as represented in the enum above
        address distributorID;  // Metamask-Ethereum address of the Distributor
        address retailerID; // Metamask-Ethereum address of the Retailer
        address consumerID; // Metamask-Ethereum address of the Consumer
    }

    // 8 events : with the same 8 state values and accept 'upc' as input argument
    event Harvested(uint upc);
    event Processed(uint upc);
    event Packed(uint upc);
    event ForSale(uint upc);
    event Sold(uint upc);
    event Shipped(uint upc);
    event Received(uint upc);
    event Purchased(uint upc);

    // modifier 'paidEnough' checks if the paid amount is sufficient 
    // to cover the price
    modifier paidEnough(uint _price) { 
        require(msg.value >= _price, "Paid amount is not ufficient."); 
        _;
    }
    
    // modifier 'checkValue' checks the price and refunds the remaining balance
    modifier checkValue(uint _upc) {
        _;
        uint _price = items[_upc].productPrice;
        uint amountToReturn = msg.value - _price;
        items[_upc].distributorID.transfer(amountToReturn);
    }

    // modifier 'harvested' checks if an item.state of a upc is Harvested
    modifier harvested(uint _upc) {
        require(items[_upc].itemState == State.Harvested, "Item is not Harvested");
        _;
    }

    // modifier 'processed' checks if an item.state of a upc is Processed
    modifier processed(uint _upc) {
        require(items[_upc].itemState == State.Processed, "Item is not Processed");
        _;
    }
    
    // modifier 'packed' checks if an item.state of a upc is Packed
    modifier packed(uint _upc) {
        require(items[_upc].itemState == State.Packed, "Item is not Packed");
        _;
    }

    // modifier 'forSale' checks if an item.state of a upc is ForSale
    modifier forSale(uint _upc) {
        require(items[_upc].itemState == State.ForSale, "Item is not ForSale");
        _;
    }

    // modifier 'sold' checks if an item.state of a upc is Sold
    modifier sold(uint _upc) {
        require(items[_upc].itemState == State.Sold, "Item is not Sold");
        _;
    }
    
    // modifier 'shipped' checks if an item.state of a upc is Shipped
    modifier shipped(uint _upc) {
        require(items[_upc].itemState == State.Shipped, "Item is not Shipped");
        _;
    }

    // modifier 'received' checks if an item.state of a upc is Received
    modifier received(uint _upc) {
        require(items[_upc].itemState == State.Received, "Item is not Received");
        _;
    }

    // modifier 'purchased' checks if an item.state of a upc is Purchased
    modifier purchased(uint _upc) {
        require(items[_upc].itemState == State.Purchased, "Item is not Purchased");
        _;
    }

    // constructor : set same initial values for the contract 
    // set 'owner' to the address that instantiated the contract
    // set 'sku' to 1
    // set 'upc' to 1
    constructor() public payable {
        _owner = msg.sender;
        sku = 1;
        upc = 1;
    }

    // function 'kill' if required
    function kill() public {
        if (msg.sender == _owner) {
            selfdestruct(_owner);
        }
    }

    // function 'harvestItem' that allows a farmer to mark an item 'Harvested'
    function harvestItem(
        uint _upc, 
        address _originFarmerID, 
        string memory _originFarmName, 
        string memory _originFarmInformation, 
        string memory  _originFarmLatitude, 
        string memory  _originFarmLongitude, 
        string memory  _productNotes) 
        public
        onlyFarmer() 
    {
        // Add the new item as part of Harvest
        items[_upc] = Item({
            sku: sku,
            upc: _upc,
            ownerID: _originFarmerID,
            originFarmerID: _originFarmerID,
            originFarmName: _originFarmName,
            originFarmInformation : _originFarmInformation,
            originFarmLatitude: _originFarmLatitude,
            originFarmLongitude: _originFarmLongitude,
            productNotes: _productNotes,
            itemState: defaultState,
            productID: sku + _upc,
            // item attributes not set yet
            productPrice: 0,
            distributorID: 0,
            retailerID: 0,
            consumerID: 0
            });
        // Add itemHistory
        itemsHistory[_upc] = ["Item is Harvested"];
        // Increment sku
        sku = sku + 1;
        // Emit the appropriate event
        emit Harvested(_upc); 
    }

    // function 'processtItem' that allows a farmer to mark an item 'Processed'
    function processItem(uint _upc) public 
        harvested(_upc)                     // check if the item is harvested
        onlyFarmer() 
        {
        // Update the appropriate fields
        items[_upc].itemState = State.Processed;
        // Emit the appropriate event
        emit Processed(_upc); 
    }

    // function 'packItem' that allows a farmer to mark an item 'Packed'
    function packItem(uint _upc) public
        processed(_upc)                             // check if the item is processed
        onlyFarmer() 
        {
        // Update the appropriate fields - itemState
        items[_upc].itemState = State.Packed;
        // Emit the appropriate event
        emit Packed(_upc); 
    }

    // function 'sellItem' that allows a farmer to mark an item 'ForSale'
    function sellItem(uint _upc, uint _price)  public 
        packed(_upc)                        // check if the item is packed
        onlyFarmer()
        {
        // Update the appropriate fields - productPrice, itemState
        items[_upc].productPrice = _price;
        items[_upc].itemState = State.ForSale;
        // Emit the appropriate event
        emit ForSale(_upc); 
    }

    // function 'buyItem' that allows the disributor to mark an item 'Sold'
    function buyItem(uint _upc) public payable 
        forSale(_upc)                             // check if the item is available for sale, 
        paidEnough(items[_upc].productPrice)      // check if buyer has paid enough
        checkValue( _upc)
        onlyDistributor() 
        {
        // Update the appropriate fields - ownerID, distributorID, itemState
        items[_upc].ownerID = msg.sender;
        items[_upc].distributorID = msg.sender;
        items[_upc].itemState = State.Sold;
        // Transfer money to farmer 
        items[_upc].originFarmerID.transfer(items[_upc].productPrice);
        // emit the appropriate event
        emit Sold(_upc); 
    }

    // function 'shipItem' that allows the distributor to mark an item 'Shipped'
    function shipItem(uint _upc) public 
        sold(_upc)                                  // check if the item is sold
        onlyFarmer()
        {
        // Update the appropriate fields - itemState
        items[_upc].itemState = State.Shipped;
        // Emit the appropriate event
        emit Shipped(_upc); 
    }

    // function 'receiveItem' that allows the retailer to mark an item 'Received'
    function receiveItem(uint _upc) public         
        shipped(_upc)                           // check if the item is shipped
        onlyRetailer()
        {
        // Access Control List enforced by calling Smart Contract / DApp

        // Update the appropriate fields - ownerID, retailerID, itemState
        items[_upc].ownerID = msg.sender;
        items[_upc].retailerID = msg.sender;
        items[_upc].itemState = State.Received;
        // Emit the appropriate event
        emit Received(_upc); 
        
    }

    // function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
    function purchaseItem(uint _upc) public 
        received(_upc)                      // check if the item is received
        onlyConsumer()
        {
        // Access Control List enforced by calling Smart Contract / DApp

        // Update the appropriate fields - ownerID, consumerID, itemState
        items[_upc].ownerID = msg.sender;
        items[_upc].consumerID = msg.sender;
        items[_upc].itemState = State.Purchased;
        // Emit the appropriate event
        emit Purchased(_upc); 
        
    }

    // function 'fetchItemBufferOne' that fetches the data
    function fetchItemBufferOne(uint _upc) public view returns 
        (
        uint    itemSKU,
        uint    itemUPC,
        address ownerID,
        address originFarmerID,
        string  memory originFarmName,
        string  memory originFarmInformation,
        string  memory originFarmLatitude,
        string  memory originFarmLongitude
        ) 
    {
        // return 8 item attributes
        itemSKU = items[_upc].sku;
        itemUPC = items[_upc].upc;
        ownerID = items[_upc].ownerID;
        originFarmerID = items[_upc].originFarmerID;
        originFarmName = items[_upc].originFarmName;
        originFarmInformation = items[_upc].originFarmInformation;
        originFarmLatitude = items[_upc].originFarmLatitude;
        originFarmLongitude = items[_upc].originFarmLongitude;
    }

    // function 'fetchItemBufferTwo' that fetches the data
    function fetchItemBufferTwo(uint _upc) public view returns 
        (
        uint    itemSKU,
        uint    itemUPC,
        uint    productID,
        string  memory productNotes,
        uint    productPrice,
        uint    itemState,
        address distributorID,
        address retailerID,
        address consumerID
        ) 
    {
        // Assign values to the 9 parameters
        itemSKU = items[_upc].sku;
        itemUPC = items[_upc].upc;
        productID = items[_upc].productID;
        productNotes = items[_upc].productNotes;
        productPrice = items[_upc].productPrice;
        itemState = uint(items[_upc].itemState);
        distributorID = items[_upc].distributorID;
        retailerID = items[_upc].retailerID;
        consumerID = items[_upc].consumerID;
    }
}