pragma solidity ^0.4.4;

contract migrations {
    address public owner;
    uint public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function migrations() {
        owner = msg.sender;
    }

    function setcompleted(uint completed) restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) restricted {
        migrations upgraded = migrations(new_address);
        upgraded.setcompleted(last_completed_migration);
    }
}
