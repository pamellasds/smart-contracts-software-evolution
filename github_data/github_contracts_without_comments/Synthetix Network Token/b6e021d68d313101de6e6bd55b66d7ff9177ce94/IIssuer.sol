pragma solidity >=0.4.24;

import ;


interface iissuer {
    
    function anysynthorsnxrateisstale() external view returns (bool anyratestale);

    function availablecurrencykeys() external view returns (bytes32[] memory);

    function availablesynthcount() external view returns (uint);

    function availablesynths(uint index) external view returns (isynth);

    function canburnsynths(address account) external view returns (bool);

    function collateral(address account) external view returns (uint);

    function collateralisationratio(address issuer) external view returns (uint);

    function collateralisationratioandanyratesstale(address _issuer)
        external
        view
        returns (uint cratio, bool anyrateisstale);

    function debtbalanceof(address issuer, bytes32 currencykey) external view returns (uint debtbalance);

    function lastissueevent(address account) external view returns (uint);

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

    function totalissuedsynths(bytes32 currencykey, bool excludeethercollateral) external view returns (uint);

    function transferablesynthetixandanyrateisstale(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyrateisstale);

    
    function issuesynths(address from, uint amount) external;

    function issuesynthsonbehalf(
        address issuefor,
        address from,
        uint amount
    ) external;

    function issuemaxsynths(address from) external;

    function issuemaxsynthsonbehalf(address issuefor, address from) external;

    function burnsynths(address from, uint amount) external;

    function burnsynthsonbehalf(
        address burnforaddress,
        address from,
        uint amount
    ) external;

    function burnsynthstotarget(address from) external;

    function burnsynthstotargetonbehalf(address burnforaddress, address from) external;

    function liquidatedelinquentaccount(
        address account,
        uint susdamount,
        address liquidator
    ) external returns (uint totalredeemed, uint amounttoliquidate);
}
