pragma solidity ^0.5.16;

import ;


interface isynthetix {
    
    function synths(bytes32 currencykey) external view returns (isynth);

    function synthsbyaddress(address synthaddress) external view returns (bytes32);

    function collateralisationratio(address issuer) external view returns (uint);

    function totalissuedsynths(bytes32 currencykey) external view returns (uint);

    function totalissuedsynthsexcludeethercollateral(bytes32 currencykey) external view returns (uint);

    function debtbalanceof(address issuer, bytes32 currencykey) external view returns (uint);

    function debtbalanceofandtotaldebt(address issuer, bytes32 currencykey)
        external
        view
        returns (uint debtbalance, uint totalsystemvalue);

    function remainingissuablesynths(address issuer)
        external
        view
        returns (
            uint maxissuable,
            uint alreadyissued,
            uint totalsystemdebt
        );

    function maxissuablesynths(address issuer) external view returns (uint maxissuable);

    function iswaitingperiod(bytes32 currencykey) external view returns (bool);

    
    function exchange(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external returns (uint amountreceived);

    function issuesynths(uint amount) external;

    function issuemaxsynths() external;

    function burnsynths(uint amount) external;

    function burnsynthstotarget() external;

    function settle(bytes32 currencykey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numentries
        );
}
