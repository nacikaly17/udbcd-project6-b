pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";
import "../coffeecore/Ownable.sol";

  /**
  * @title FarmerRole
  * @dev Contract to manage the Role Farmer. 
  */
contract FarmerRole is Ownable{
    using Roles for Roles.Role;

    // Define an  Event farmer is added
    event FarmerAdded(address indexed account);
    // Define an  Event farmer is removed
    event FarmerRemoved(address indexed account);

    // Struct 'farmers' is inheriting from 'Roles' library, struct Role
    Roles.Role private farmers;

    // The address that deploys this contract is the 1st farmer
    constructor() public {
        _addFarmer(msg.sender);
    }

    // Modifier that checks to see if msg.sender has the appropriate role
    modifier onlyFarmer() {
        require(isFarmer(msg.sender), "Caller is not a farmer.");
        _;
    }

    // Function 'isFarmer' to check this role
    function isFarmer(address account) public view returns (bool) {
        return farmers.has(account);
    }

    // Function 'addFarmer' that adds this role
    function addFarmer(address account) public  onlyOwner{
        _addFarmer(account);
    }

    // Function 'renounceFarmer' to renounce this role
    function renounceFarmer() public  onlyOwner{
        _removeFarmer(msg.sender);
    }

    // Internal function '_addFarmer' to add this role, called by 'addFarmer'
    function _addFarmer(address account) internal {
        farmers.add(account);
        emit FarmerAdded(account);
    }

    // Internal function '_removeFarmer' to remove this role, called by 'removeFarmer'
    function _removeFarmer(address account) internal {
        farmers.remove(account);
        emit FarmerRemoved(account);
    }
}