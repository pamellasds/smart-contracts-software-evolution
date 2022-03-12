
pragma solidity >=0.4.10;

import ;
import ;

contract sale {
    
    
    
    uint public constant softcap_time = 4 hours;

    address public owner;    
    address public newowner; 
    string public notice;    
    uint public start;       
    uint public end;         
    uint public cap;         
    uint public softcap;     
    bool public live;        

    receiver public r0;
    receiver public r1;
    receiver public r2;

    function sale() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    
    function emitbegin() internal {
        r0.start();
        r1.start();
        r2.start();
    }

    
    function emitend() internal {
        r0.end();
        r1.end();
        r2.end();
    }

    function () payable {
        
        require(msg.sender == address(r0) || msg.sender == address(r1) || msg.sender == address(r2));
        require(block.timestamp >= start);

        
        
        if (this.balance > softcap && block.timestamp < end && (end  block.timestamp) > softcap_time)
            end = block.timestamp + softcap_time;

        
        
        
        
        
        
        if (block.timestamp > end || this.balance > cap) {
            require(live);
            live = false;
            emitend();
        } else if (!live) {
            live = true;
            emitbegin();
        }
    }

    function init(uint _start, uint _end, uint _cap, uint _softcap) onlyowner {
        start = _start;
        end = _end;
        cap = _cap;
        softcap = _softcap;
    }

    function setreceivers(address a, address b, address c) onlyowner {
        r0 = receiver(a);
        r1 = receiver(b);
        r2 = receiver(c);
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

    
    function withdraw() onlyowner {
        msg.sender.transfer(this.balance);
    }

    
    function withdrawsome(uint value) onlyowner {
        require(value <= this.balance);
        msg.sender.transfer(value);
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

