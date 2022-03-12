pragma solidity 0.4.25;

contract isynthetixstate {
    
    struct issuancedata {
        
        
        
        
        
        uint initialdebtownership;
        
        
        
        uint debtentryindex;
    }

    uint[] public debtledger;
    uint public issuanceratio;
    mapping(address => issuancedata) public issuancedata;

    function debtledgerlength() external view returns (uint);
    function hasissued(address account) external view returns (bool);
    function incrementtotalissuercount() external;
    function decrementtotalissuercount() external;
    function setcurrentissuancedata(address account, uint initialdebtownership) external;
    function lastdebtledgerentry() external view returns (uint);
    function appenddebtledgervalue(uint value) external;
    function clearissuancedata(address account) external;
}
