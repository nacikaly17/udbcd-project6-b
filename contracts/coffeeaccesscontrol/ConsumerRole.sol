pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";
import "../coffeecore/Ownable.sol";

  /**
  * @title ConsumerRole
  * @dev Contract to manage the Role Consumer. 
  */
contract ConsumerRole is Ownable {
    using Roles for Roles.Role;
    
    // Define an Event Consumer is added
    event ConsumerAdded(address indexed account);
    // Define an Event Consumer is removed
    event ConsumerRemoved(address indexed account);

    // Struct 'consumers' is inheriting from 'Roles' library, struct Role
    Roles.Role private consumers;

    // The address that deploys this contract is the 1st consumer
    constructor() public {
        _addConsumer(msg.sender);
    }

    // Modifier that checks to see if msg.sender has the appropriate role
    modifier onlyConsumer() {
        require(isConsumer(msg.sender), "Caller is not a consumer.");
        _;
    }

    // Function 'isConsumer' to check this role
    function isConsumer(address account) public view returns (bool) {
        return consumers.has(account);
    }


    // Function 'addConsumer' that adds this role
    function addConsumer(address account) public  onlyOwner{
        _addConsumer(account);
    }

    // Function 'renounceFarmer' to renounce this role
    function renounceConsumer() public onlyOwner{
        _removeConsumer(msg.sender);
    }

    // Internal function '_addConsumer' to add this role, called by 'addConsumer'
    function _addConsumer(address account) internal {
        consumers.add(account);
        emit ConsumerAdded(account);
    }

    // Internal function '_removeConsumer' to remove this role, called by 'removeConsumer'
    function _removeConsumer(address account) internal {
        consumers.remove(account);
        emit ConsumerRemoved(account);
    }
}