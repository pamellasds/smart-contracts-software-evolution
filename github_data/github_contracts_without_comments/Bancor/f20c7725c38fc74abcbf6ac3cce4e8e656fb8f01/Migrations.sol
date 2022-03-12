pragma solidity 0.4.26;

contract migrations {
    address public owner;
    uint256 public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setcompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {
        migrations upgraded = migrations(new_address);
        upgraded.setcompleted(last_completed_migration);
    }
}
