pragma solidity ^0.5.16;



contract ifeepool {
    address public fee_address;
    uint public exchangefeerate;

    function amountreceivedfromexchange(uint value) external view returns (uint);

    function amountreceivedfromtransfer(uint value) external view returns (uint);

    function recordfeepaid(uint susdamount) external;

    function appendaccountissuancerecord(
        address account,
        uint lockedamount,
        uint debtentryindex
    ) external;

    function setrewardstodistribute(uint amount) external;
}
