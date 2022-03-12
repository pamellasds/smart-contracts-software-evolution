pragma solidity 0.4.25;


interface iexchanger {
    function exchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    ) external returns (uint amountreceived);
}
