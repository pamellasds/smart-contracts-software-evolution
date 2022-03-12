
pragma solidity >=0.4.10;

import ;
import ;


contract receiver {
    event startsale();
    event endsale();
    event etherin(address from, uint amount);

    address public owner;    
    address public newowner; 
    string public notice;    

    sale public sale;

    function receiver() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlysale() {
        require(msg.sender == address(sale));
        _;
    }

    function live() constant returns(bool) {
        return sale.live();
    }

    
    function start() onlysale {
        startsale();
    }

    
    function end() onlysale {
        endsale();
    }

    function () payable {
        
        etherin(msg.sender, msg.value);
        require(sale.call.value(msg.value)());
    }

    
    function changeowner(address next) onlyowner {
        newowner = next;
    }

    
    function acceptownership() {
        require(msg.sender == newowner);
        owner = msg.sender;
        newowner = 0;
    }

    
    function setnotice(string note) onlyowner {
        notice = note;
    }

    
    function setsale(address s) onlyowner {
        sale = sale(s);
    }

    
    
    

    
    function withdrawtoken(address token) onlyowner {
        token t = token(token);
        require(t.transfer(msg.sender, t.balanceof(this)));
    }

    
    function refundtoken(address token, address sender, uint amount) onlyowner {
        token t = token(token);
        require(t.transfer(sender, amount));
    }
}

