pragma solidity >=0.4.24;

import ;


interface isynthetix {
    
    function anysynthorsnxrateisinvalid() external view returns (bool anyrateinvalid);

    function availablecurrencykeys() external view returns (bytes32[] memory);

    function availablesynthcount() external view returns (uint);

    function availablesynths(uint index) external view returns (isynth);

    function collateral(address account) external view returns (uint);

    function collateralisationratio(address issuer) external view returns (uint);

    function debtbalanceof(address issuer, bytes32 currencykey) external view returns (uint);

    function iswaitingperiod(bytes32 currencykey) external view returns (bool);

    function maxissuablesynths(address issuer) external view returns (uint maxissuable);

    function remainingissuablesynths(address issuer)
        external
        view
        returns (
            uint maxissuable,
            uint alreadyissued,
            uint totalsystemdebt
        );

    function synths(bytes32 currencykey) external view returns (isynth);

    function synthsbyaddress(address synthaddress) external view returns (bytes32);

    function totalissuedsynths(bytes32 currencykey) external view returns (uint);

    function totalissuedsynthsexcludeethercollateral(bytes32 currencykey) external view returns (uint);

    function transferablesynthetix(address account) external view returns (uint transferable);

    
    function burnsynths(uint amount) external;

    function burnsynthsonbehalf(address burnforaddress, uint amount) external;

    function burnsynthstotarget() external;

    function burnsynthstotargetonbehalf(address burnforaddress) external;

    function exchange(
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external returns (uint amountreceived);

    function exchangeonbehalf(
        address exchangeforaddress,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey
    ) external returns (uint amountreceived);

    function issuemaxsynths() external;

    function issuemaxsynthsonbehalf(address issueforaddress) external;

    function issuesynths(uint amount) external;

    function issuesynthsonbehalf(address issueforaddress, uint amount) external;

    function mint() external returns (bool);

    function settle(bytes32 currencykey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numentries
        );

    function liquidatedelinquentaccount(address account, uint susdamount) external returns (bool);
}
