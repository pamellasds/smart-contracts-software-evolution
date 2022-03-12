pragma solidity ^0.4.24;



contract migrations {
    uint public last_completed_migration;

    function setcompleted(uint completed) public {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public {
        migrations upgraded = migrations(new_address);
        upgraded.setcompleted(last_completed_migration);
    }
}
