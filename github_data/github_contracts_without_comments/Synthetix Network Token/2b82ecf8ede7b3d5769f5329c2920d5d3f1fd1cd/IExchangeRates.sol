pragma solidity 0.4.25;


interface iexchangerates {
    function effectivevalue(bytes4 sourcecurrencykey, uint sourceamount, bytes4 destinationcurrencykey) public view returns (uint);

    function rateforcurrency(bytes4 currencykey) public view returns (uint);

    function anyrateisstale(bytes4[] currencykeys) external view returns (bool);

    function rateisstale(bytes4 currencykey) external view returns (bool);
}