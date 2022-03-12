pragma solidity ^0.5.16;

import ;
import ;



contract exchangestate is owned, state {
    struct exchangeentry {
        bytes32 src;
        uint amount;
        bytes32 dest;
        uint amountreceived;
        uint exchangefeerate;
        uint timestamp;
        uint roundidforsrc;
        uint roundidfordest;
    }

    mapping(address => mapping(bytes32 => exchangeentry[])) public exchanges;

    uint public maxentriesinqueue = 12;

    constructor(address _owner, address _associatedcontract) public owned(_owner) state(_associatedcontract) {}

    

    function setmaxentriesinqueue(uint _maxentriesinqueue) external onlyowner {
        maxentriesinqueue = _maxentriesinqueue;
    }

    

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
    ) external onlyassociatedcontract {
        require(exchanges[account][dest].length < maxentriesinqueue, );

        exchanges[account][dest].push(
            exchangeentry({
                src: src,
                amount: amount,
                dest: dest,
                amountreceived: amountreceived,
                exchangefeerate: exchangefeerate,
                timestamp: timestamp,
                roundidforsrc: roundidforsrc,
                roundidfordest: roundidfordest
            })
        );
    }

    function removeentries(address account, bytes32 currencykey) external onlyassociatedcontract {
        delete exchanges[account][currencykey];
    }

    

    function getlengthofentries(address account, bytes32 currencykey) external view returns (uint) {
        return exchanges[account][currencykey].length;
    }

    function getentryat(
        address account,
        bytes32 currencykey,
        uint index
    )
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
        )
    {
        exchangeentry storage entry = exchanges[account][currencykey][index];
        return (
            entry.src,
            entry.amount,
            entry.dest,
            entry.amountreceived,
            entry.exchangefeerate,
            entry.timestamp,
            entry.roundidforsrc,
            entry.roundidfordest
        );
    }

    function getmaxtimestamp(address account, bytes32 currencykey) external view returns (uint) {
        exchangeentry[] storage userentries = exchanges[account][currencykey];
        uint timestamp = 0;
        for (uint i = 0; i < userentries.length; i++) {
            if (userentries[i].timestamp > timestamp) {
                timestamp = userentries[i].timestamp;
            }
        }
        return timestamp;
    }
}
