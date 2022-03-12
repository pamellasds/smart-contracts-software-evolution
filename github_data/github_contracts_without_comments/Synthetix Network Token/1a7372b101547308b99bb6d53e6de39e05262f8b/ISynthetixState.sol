pragma solidity >=0.4.24;


interface isynthetixstate {
    
    function debtledger(uint index) external view returns (uint);

    function issuancedata(address account) external view returns (uint initialdebtownership, uint debtentryindex);

    function debtledgerlength() external view returns (uint);

    function hasissued(address account) external view returns (bool);

    function lastdebtledgerentry() external view returns (uint);

    
    function incrementtotalissuercount() external;

    function decrementtotalissuercount() external;

    function setcurrentissuancedata(address account, uint initialdebtownership) external;

    function appenddebtledgervalue(uint value) external;

    function clearissuancedata(address account) external;
}
