pragma solidity >=0.4.24;


interface iexchanger {
    
    function calculateamountaftersettlement(
        address from,
        bytes32 currencykey,
        uint amount,
        uint refunded
    ) external view returns (uint amountaftersettlement);

    function issynthrateinvalid(bytes32 currencykey) external view returns (bool);

    function maxsecsleftinwaitingperiod(address account, bytes32 currencykey) external view returns (uint);

    function settlementowing(address account, bytes32 currencykey)
        external
        view
        returns (
            uint reclaimamount,
            uint rebateamount,
            uint numentries
        );

    function haswaitingperiodorsettlementowing(address account, bytes32 currencykey) external view returns (bool);

    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey)
        external
        view
        returns (uint exchangefeerate);

    function getamountsforexchange(
        uint sourceamount,
        bytes32 sourcecurrencykey,
        bytes32 destinationcurrencykey
    )
        external
        view
        returns (
            uint amountreceived,
            uint fee,
            uint exchangefeerate
        );

    function pricedeviationthresholdfactor() external view returns (uint);

    function waitingperiodsecs() external view returns (uint);

    
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

    function settle(address from, bytes32 currencykey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numentries
        );

    function suspendsynthwithinvalidrate(bytes32 currencykey) external;
}
