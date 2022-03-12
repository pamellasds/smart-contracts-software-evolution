pragma solidity ^0.5.16;


interface iexchanger {
    function maxsecsleftinwaitingperiod(address account, bytes32 currencykey) external view returns (uint);

    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) external view returns (uint);

    function settlementowing(address account, bytes32 currencykey)
        external
        view
        returns (
            uint reclaimamount,
            uint rebateamount,
            uint numentries
        );

    function settle(address from, bytes32 currencykey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numentries
        );

    function exchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    ) external returns (uint amountreceived);

    function exchangeonbehalf(
        address exchangeforaddress,
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external returns (uint amountreceived);

    function calculateamountaftersettlement(
        address from,
        bytes32 currencykey,
        uint amount,
        uint refunded
    ) external view returns (uint amountaftersettlement);
}
