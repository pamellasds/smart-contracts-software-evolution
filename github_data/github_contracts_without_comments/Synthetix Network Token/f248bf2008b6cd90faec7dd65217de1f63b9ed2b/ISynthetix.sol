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

    

    function balanceof(address account) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function transferfrom(address from, address to, uint value) public returns (bool);

    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        public
        view
        returns (uint);

    function exchange(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey) external returns (uint);

    function issuesynths(uint amount) external;

    function issuemaxsynths() external;

    function burnsynths(uint amount) external;

    function collateralisationratio(address issuer) public view returns (uint);

    function totalissuedsynths(bytes32 currencykey) public view returns (uint);

    function totalissuedsynthsexcludeethercollateral(bytes32 currencykey) public view returns (uint);

    function getsynthbyaddress(address synth) external view returns (bytes32);

    function debtbalanceof(address issuer, bytes32 currencykey) public view returns (uint);

    function remainingissuablesynths(address issuer) public view returns (uint, uint);

    function emitsynthexchange(
        address account,
        bytes32 fromcurrencykey,
        uint fromamount,
        bytes32 tocurrencykey,
        uint toamount,
        address toaddress
    ) external;
}
