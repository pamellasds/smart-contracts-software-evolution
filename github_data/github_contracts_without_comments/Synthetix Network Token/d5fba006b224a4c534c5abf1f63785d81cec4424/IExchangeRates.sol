pragma solidity 0.4.25;



interface iexchangerates {
    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        external
        view
        returns (uint);

    function rateforcurrency(bytes32 currencykey) external view returns (uint);

    function ratesforcurrencies(bytes32[] currencykeys) external view returns (uint[] memory);

    function rateisstale(bytes32 currencykey) external view returns (bool);

    function rateisfrozen(bytes32 currencykey) external view returns (bool);

    function anyrateisstale(bytes32[] currencykeys) external view returns (bool);

    function getcurrentroundid(bytes32 currencykey) external view returns (uint);

    function effectivevalueatround(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        uint roundidforsrc,
        uint roundidfordest
    ) external view returns (uint);

    function getlastroundidbeforeelapsedsecs(
        bytes32 currencykey,
        uint startingroundid,
        uint startingtimestamp,
        uint timediff
    ) external view returns (uint);

    function ratesandstaleforcurrencies(bytes32[] currencykeys) external view returns (uint[], bool);

    function rateandtimestampatround(bytes32 currencykey, uint roundid) external view returns (uint rate, uint time);
}
