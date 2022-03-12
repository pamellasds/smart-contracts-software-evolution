pragma solidity ^0.5.16;


interface ifeepool {
    

    
    function fee_address() external view returns (address);

    function exchangefeerate() external view returns (uint);

    function amountreceivedfromexchange(uint value) external view returns (uint);

    
    function recordfeepaid(uint susdamount) external;

    function appendaccountissuancerecord(
        address account,
        uint lockedamount,
        uint debtentryindex
    ) external;

    function setrewardstodistribute(uint amount) external;
}
