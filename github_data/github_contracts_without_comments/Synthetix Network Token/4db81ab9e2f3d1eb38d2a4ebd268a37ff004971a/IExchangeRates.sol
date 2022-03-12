pragma solidity 0.4.25;


interface iexchangerates {
    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey) public view returns (uint);

    function rateforcurrency(bytes32 currencykey) public view returns (uint);

    function anyrateisstale(bytes32[] currencykeys) external view returns (bool);

    function rateisstale(bytes32 currencykey) external view returns (bool);
}
