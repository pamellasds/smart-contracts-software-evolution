pragma solidity >=0.4.24;


interface isystemsettings {
    
    function pricedeviationthresholdfactor() external view returns (uint);

    function waitingperiodsecs() external view returns (uint);

    function issuanceratio() external view returns (uint);

    function feeperiodduration() external view returns (uint);

    function targetthreshold() external view returns (uint);

    function liquidationdelay() external view returns (uint);

    function liquidationratio() external view returns (uint);

    function liquidationpenalty() external view returns (uint);

    function ratestaleperiod() external view returns (uint);

    function exchangefeerate(bytes32 currencykey) external view returns (uint);

    function minimumstaketime() external view returns (uint);
}
