pragma solidity ^0.4.24;


interface stablecoineventinterface {
    
    event transfer(address indexed from, address indexed to, uint256 value);

    
    event ownershiptransferred(
        address indexed oldowner,
        address indexed newowner
    );

    
    event pause();
    event unpause();

    
    event supplyincreased(address indexed to, uint256 value);
    event supplydecreased(address indexed from, uint256 value);
    event supplycontrollerset(
        address indexed oldsupplycontroller,
        address indexed newsupplycontroller
    );

    
    event upgraded(address implementation);
}
