pragma solidity >=0.4.24;


interface ifeepool {
    

    
    function fee_address() external view returns (address);

    function feesavailable(address account) external view returns (uint, uint);

    function feeperiodduration() external view returns (uint);

    function isfeesclaimable(address account) external view returns (bool);

    function targetthreshold() external view returns (uint);

    function totalfeesavailable() external view returns (uint);

    function totalrewardsavailable() external view returns (uint);

    
    function claimfees() external returns (bool);

    function claimonbehalf(address claimingforaddress) external returns (bool);

    function closecurrentfeeperiod() external;

    
    function appendaccountissuancerecord(
        address account,
        uint lockedamount,
        uint debtentryindex
    ) external;

    function recordfeepaid(uint susdamount) external;

    function setrewardstodistribute(uint amount) external;
}
