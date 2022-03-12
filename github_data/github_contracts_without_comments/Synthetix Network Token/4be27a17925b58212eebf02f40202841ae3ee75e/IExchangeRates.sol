pragma solidity >=0.4.24;



interface iexchangerates {
    
    struct rateandupdatedtime {
        uint216 rate;
        uint40 time;
    }

    struct inversepricing {
        uint entrypoint;
        uint upperlimit;
        uint lowerlimit;
        bool frozenatupperlimit;
        bool frozenatlowerlimit;
    }

    
    function aggregators(bytes32 currencykey) external view returns (address);

    function aggregatorwarningflags() external view returns (address);

    function anyrateisinvalid(bytes32[] calldata currencykeys) external view returns (bool);

    function canfreezerate(bytes32 currencykey) external view returns (bool);

    function currentroundforrate(bytes32 currencykey) external view returns (uint);

    function currenciesusingaggregator(address aggregator) external view returns (bytes32[] memory);

    function effectivevalue(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external view returns (uint value);

    function effectivevalueandrates(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    )
        external
        view
        returns (
            uint value,
            uint sourcerate,
            uint destinationrate
        );

    function effectivevalueatround(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        uint roundidforsrc,
        uint roundidfordest
    ) external view returns (uint value);

    function getcurrentroundid(bytes32 currencykey) external view returns (uint);

    function getlastroundidbeforeelapsedsecs(
        bytes32 currencykey,
        uint startingroundid,
        uint startingtimestamp,
        uint timediff
    ) external view returns (uint);

    function inversepricing(bytes32 currencykey)
        external
        view
        returns (
            uint entrypoint,
            uint upperlimit,
            uint lowerlimit,
            bool frozenatupperlimit,
            bool frozenatlowerlimit
        );

    function lastrateupdatetimes(bytes32 currencykey) external view returns (uint256);

    function oracle() external view returns (address);

    function rateandtimestampatround(bytes32 currencykey, uint roundid) external view returns (uint rate, uint time);

    function rateandupdatedtime(bytes32 currencykey) external view returns (uint rate, uint time);

    function rateforcurrency(bytes32 currencykey) external view returns (uint);

    function rateisflagged(bytes32 currencykey) external view returns (bool);

    function rateisfrozen(bytes32 currencykey) external view returns (bool);

    function rateisinvalid(bytes32 currencykey) external view returns (bool);

    function rateisstale(bytes32 currencykey) external view returns (bool);

    function ratestaleperiod() external view returns (uint);

    function ratesandupdatedtimeforcurrencylastnrounds(bytes32 currencykey, uint numrounds)
        external
        view
        returns (uint[] memory rates, uint[] memory times);

    function ratesandinvalidforcurrencies(bytes32[] calldata currencykeys)
        external
        view
        returns (uint[] memory rates, bool anyrateinvalid);

    function ratesforcurrencies(bytes32[] calldata currencykeys) external view returns (uint[] memory);

    
    function freezerate(bytes32 currencykey) external;
}
