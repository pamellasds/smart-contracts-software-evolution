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

    function ratesandstaleforcurrencies(bytes32[] currencykeys) external view returns (uint[], bool);
}
