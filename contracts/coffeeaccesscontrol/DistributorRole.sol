pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";
import "../coffeecore/Ownable.sol";

  /**
  * @title DistributorRole
  * @dev Contract to manage the Role Distributor. 
  */
contract DistributorRole is Ownable{
    using Roles for Roles.Role;

    // Define an  Event Distributor is added
    event DistributorAdded(address indexed account);
    // Define an  Event Distributor is removed
    event DistributorRemoved(address indexed account);

    // Struct 'distributors' is inheriting from 'Roles' library, struct Role
    Roles.Role private distributors;

    // The address that deploys this contract is the 1st Distributor
    constructor() public {
        _addDistributor(msg.sender);
    }

    // Modifier that checks to see if msg.sender has the appropriate role
    modifier onlyDistributor() {
        require(isDistributor(msg.sender), "Caller is not a distributor.");
        _;
    }

    // Function 'isDistributor' to check this role
    function isDistributor(address account) public view returns (bool) {
        return distributors.has(account);
    }

    // Function 'addDistributor' that adds this role
    function addDistributor(address account) public  onlyOwner{
        _addDistributor(account);
    }

    // Function 'renounceDistributor' to renounce this role
    function renounceDistributor() public onlyOwner{
        _removeDistributor(msg.sender);
    }

     // Internal function '_addDistributor' to add this role, called by 'addDistributor'
    function _addDistributor(address account) internal {
        distributors.add(account);
        emit DistributorAdded(account);
    }

    // Internal function '_removeDistributor' to remove this role, called by 'removeDistributor'
    function _removeDistributor(address account) internal {
        distributors.remove(account);
        emit DistributorRemoved(account);
    }
}