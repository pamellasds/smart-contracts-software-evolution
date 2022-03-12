pragma solidity 0.4.25;


import ;
import ;
import ;
import ;
import ;
import ;


contract isynthetix {
    

    uint public totalsupply;

    mapping(bytes32 => synth) public synths;

    mapping(address => bytes32) public synthsbyaddress;

    

    function balanceof(address account) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function transferfrom(address from, address to, uint value) public returns (bool);

    function exchange(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        external
        returns (uint amountreceived);

    function issuesynths(uint amount) external;

    function issuemaxsynths() external;

    function burnsynths(uint amount) external;

    function burnsynthstotarget() external;

    function settle(bytes32 currencykey) external returns (uint reclaimed, uint refunded, uint numentries);

    function collateralisationratio(address issuer) public view returns (uint);

    function totalissuedsynths(bytes32 currencykey) public view returns (uint);

    function totalissuedsynthsexcludeethercollateral(bytes32 currencykey) public view returns (uint);

    function debtbalanceof(address issuer, bytes32 currencykey) public view returns (uint);

    function debtbalanceofandtotaldebt(address issuer, bytes32 currencykey)
        public
        view
        returns (uint debtbalance, uint totalsystemvalue);

    function remainingissuablesynths(address issuer)
        public
        view
        returns (uint maxissuable, uint alreadyissued, uint totalsystemdebt);

    function maxissuablesynths(address issuer) public view returns (uint maxissuable);

    function iswaitingperiod(bytes32 currencykey) external view returns (bool);

    function emitsynthexchange(
        address account,
        bytes32 fromcurrencykey,
        uint fromamount,
        bytes32 tocurrencykey,
        uint toamount,
        address toaddress
    ) external;

    function emitexchangereclaim(address account, bytes32 currencykey, uint amount) external;

    function emitexchangerebate(address account, bytes32 currencykey, uint amount) external;
}
