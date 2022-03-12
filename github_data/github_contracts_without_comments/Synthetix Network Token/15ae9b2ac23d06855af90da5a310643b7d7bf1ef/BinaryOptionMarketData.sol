pragma solidity ^0.5.16;
pragma experimental abiencoderv2;


import ;
import ;
import ;


contract binaryoptionmarketdata {
    struct optionvalues {
        uint long;
        uint short;
    }

    struct deposits {
        uint deposited;
        uint exercisabledeposits;
    }

    struct resolution {
        bool resolved;
        bool canresolve;
    }

    struct oraclepriceandtimestamp {
        uint price;
        uint updatedat;
    }

    
    struct marketparameters {
        address creator;
        binaryoptionmarket.options options;
        binaryoptionmarket.times times;
        binaryoptionmarket.oracledetails oracledetails;
        binaryoptionmarketmanager.fees fees;
        binaryoptionmarketmanager.creatorlimits creatorlimits;
    }

    struct marketdata {
        oraclepriceandtimestamp oraclepriceandtimestamp;
        binaryoptionmarket.prices prices;
        deposits deposits;
        resolution resolution;
        binaryoptionmarket.phase phase;
        binaryoptionmarket.side result;
        optionvalues totalbids;
        optionvalues totalclaimablesupplies;
        optionvalues totalsupplies;
    }

    struct accountdata {
        optionvalues bids;
        optionvalues claimable;
        optionvalues balances;
    }

    function getmarketparameters(binaryoptionmarket market) public view returns (marketparameters memory) {
        (binaryoption long, binaryoption short) = market.options();
        (uint biddingenddate, uint maturitydate, uint expirydate) = market.times();
        (bytes32 key, uint strikeprice, uint finalprice) = market.oracledetails();
        (uint poolfee, uint creatorfee, uint refundfee) = market.fees();

        marketparameters memory data = marketparameters(
            market.creator(),
            binaryoptionmarket.options(long, short),
            binaryoptionmarket.times(biddingenddate, maturitydate, expirydate),
            binaryoptionmarket.oracledetails(key, strikeprice, finalprice),
            binaryoptionmarketmanager.fees(poolfee, creatorfee, refundfee),
            binaryoptionmarketmanager.creatorlimits(0, 0)
        );

        
        (uint capitalrequirement, uint skewlimit) = market.creatorlimits();
        data.creatorlimits = binaryoptionmarketmanager.creatorlimits(capitalrequirement, skewlimit);
        return data;
    }

    function getmarketdata(binaryoptionmarket market) public view returns (marketdata memory) {
        (uint price, uint updatedat) = market.oraclepriceandtimestamp();
        (uint longclaimable, uint shortclaimable) = market.totalclaimablesupplies();
        (uint longsupply, uint shortsupply) = market.totalsupplies();
        (uint longbids, uint shortbids) = market.totalbids();
        (uint longprice, uint shortprice) = market.prices();

        return
            marketdata(
                oraclepriceandtimestamp(price, updatedat),
                binaryoptionmarket.prices(longprice, shortprice),
                deposits(market.deposited(), market.exercisabledeposits()),
                resolution(market.resolved(), market.canresolve()),
                market.phase(),
                market.result(),
                optionvalues(longbids, shortbids),
                optionvalues(longclaimable, shortclaimable),
                optionvalues(longsupply, shortsupply)
            );
    }

    function getaccountmarketdata(binaryoptionmarket market, address account) public view returns (accountdata memory) {
        (uint longbid, uint shortbid) = market.bidsof(account);
        (uint longclaimable, uint shortclaimable) = market.claimablebalancesof(account);
        (uint longbalance, uint shortbalance) = market.balancesof(account);

        return
            accountdata(
                optionvalues(longbid, shortbid),
                optionvalues(longclaimable, shortclaimable),
                optionvalues(longbalance, shortbalance)
            );
    }
}
