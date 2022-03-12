pragma solidity 0.4.25;

contract migrations {
    address public owner;
    uint public last_completed_migration;

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function setcompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {
        migrations upgraded = migrations(new_address);
        upgraded.setcompleted(last_completed_migration);
    }
}
