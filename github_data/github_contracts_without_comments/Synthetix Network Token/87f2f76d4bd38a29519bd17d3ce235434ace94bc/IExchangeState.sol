pragma solidity 0.4.25;


interface iexchangestate {
    function appendexchangeentry(
        address account,
        bytes32 src,
        uint amount,
        bytes32 dest,
        uint amountreceived,
        uint exchangefeerate,
        uint timestamp,
        uint roundidforsrc,
        uint roundidfordest
    ) external;

    function removeentries(address account, bytes32 currencykey) external;

    function getlengthofentries(address account, bytes32 currencykey) external view returns (uint);

    function getentryat(address account, bytes32 currencykey, uint index)
        external
        view
        returns (
            bytes32 src,
            uint amount,
            bytes32 dest,
            uint amountreceived,
            uint exchangefeerate,
            uint timestamp,
            uint roundidforsrc,
            uint roundidfordest
        );

    function getmaxtimestamp(address account, bytes32 currencykey) external view returns (uint);
}
