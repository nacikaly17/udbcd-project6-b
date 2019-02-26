pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";
import "../coffeecore/Ownable.sol";

  /**
  * @title RetailerRole
  * @dev Contract to manage the Role Retailer. 
  */
contract RetailerRole is Ownable{

    using Roles for Roles.Role;

    // Define an  Event Retailer is added
    event RetailerAdded(address indexed account);
    // Define an  Event Retailer is removed
    event RetailerRemoved(address indexed account);
    
    // Struct 'retailers' is inheriting from 'Roles' library, struct Role
    Roles.Role private retailers;

    // The address that deploys this contract is the 1st retailer
    constructor() public {
        _addRetailer(msg.sender);
    }

    // Modifier that checks to see if msg.sender has the appropriate role
    modifier onlyRetailer() {
        require(isRetailer(msg.sender), "Caller is not a retailer.");
        _;
    }

    // Function 'isRetailer' to check this role
    function isRetailer(address account) public view returns (bool) {
        return retailers.has(account);
    }

    // Function 'addRetailer' that adds this role
    function addRetailer(address account) public onlyOwner {
        _addRetailer(account);
    }

    // Function 'renounceRetailer' to renounce this role
    function renounceRetailer() public onlyOwner{
        _removeRetailer(msg.sender);
    }

    // Internal function '_addRetailer' to add this role, called by 'addRetailer'
    function _addRetailer(address account) internal {
        retailers.add(account);
        emit RetailerAdded(account);
    }

     // Internal function '_removeRetailer' to remove this role, called by 'removeRetailer'
    function _removeRetailer(address account) internal {
        retailers.remove(account);
        emit RetailerRemoved(account);
      
    }
}