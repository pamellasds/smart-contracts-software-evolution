



pragma solidity ^0.5.0;


interface ierc20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferfrom(address from, address to, uint256 value) external returns (bool);

    function totalsupply() external view returns (uint256);

    function balanceof(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event transfer(address indexed from, address indexed to, uint256 value);

    event approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.5.0;


library safemath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a  b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.5.0;




contract erc20 is ierc20 {
    using safemath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalsupply;

    
    function totalsupply() public view returns (uint256) {
        return _totalsupply;
    }

    
    function balanceof(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    
    function transferfrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    
    function increaseallowance(address spender, uint256 addedvalue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedvalue));
        return true;
    }

    
    function decreaseallowance(address spender, uint256 subtractedvalue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedvalue));
        return true;
    }

    
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit transfer(from, to, value);
    }

    
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalsupply = _totalsupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit transfer(address(0), account, value);
    }

    
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalsupply = _totalsupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit transfer(account, address(0), value);
    }

    
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit approval(owner, spender, value);
    }

    
    function _burnfrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}



pragma solidity ^0.5.0;



contract tokenminterc20token is erc20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalsupply, address payable feereceiver, address tokenowneraddress) public payable {
      _name = name;
      _symbol = symbol;
      _decimals = decimals;

      
      _mint(tokenowneraddress, totalsupply);

      
      feereceiver.transfer(msg.value);
    }

    

    
    function name() public view returns (string memory) {
      return _name;
    }

    
    function symbol() public view returns (string memory) {
      return _symbol;
    }

    
    function decimals() public view returns (uint8) {
      return _decimals;
    }
}
