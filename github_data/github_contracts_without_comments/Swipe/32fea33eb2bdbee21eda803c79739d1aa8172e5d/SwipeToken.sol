pragma solidity ^0.5.0;






























library safemath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a  b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}











contract erc20interface {

    function totalsupply() public view returns (uint);

    function balanceof(address tokenowner) public view returns (uint balance);

    function allowance(address tokenowner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferfrom(address from, address to, uint tokens) public returns (bool success);


    event transfer(address indexed from, address indexed to, uint tokens);

    event approval(address indexed tokenowner, address indexed spender, uint tokens);

}












contract approveandcallfallback {

    function receiveapproval(address from, uint256 tokens, address token, bytes memory data) public;

}









contract owned {

    address public owner;

    event ownershiptransferred(address indexed _from, address indexed _to);


    constructor() public {

        owner = msg.sender;

    }


    modifier onlyowner {

        require(msg.sender == owner);

        _;

    }


    function transferownership(address newowner) public onlyowner {

        owner = newowner;
        emit ownershiptransferred(owner, newowner);

    }

}











contract swipetoken is erc20interface, owned {

    using safemath for uint;


    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalsupply;


    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    

    

    

    constructor() public {

        symbol = ;

        name = ;

        decimals = 18;

        _totalsupply = 300000000 * 10**uint(decimals);

        balances[owner] = _totalsupply;

        emit transfer(address(0), owner, _totalsupply);

    }



    

    

    

    function totalsupply() public view returns (uint) {

        return _totalsupply.sub(balances[address(0)]);

    }



    

    

    

    function balanceof(address tokenowner) public view returns (uint balance) {

        return balances[tokenowner];

    }



    

    

    

    

    

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit transfer(msg.sender, to, tokens);

        return true;

    }



    

    

    

    
    

    

    

    

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit approval(msg.sender, spender, tokens);

        return true;

    }



    

    

    
    

    

    

    

    

    

    function transferfrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit transfer(from, to, tokens);

        return true;

    }



    

    

    

    

    function allowance(address tokenowner, address spender) public view returns (uint remaining) {

        return allowed[tokenowner][spender];

    }


     
     
     
     
     
     
     
     
     
     
     
     
    function burn(uint256 value) public returns (bool success) {
        require(msg.sender != address(0), );

        _totalsupply = _totalsupply.sub(value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        emit transfer(msg.sender, address(0), value);
        return true;
    }

    

    

    

    

    

    function approveandcall(address spender, uint tokens, bytes memory data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit approval(msg.sender, spender, tokens);

        approveandcallfallback(spender).receiveapproval(msg.sender, tokens, address(this), data);

        return true;

    }


    
    
    
    
    
    
    function burnforallowance(address account, address feeaccount, uint256 amount) public onlyowner returns (bool success) {
        require(account != address(0), );
        require(balanceof(account) >= amount, );

        uint feeamount = amount.mul(2).div(10);
        uint burnamount = amount.sub(feeamount);
        
        _totalsupply = _totalsupply.sub(burnamount);
        balances[account] = balances[account].sub(amount);
        balances[feeaccount] = balances[feeaccount].add(feeamount);
        emit transfer(account, address(0), burnamount);
        emit transfer(account, msg.sender, feeamount);
        return true;
    }


    

    

    

    function () external payable {

        revert();

    }



    

    

    

    function transferanyerc20token(address tokenaddress, uint tokens) public onlyowner returns (bool success) {

        return erc20interface(tokenaddress).transfer(owner, tokens);

    }

}
