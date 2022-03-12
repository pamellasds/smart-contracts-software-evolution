pragma solidity >=0.4.24;

import ;
import ;

interface ibinaryoptionmarket {
    

    enum phase { bidding, trading, maturity, expiry }
    enum side { long, short }

    

    function options() external view returns (ibinaryoption long, ibinaryoption short);
    function prices() external view returns (uint long, uint short);
    function times() external view returns (uint biddingend, uint maturity, uint destructino);
    function oracledetails() external view returns (bytes32 key, uint strikeprice, uint finalprice);
    function fees() external view returns (uint poolfee, uint creatorfee, uint refundfee);
    function creatorlimits() external view returns (uint capitalrequirement, uint skewlimit);

    function deposited() external view returns (uint);
    function creator() external view returns (address);
    function resolved() external view returns (bool);
    function refundsenabled() external view returns (bool);

    function phase() external view returns (phase);
    function oraclepriceandtimestamp() external view returns (uint price, uint updatedat);
    function canresolve() external view returns (bool);
    function result() external view returns (side);

    function pricesafterbidorrefund(side side, uint value, bool refund) external view returns (uint long, uint short);
    function bidorrefundforprice(side bidside, side priceside, uint price, bool refund) external view returns (uint);

    function bidsof(address account) external view returns (uint long, uint short);
    function totalbids() external view returns (uint long, uint short);
    function claimablebalancesof(address account) external view returns (uint long, uint short);
    function totalclaimablesupplies() external view returns (uint long, uint short);
    function balancesof(address account) external view returns (uint long, uint short);
    function totalsupplies() external view returns (uint long, uint short);
    function exercisabledeposits() external view returns (uint);

    

    function bid(side side, uint value) external;
    function refund(side side, uint value) external returns (uint refundminusfee);

    function claimoptions() external returns (uint longclaimed, uint shortclaimed);
    function exerciseoptions() external returns (uint);
}
