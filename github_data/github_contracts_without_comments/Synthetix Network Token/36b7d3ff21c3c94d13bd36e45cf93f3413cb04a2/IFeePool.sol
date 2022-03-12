pragma solidity 0.4.25;

contract ifeepool {
    address public fee_address;
    uint public exchangefeerate;
    function amountreceivedfromexchange(uint value) external view returns (uint);
    function amountreceivedfromtransfer(uint value) external view returns (uint);
    function feepaid(bytes4 currencykey, uint amount) external;
    function appendaccountissuancerecord(address account, uint lockedamount, uint debtentryindex) external;
    function rewardsminted(uint amount) external;
    function transferfeeincurred(uint value) public view returns (uint);
}
